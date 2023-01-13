---
layout: post
title: "OpenGL1.4自定义Vertex"
date: 2023-01-08
categories: Graphics
tags: OpenGL
excerpt: Vertex不止坐标
---

* content
{:toc}

## vertex自定义

将颜色数值也放入vertex中

```cpp
float triangle_vertices[] = {
    // positions         // colors
      0.0f, -0.5f, 0.0f,  1.0f, 0.0f, 0.0f,   // bottom right
    -1.0f, -0.5f, 0.0f,  0.0f, 1.0f, 0.0f,   // bottom left
    -0.5f,  0.5f, 0.0f,  0.0f, 0.0f, 1.0f    // top
};
```

## vertex shader

定义两个输入属性`aPos`和`aColor`，`location`下标分别为1，2

定义一个输出属性`ourColor`

```cpp
#version 330 core
layout (location = 0) in vec3 aPos;   // the position variable has attribute position 0
layout (location = 1) in vec3 aColor; // the color variable has attribute position 1
  
out vec3 ourColor; // output a color to the fragment shader

void main()
{
    gl_Position = vec4(aPos, 1.0);
    ourColor = aColor; // set ourColor to the input color we got from the vertex data
} 
```

![输入数据布局]({{site.static}}/images/opengl-vetex-layout.png)

设置vertex attribute， 注意第一个参数location下标的使用， 最后一个参数起始offset

```cpp
// position attribute
glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 6 * sizeof(float), (void*)0);
// color attribute
glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, 6 * sizeof(float), (void*)(3* sizeof(float)));

glEnableVertexAttribArray(0);
glEnableVertexAttribArray(1);
```

## fragment shader

使用vertex shader传递的属性`ourColor`, 作为输出颜色

```cpp
#version 330 core
out vec4 FragColor;  
in vec3 ourColor;
  
void main()
{
    FragColor = vec4(ourColor, 1.0);
}
```

fragment shader具有插值(interpolation)功能，通常在栅格化(rasterization)过程, fragment shader会比vertex shader指定更多的fragment， 所以根据位置会将所有当前位置的fragment颜色做插值处理。插值之后两种颜色之间会有个渐变过程

## 多个VAO

VAO对VBO, EBO是引用，所以多个VAO就要创建多个对应的VBO，VEO。

![VAO]({{site.static}}/images/oepngl-vao-vbo-ebo.png)

```cpp
GLuint VAO[2], VBO[2], EBO;
glGenVertexArrays(2, VAO);
glGenBuffers(2, VBO);
glGenBuffers(1, &EBO);

glDeleteVertexArrays(2, VAO);
glDeleteBuffers(2, VBO);
glDeleteBuffers(1, &EBO);
```

## 绘制图形

![结果]({{site.static}}/images/opengl-lesson-04-result.png)

[代码](https://github.com/geemaple/learning/blob/main/learn_opengl/learn_opengl/lesson/lesson_04_vertex.cpp)

## 更多

1. [https://learnopengl.com/Getting-started/Shaders](https://learnopengl.com/Getting-started/Shaders)