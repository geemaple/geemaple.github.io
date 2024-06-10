---
layout: post
title: "OpenGL1.3 - 高阶着色语言GLSL"
categories: Graphics
tags: C++ OpenGL
excerpt: GLSL语言
---

* content
{:toc}

## 状态机

OpenGL本身是一个大的状态机，一堆状态指示显卡如何绘制。这些状态叫做Context

我们绘制的时候，通常改变一些状态，改变buffers，然后用context来绘制

Shaders是GPU中的小程序，他们是流水线上的特殊功能程序，只有输入和输出，彼此见也没有交流

## GLSL

GLSL类似C语言，专门用来图形绘制，包含vector和matrix处理

### 语法

1. 首先是版本声明
2. 输入和输出变量
3. uniform
4. 主函数

```cpp
#version version_number
in type in_variable_name;
in type in_variable_name;

out type out_variable_name;
  
uniform type uniform_name;
  
void main()
{
  // process input(s) and do some weird graphics stuff
  ...
  // output processed stuff to output variable
  out_variable_name = weird_stuff_we_processed;
}
```

vertex shade每一个输入变量也称vertex attribute, 硬件会规定最多允许多少个输入变量

OpenGL标准是至少有16个vec4输入变量，但是最终取决于硬件

```cpp
int nrAttributes;
glGetIntegerv(GL_MAX_VERTEX_ATTRIBS, &nrAttributes);
std::cout << "Maximum nr of vertex attributes supported: " << nrAttributes << std::endl;
```

### 基本数据类型

```cpp
int, float, double, uint, bool
```

### Vectors

```cpp
n = [2, 4]

vecn: float // vec2, vec3, vec4
bvecn: boolean
ivecn: integers
uvecn: unsigned integers
dvecn: double

// 向量常用下标
x, y, z, w
r, g, b, a
s, t, p, q

// swizzling
vec2 someVec;
vec4 differentVec = someVec.xyxx;
vec3 anotherVec = differentVec.zyw;
vec4 otherVec = someVec.xxxx + anotherVec.yxzy;

vec2 vect = vec2(0.5, 0.7);
vec4 result = vec4(vect, 0.0, 0.0);
vec4 otherResult = vec4(result.xyz, 1.0);
```

### 输入输出

**vertex shader**输入是不同的，主要是因为输入来自vertex，而vertex可以自由定义

所以vertex shader需要一个`layout (location = 0)`来指定用哪个`VertexAttrib`来解析数据

**fragment shader**负责生成最终的颜色，需要vec4的颜色输出， 如果忘记输出，通常数据会成为undefined, 绘制的结果可能是白色或者黑色

流水线意味着一个shader的输出是另一个shader的输入，当流水线上两个shaders的类型和名字匹配的时候，程序会把变量链接起来，这样shaders之间就可以传递数据了

例如下面的vertexColor

```cpp
// vertex shader
#version 330 core
layout (location = 0) in vec3 aPos; // the position variable has attribute position 0
  
out vec4 vertexColor; // specify a color output to the fragment shader

void main()
{
    gl_Position = vec4(aPos, 1.0); // see how we directly give a vec3 to vec4's constructor
    vertexColor = vec4(0.5, 0.0, 0.0, 1.0); // set the output variable to a dark-red color
}

// fragment shader
#version 330 core
out vec4 FragColor;
  
in vec4 vertexColor; // the input variable from the vertex shader (same name and same type)  

void main()
{
    FragColor = vertexColor;
} 
```

### Uniforms

Uniforms是另一种传递数据的方法就是, 它将数据从CPU传递到GPU  

Uniforms和vertex attributes有些不同:

1. Uniforms是global的，可以被程序中的任意shader使用
2. Uniforms会保存数据，直到重置或变更

```cpp
#version 330 core
out vec4 FragColor;
  
uniform vec4 ourColor; // we set this variable in the OpenGL code.

void main()
{
    FragColor = ourColor;
} 
```

注意如果uniform变量在任何GLSL中都没有使用，编译器会悄悄移除变量

通过`glUniformxy`设置uniform变量, 由于OpenGL是C语言不支持函数重载, X代表向量纬度，Y代表数据类型, 

查找变量不需要`glUseProgram`, 但`glUniformXY`设置的时候需要：

```cpp
float timeValue = glfwGetTime();
float greenValue = (sin(timeValue) / 2.0f) + 0.5f; // sin function return [-1, 1]
int vertexColorLocation = glGetUniformLocation(shaderProgram, "ourColor");

glUseProgram(shaderProgram);
glUniform4f(vertexColorLocation, 0.0f, greenValue, 0.0f, 1.0f);
```

## 绘制多边形

OpenGL只处理三角形，那么多边形就只能画对角线，切割成三角形了

```cpp
float vertices[] = {
    // first top-right triangle
     0.5f,  0.5f, 0.0f,  // top right
     0.5f, -0.5f, 0.0f,  // bottom right
    -0.5f,  0.5f, 0.0f,  // top left 
    // second bottom-left triangle
     0.5f, -0.5f, 0.0f,  // bottom right
    -0.5f, -0.5f, 0.0f,  // bottom left
    -0.5f,  0.5f, 0.0f   // top left
}; 
```

## EBO

由于两个三角形要拼接在一起，就会有两个坐标点重复，算是额外开销，如果是100多边形，那么重复量就很大了, EBO(element buffer objects)适用于这个场景

```cpp
    float vertices[] = {
         0.5f,  0.5f, 0.0f,  // top right
         0.5f, -0.5f, 0.0f,  // bottom right
        -0.5f, -0.5f, 0.0f,  // bottom left
        -0.5f,  0.5f, 0.0f   // top left
    };
    unsigned int indices[] = {  // note that we start from 0!
        0, 1, 3,   // first triangle
        1, 2, 3    // second triangle
    };
    
    GLuint EBO;
    // create
    glGenBuffers(1, &EBO);
    
    ...
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, EBO);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_STATIC_DRAW);
```

注意当目标为`GL_ELEMENT_ARRAY_BUFFER`，VAO也会保存bind与unbind信息，所以要在VAO激活时解绑EBO，这可能不是你想要的

## 绘制四边形

![结果]({{site.static}}/images/opengl-lesson-03-result.png)

绘制的时候要使用新的函数

```cpp
    glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, 0);
```

[源码](https://github.com/geemaple/learning/blob/main/learn_opengl/learn_opengl/lesson/lesson_03_rectangle.cpp)


## 更多

1. [https://learnopengl.com/Getting-started/Shaders](https://learnopengl.com/Getting-started/Shaders)
2. [https://open.gl/drawing](https://open.gl/drawing)