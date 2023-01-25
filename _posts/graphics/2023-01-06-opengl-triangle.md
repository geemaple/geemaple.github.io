---
layout: post
title: "OpenGL1.2绘制三角形Triangle"
date: 2023-01-06
categories: Graphics
tags: OpenGL C++
excerpt: 三角形是最稳定的
---

* content
{:toc}

## 双缓冲设计

```cpp
void glfwSwapBuffers(GLFWwindow * window)

/* This function swaps the front and back buffers of the specified window. If the swap interval is greater than zero, the GPU driver waits the specified number of screen updates before swapping the buffers.

When an application draws in a single buffer the resulting image may display flickering issues. This is because the resulting output image is not drawn in an instant, but drawn pixel by pixel and usually from left to right and top to bottom. Because this image is not displayed at an instant to the user while still being rendered to, the result may contain artifacts. To circumvent these issues, windowing applications apply a double buffer for rendering. The front buffer contains the final output image that is shown at the screen, while all the rendering commands draw to the back buffer. As soon as all the rendering commands are finished we swap the back buffer to the front buffer so the image can be displayed without still being rendered to, removing all the aforementioned artifacts.
*/
```

`glfwSwapBuffers`采用两个缓冲设计，因为绘制不是立即完成的，所以绘制在幕后进行，当绘制完成后，在切换到前台给用户看到，这样增强用户体验

## 垂直同步

```cpp
void glfwSwapInterval(int interval) 
/* 
    This function sets the swap interval for the current context, This is sometimes called 'vertical synchronization', 'vertical retrace synchronization' or 'vsync', 
    interval = The minimum number of screen updates to wait for until the buffers are swapped by glfwSwapBuffers 
*/
```

设置要等多少次屏幕刷新，才切换幕后缓冲到前台

## [栅格化](https://en.wikipedia.org/wiki/Rasterisation)

![栅格化]({{site.static}}/images/opengl-top-left-triangle-rasterization-rule.gif)

完美的几何图形可以比作无限高清图片，当矢量绘制到低像素屏幕上，就会出现一个现象，就是信息会丢失。

需要决定哪些像素块需要绘制，哪些不需要，这个过程叫做栅格化。

信息丢失的结果是弧线看起来有锯齿，可以打开抗锯齿(当然是由性能消耗的)。

抗锯齿并不能分割像素，抗锯齿做的是在黑白世界，增加了灰度，使得曲线看起来比较平滑

## 绘图流水线

```
Application =>  Geometry => Rasterization => Screen
    应用            几何         栅格化          屏幕
```

OpenGL世界是3D, 但屏幕是2D的，所以很大一部分绘制工作，就是将3D坐标转换成2D坐标。

Graphics Pipeline的另一部分工作室，将转换的2D坐标，绘制成颜色像素点

流水线上的操作处理程序，称作shaders，随着时间推移，shaders一词已经进化成为处理图形渲染的专门程序

![Graphics Pipeline]({{site.static}}/images/opengl-graphics-pipeline.png)

上图是流水线处理过程，具体可通过代码了解，蓝色部分的shaders可以通过GLSL语言控制

## VBO

屏幕坐标范围[-1, 1], 每一组三维坐标(x, y, z), 其中 z=0

![坐标]({{site.static}}/images/opengl-triangle-vertex-buffer.png)

定义坐标数组，然后将数据拷贝到显卡存储单元VBO(vertex buffer objects)中，GPU中的显存要比内存快得多

从CPU到显卡推送数据比较慢，所以OpenGL期待传送一个array包含所有vetices

1. 在显卡创建一个Buffer
2. 通过Bind改变OpenGL状态机，将其设定为当前的Buffer
3. 拷贝数据到Buffer中(注意使用GL_ARRAY_BUFFER而不是id)

拷贝数据最后一个参数决定，GPU内存使用类型
* GL_STATIC_DRAW = 上传一次, 绘制多次
* GL_DYNAMIC_DRAW = 多次上传，绘制多次
* GL_STREAM_DRAW = 流式，上传一次，绘制一次，不断重复

```cpp
    float vertices[] = {
        -0.5f, -0.5f, 0.0f, //left
         0.5f, -0.5f, 0.0f, //right
         0.0f,  0.5f, 0.0f  // top
    };

    unsigned int VBO; // vertex buffer object
    glGenBuffers(1, &VBO);
    glBindBuffer(GL_ARRAY_BUFFER, VBO);
    
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
```

## VAP

Vertex Shader允许传入不同的Buffer，我们还需要告诉OpenGL数据结构，才能解析
以三角形坐标为例，

```cpp
// index = 0 (GLSL的location, glEnableVertexAttribArray)中需一致
// 数据维度 = 3
// 数据类型 = GL_FLOAT
// 是否需要normalized，如果是无符号转换成[0, 1], 有符号数据转换成[-1, 1]
// 下一组数据的offset
// 第一组数据起始offset
glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3 * sizeof(float), (void*)0);
```

## VAO

通常需要数十个VBO来维持不同坐标，纹理，命令等等，一个个绑定十分麻烦。
新版OpenGL提供了VAO(vertex array object)，能够存储所有的vertex.

1. 创建一个Buffer Array
2. 通过Bind绑定
3. 绑定后`glVertexAttribPointer glEnableVertexAttribArray glDisableVertexAttribArray`操作都会存储到VAO中
4. 和调用`glDisableVertexAttribArray`相关的VBO引用也会存储到VAO中
5. 需要enable属性

```cpp
unsigned int VAO;
// create VAO
glGenVertexArrays(1, &VAO);
glBindVertexArray(VAO);
// agttributes
glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3 * sizeof(float), (void*)0);
glEnableVertexAttribArray(0);
```

## GLSL

GLSL和C语言很像，需要编译后才能使用，OpenGL程序至少需要两个shader才能工作，若有任何错误OpenGL选择躺平不画:

1. vertex shader处理坐标
2. fragment shader上色

### vertex shader

GLSL最大是纬度是4，也就是vec4, 分别为(x, y, z, w), 前三个是3维坐标，最后一个w和视角有关系

330对应版本3.3(从3.3开始版本才开始对应)，使用core mode，一个输入变量in vec3, gl_Position为输出

```cpp
#version 330 core
layout (location = 0) in vec3 aPos;

void main()
{
    gl_Position = vec4(aPos.x, aPos.y, aPos.z, 1.0);
}
```

### frament shader

一个输出out vec4，代表RGBA颜色，数值范围[0.0, 1.0]

```cpp
#version 330 core
out vec4 FragColor;

void main()
{
    FragColor = vec4(1.0f, 0.5f, 0.2f, 1.0f);
} 
```

最后，需要编译，链接才能使用，可以修改DLSL源码，但是要重新链接才能生效

## 绘制三角形

![结果]({{site.static}}/images/opengl-lesson-02-result.png)

```cpp
// commonly point, line or triangle
glDrawArrays(GL_TRIANGLES, 0, 3);
```

[源码](https://github.com/geemaple/learning/blob/main/learn_opengl/learn_opengl/lesson/lesson_02_triangle.cpp)

## 更多

1. [https://learnopengl.com/Getting-started/Hello-Triangle](https://learnopengl.com/Getting-started/Hello-Triangle)
2. [http://antongerdelan.net/opengl/hellotriangle.html](http://antongerdelan.net/opengl/hellotriangle.html)
3. [https://open.gl/drawing](https://open.gl/drawing)