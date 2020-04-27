---
title: "Java中的类型"
date: 2020-04-27T11:55:11+08:00
draft: false
categories: ["Java"]
---

# Java 中的类型

导读：最新在学习 Android 的过程中经常见到 `ParameterizedType` ，但是不是很明白这个时什么，今天利用这篇博客好好总结一下关于 java 中的 `Type`。

## Java 中的 Type

`Type` 是 Java 语言中的所有类型的公共超级接口。这些类型包括：

1. raw types
2. parameterized types
3. array types
4. type variables
5. primitive types

`Type` 类型是 JDK5 开始引入的，引入的目的主要是为了泛型，在没有泛型之前，所有的类型都是原始类型（raw types）。所有的原始类型都通过 `Class` 进行抽象，但是引入泛型后就无法获取一个类的泛型信息。

| 类型                | 中文名称       | 对应的类            | 解释                                                         |
| ------------------- | -------------- | ------------------- | ------------------------------------------------------------ |
| raw types           | 原始类型       | `Class`             | 如果一个类型是有泛型的，但是在创建的时候没有指定类型，那么这个类的类型就是原始类型 |
| parameterized types | 参数化类型     | `ParameterizedType` | 带有泛型参数的类型                                           |
| array types         | (泛型)数组类型 | `GenericArrayType`  | 比如 `List<T>[]` `T[]`                                       |
| type variables      | 类型变量       | `TypeVariable<D>`   | 如参数化类型中的 T、V 等                                     |
| primitive types     | 基本类型       | `Class`             | 八大基本类型: `int`、`long`、`short`、`byte`、`float`、`double`、`char`、`boolean` |

这里还有一个 `WildcardType` ，我们从这个接口的注释上可以看出这个类表示的通配符，例如 `<?>`、`<? extends Number>`、或者 `<? super Integer>`。



![image-20200426212653695](C:\Users\mengchen\AppData\Roaming\Typora\typora-user-images\image-20200426212653695.png)

下面写了一个类来检测一个类的 Type:

```java
public class GetClassType<T> {

    T[] ts;

    private static void getType(Type type) {
        if (type instanceof GenericArrayType) {
            System.out.println("GenericArrayType");
        }
        if (type instanceof ParameterizedType) {
            System.out.println("ParameterizedType");
        }
        if (type instanceof TypeVariable) {
            System.out.println("TypeVariable");
        }
        if (type instanceof WildcardType) {
            System.out.println("WildcardType");
        }

        if (type instanceof Class) {
            System.out.println("Class");
        }

    }
    
    public static boolean isPrimitive(Class<?> clazz) {
        return clazz.isPrimitive();
    }

    public static void main(String[] args) throws NoSuchFieldException {
        List<Integer> list = new ArrayList<>();
        System.out.println("List<Integer> type is: ");
        getType(list.getClass().getGenericSuperclass());
        // raw type
        System.out.println("list 变量对应类型的父类的 raw type: " + ((ParameterizedType) list.getClass().getGenericSuperclass()).getRawType());
        Type type = ((ParameterizedType) list.getClass().getGenericSuperclass()).getActualTypeArguments()[0];
        System.out.println("List<Integer> 类的第一个泛型参数的类型: ");
        getType(type);
        System.out.println("GetClassType.ts 的类型是: ");
        Field fieldTs = GetClassType.class.getDeclaredField("ts");
        Type fieldTsType = fieldTs.getGenericType();
        getType(fieldTsType);
        // primitive type
        System.out.println("int.class 是否是 primitive type = " + isPrimitive(int.class));
    }
}
```

下面我们来逐个介绍一下这些类型。

## raw types

上面也提到了因为引入了泛型，所以就有了这一系列的 `Type`，raw type 是为了向前兼容的产物。也就是说如果一个有泛型的类，在创建的时候不指定泛型，那么这个类的 `Type` 就是 raw type。当然不推荐使用 raw type。

## parameterized types

如果一个类型有泛型，并且在声明这个类型的变量的时候使用了泛型（如果没有使用就是 raw type），那么这个类的 type 就是 parameterized 。下面我们来通过代码来使用一下 parameterized 。

```java
public class ParameterizedTypeDemo {

    ParameterizedTypeDemoTest<Integer> test = new ParameterizedTypeDemoTest<>();

    public static void main(String[] args) throws NoSuchFieldException {
        ParameterizedType parameterizedType = (ParameterizedType) ParameterizedTypeDemo.class.getDeclaredField("test").getGenericType();
        Type[] arguments = parameterizedType.getActualTypeArguments();
        System.out.println("parameterizedType 的类型参数: ");
        for (Type argument : arguments) {
            System.out.println(argument);
        }
        Type rawType = parameterizedType.getRawType();
        System.out.println("parameterizedType 对应的 raw type 是: " + rawType.getTypeName());
        Type ownerType = parameterizedType.getOwnerType();
        System.out.println("parameterizedType 的 owner type 是: " + ownerType.getTypeName());
    }

    class ParameterizedTypeDemoTest<T> {

    }
}
```

`ParameterizedType` 中有如下三个方法: 

1. `getActualTypeArguments` 获取实际的参数列表（也就是声明变量的时候指定的泛型）。
2. `getRawType` 获取 parameterized type 对应的 raw type。
3. `getOwnerType` 获取拥有 `ParameterizedType`  类型变量的类对应的类型。

上面的代码演示了这三种方法。

## array types

array type 表示的是泛型数组，在代码中我们无法直接创建泛型数组，但是可以通过强制类型转换将非泛型数组转换成泛型数组或者通过 `Array` 创建数组然后再强制类型转换，如下代码：

```java
public class GenericArrayTypeDemo<T> {

    T[] ts;

    @SuppressWarnings("unchecked")
    public GenericArrayTypeDemo(int length) {
        ts = (T[]) new Object[length];
    }

    @SuppressWarnings("unchecked")
    public static <S> S[] getArrayType(Class<S> clazz, int length) {
        return (S[]) Array.newInstance(clazz, length);
    }

    public static void main(String[] args) {
        GenericArrayTypeDemo<Integer> demo = new GenericArrayTypeDemo<>(10);
    }

}
```

`GenericArrayType` 中特有的方法是 `getGenericComponentType()` ，这个方法的作用是获取 `GenericArrayType` 对应的类型去掉一层数组 (`[]`) 之后的类型，例如: `T[]` 通过 ``getGenericComponentType` 方法获取到的类型是 `T`；`T[][]` 通过  `getGenericComponentType` 方法获取到的类型是 `T[]`。下面的代码演示了这个方法的作用。

```java
public class GenericArrayTypeDemo<T> {

    T[] ts;
    T[][] tss;

    @SuppressWarnings("unchecked")
    public GenericArrayTypeDemo(int length) {
        ts = (T[]) new Object[length];
    }

    @SuppressWarnings("unchecked")
    public static <S> S[] getArrayType(Class<S> clazz, int length) {
        return (S[]) Array.newInstance(clazz, length);
    }

    public static void main(String[] args) throws NoSuchFieldException {
        GenericArrayTypeDemo<Integer> demo = new GenericArrayTypeDemo<>(10);
        GenericArrayType type = (GenericArrayType) GenericArrayTypeDemo.class.getDeclaredField("ts").getGenericType();
        System.out.println("GenericArrayTypeDemo 中 ts 的变量类型是: ");
        System.out.println(type.getGenericComponentType());     // 输出 T
        GenericArrayType type2 = (GenericArrayType) GenericArrayTypeDemo.class.getDeclaredField("tss").getGenericType();
        System.out.println("GenericArrayTypeDemo 中 tss 的变量类型是: ");
        System.out.println(type2.getGenericComponentType());    // 输出 T[]
    }

}
```

## type variables

type variable 表示的是类型参数，也就是泛型。例如: `List<T>`，那么它的类型参数就是 `T`。

`GenericArrayType` 中特有的方法是 `getBounds()` ，这个方法返回的是该类型参数的上界，当然上界可能不止一个，所以返回了一个数组 `Type[]`。

```java
public class TypeVariableDemo<T extends Number & Serializable> {

    List<T> listT;

    public static void main(String[] args) throws NoSuchFieldException {
        TypeVariable type =
                (TypeVariable) (((ParameterizedType) TypeVariableDemo.class.getDeclaredField("listT").getGenericType()).getActualTypeArguments()[0]);
        System.out.println("TypeVariableDemo 中 listT 的类型参数是: ");
        System.out.println(type);
        System.out.println("该类型参数的上界是: ");
        System.out.println(Arrays.toString(type.getBounds()));
    }

}
```

## primitive types

这个有人翻译为原始数据类型，但是我觉得翻译成基本数据类型更加恰当，因为 primitive type 表示的是: `int`、`double` 之类的基本类型。

`int` 对应的 `Class` 是 `int.class`，`int.class` 就是一个 primitive。