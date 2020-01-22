---
title: "Java 并发之无锁"
date: 2018-10-09T17:15:00+08:00
draft: false
toc: true
categories: ["Java", "并发"]
---


# Java并发编程之无锁

在谈论无所之前先来看看乐观派和悲观派。对于乐观派而言，他们总认为事情总会朝着好的方向发展，总认为几乎不会坏事，我已可以随意的去做事。但是对于悲观派来说，他们认为出错是一种常态，所以无论事情大小都会考虑的面面俱到，滴水不漏。

在两种派别对应在并发中就是加锁和无锁，也就是说加锁是一种悲观的策略，而无锁是一种乐观的策略。对于锁，如果有多个线程同事访问一个临界资源，宁可牺牲性能让线程等待，也不会让一个线程不加锁访问临界资源。对于无锁，它会假定对资源的访问是没有冲突的。也就是多个线程对临界资源的访问是没有冲突的。既然没有冲突，那么就不需要等待，所有的线程都可以不需要等待的执行下去。如果遇到了冲突，怎么办？这里无锁策略使用了一种称为CAS的技术来保证线程执行的安全性。下面我们来具体讨论一下CAS。

## 无锁解决冲突的办法：CAS

CAS的全称是Compare And Swap即比较和交换。

CAS算法的过程是这样的：它包含三个参数的变量CAS(V, E, N)。作用如下：

+ V 表示要更新的值。
+ E 表示预期的值。
+ N 表示新值。

**仅当V值等于E值的，才会将V值设置为N值**，如果V值和E值不同，则说明已经有其他线程做了更新，当前线程什么都不做。CVS返回的是当前V的真实值。
CAS是乐观派，总认为自己可以操作成功。当多个线程同时使用CAS来给一个变量设置时，只有一个会成功，其它的都会失败，但是CAS很乐观，失败了就失败了，可以再次尝试。

## Java中的指针：Unsafe类
What? Java中也有指针。Unsfae类就像它的名字一样，不安全，里面有一些向C语言的指针一样直接操作内存的方法。并且官方也不推荐直接使用Unsafe类。但是CAS的实现用到了这个类。
下面来看看Unsafe中的一些方法：

```java
// 分配内存
public native long allocateMemory(long var1);

// 重新分配内存
public native long reallocateMemory(long var1, long var3);

// 拷贝内存
public native void copyMemory(Object var1, long var2, Object var4, long var5, long var7);

// 释放内存
public native void freeMemory(long var1);

// 获取起始地址
public native long getAddress(long var1);


// 获取操作系统内存页大小
public native int pageSize();

.....
```

Unsafe中有两个方法可以将线程挂起和恢复，如下：

```java
// 线程调用方法，将线程挂起
public native void unpark(Object var1);

// 线程恢复
public native void park(boolean var1, long var2);
```

Unsafe中的关于CAS的操作：

```java
public final native boolean compareAndSwapObject(Object var1, long var2, Object var4, Object var5);

public final native boolean compareAndSwapInt(Object var1, long var2, int var4, int var5);

public final native boolean compareAndSwapLong(Object var1, long var2, long var4, long var6);
```

CAS的操作的核心实现是这三个方法。
三个方法的参数都类似，分别为：
1. CAS需要更改变量的对象；
2. 对象内存的偏移量;
3. 期望值
4. 需要设置的值

其中偏移量可以通过Unsafe类中的objectFieldOffset()方法获取到，这些方法如下：

```java
public native long objectFieldOffset(Field field);
```

因为int，long，boolean类型的相关操作不是原子性的，所以JDK在1.5之后提供了atomic包（具体在`java.util.concurrent.atomic`中）来将这些操作变成原子操作。

下面的图片中的是atomic下提供的原子操作的类：
![image.png](https://img-blog.csdn.net/20181017155907620?watermark/2/text/aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3N0YXJleHBsb2Rl/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70)

这里以AtomicInteger来进行分析：

```java
public class AtomicInteger extends Number implements java.io.Serializable {
    
    // 实例化Unsafe
    private static final Unsafe unsafe = Unsafe.getUnsafe();
    
    // valueOffset变量保存的是value中的偏移量，这一点可以在下面的static初始化块中可以看出
    private static final long valueOffset;

    static {
        try {
            // 获取value的偏移量
            valueOffset = unsafe.objectFieldOffset
                (AtomicInteger.class.getDeclaredField("value"));
        } catch (Exception ex) { throw new Error(ex); }
    }

    private volatile int value;

    /**
     * 通过int值实例化一个AtomicInteger对象
     */
    public AtomicInteger(int initialValue) {
        value = initialValue;
    }

    /**
     * 实例化一个AtomicInteger对象，其初始值为0
     */
    public AtomicInteger() {
    }
    
    // 获取当前值
    public final int get() {
        return value;
    }
    // 设置当前值
    public final void set(int newValue) {
        value = newValue;
    }

    // 延迟设值
    public final void lazySet(int newValue) {
        unsafe.putOrderedInt(this, valueOffset, newValue);
    }

    // 设置新值获取旧值
    public final int getAndSet(int newValue) {
        return unsafe.getAndSetInt(this, valueOffset, newValue);
    }

    // CAS操作，把当前值和预期值做比较，相当时设置新值
    public final boolean compareAndSet(int expect, int update) {
        return unsafe.compareAndSwapInt(this, valueOffset, expect, update);
    }

    
    public final boolean weakCompareAndSet(int expect, int update) {
        return unsafe.compareAndSwapInt(this, valueOffset, expect, update);
    }

    // 当前值加1，返回旧值
    public final int getAndIncrement() {
        return unsafe.getAndAddInt(this, valueOffset, 1);
    }

    // 当前值-1，返回旧值
    public final int getAndDecrement() {
        return unsafe.getAndAddInt(this, valueOffset, -1);
    }

    // 当前值加上delta，然后返回旧值
    public final int getAndAdd(int delta) {
        return unsafe.getAndAddInt(this, valueOffset, delta);
    }

    // 当前值加1，然后返回
    public final int incrementAndGet() {
        return unsafe.getAndAddInt(this, valueOffset, 1) + 1;
    }
    
    // 当前值减1，返回返回
    public final int decrementAndGet() {
        return unsafe.getAndAddInt(this, valueOffset, -1) - 1;
    }

    // 当前值加上delta，然后返回
    public final int addAndGet(int delta) {
        return unsafe.getAndAddInt(this, valueOffset, delta) + delta;
    }

    // ...
}
```
其中的大部分方法都直接或者间接使用了CAS来保证安全。

除了上面的对于基本变量的Atomic类，还有关于普通对象引用的Atmoic类。

## AtomicReference 无锁的引用

AtomicReference和AtmoicInteger非常类似，不同之处就是AtmoicInteger是对整数的封装，而AtmoicReference是对普通对象的引用，也就是它可以保证在修改对象引用时线程的安全性。

CAS中有一个很重要的问题ABA。CAS比较的是对象中的值和期望值，但是有可能在你获取到当前对象的数据后，在准备修改为新值之前，对象的值被其他线程连续修改两次，而且经过这两次修改之后，对象有恢复为旧值。这样，前后的结果看似没有被改过，但是其实已经被修改了2次。过程如下图：
![在这里插入图片描述](https://img-blog.csdn.net/20181010171642689?watermark/2/text/aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3N0YXJleHBsb2Rl/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70)

一般来说，发生这种事情的可能性很小。而且即使发生了也不会有什么影响，比如，一个数字，被修改一次后，在修改回去，不会对CAS产生什么影响。

但是有时候在一些具体问题中这种情况就有可能发生。所以在JDK中提供了AtomicStampedReference来解决这种问题。

## AtomicStampedReference

AtomicStampedReference在内部维护了一个时间戳。当AtmoicStampedReference对应的数字被修改时，除了更新数据本身，还必须更新时间戳。当AtomicStampedReference设置对象值时，对象和时间戳都必须满足期望值，才会写入成功。通过维护时间戳能有效的防止ABA问题。

AtmoicStampedReference的几个API在Atmomic的基础上新增了几个有关时间戳的信息。

```java
// 参数为：期望值，新值，期望时间戳，新的时间戳
public boolean compareAndSet(V   expectedReference,
                                 V   newReference,
                                 int expectedStamp,
                                 int newStamp);
// 获取索引
public V getReference()
// 获取时间戳
public int getStamp()
// 设置当前对象引用和时间戳
public void set(V newReference, int newStamp)
```
