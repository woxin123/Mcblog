---
title: "关于Java中的传参是值传递还是引用传递"
date: 2019-02-09T17:29:36+08:00
draft: false
categories: ["Java"]
---

在Java中其实只有值传递，而没有所谓的引用传递。既然Java中没有引用传递，那么到底什么才是引用传递呢？

在C++中是有引用传递的，下来我们来看一个简单的小程序，如下：

```c++
#include <iostream>
using namespace std;

int changeXtoY(int &x, int y) {
    x = y;
}

int main() {
    int a = 2;
    changeXtoY(a, 4);
    cout << "a=" << a << endl;
    return 0;
}
```

运行的结果是`a = 4`，这里的函数`changeXtoY`用到的就是引用传递，这里没有使用指针，而是使用了引用这种方式，`&x`就是a的一个引用，一旦x被修改，那么a也就被修改了。

在Java中的有两种类型的参数，一种是基本类型，一种是引用类型。基本类型是值传递，这个毫无疑问。引用类型虽然被称为引用类型，但是在传参的时候不是引用传递，而是值传递。引用类型所在的变量存储的是一个对象的句柄或指针，在传参的时候只是将这个句柄或指针的值复制了一份，就好比指针类型的传参一样。

我们把上面的例子进行升级，看看引用传递的实质是什么。

```c++
#include <iostream>
#include <cstdio>
using namespace std;

int changeXtoY(int &x, int y) {
    printf("x = %p\n", x);
    x = y;
    printf("x = %p\n", x);
}

int main() {
    int a = 2;
    printf("a = %p\n", a);
    changeXtoY(a, 4);
    cout << "a=" << a << endl;
    printf("a = %p\n", a);
    return 0;
}
```

结果如下：

```text
a = 0x2
x = 0x2
x = 0x4
a=4
a = 0x4
```

a的地址和`changeXtoY`方法中的x的地址是相同的，而在将x改变后的地址和方法调用结束后a的地址是相同的。这就是引用传递的实质，传递了参数的引用。

把Java中的引用类型的参数传递和c++中的引用传递比较一下，你就会发现Java中是没有引用传递的。**按值传递的精髓是：传递的是存储单元中的内容，而不是存储单元的引用！**