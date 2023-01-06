---
layout: post
title: "OpenGL绘制一个三角形"
date: 2023-01-06
categories: OpenGL
tags: graphics
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

## 抗锯齿

完美的几何图形可以比作无限高清图片，当矢量绘制到低像素屏幕上，就会出现一个现象，就是信息会丢失。

需要决定哪些像素块需要绘制，哪些不需要，这个过程叫做[栅格化](https://en.wikipedia.org/wiki/Rasterisation)。

信息丢失的结果是弧线看起来有锯齿，可以打开抗锯齿(当然是由性能消耗的)。

抗锯齿并不能分割像素，抗锯齿做的是在黑白世界，增加了灰度，舍得曲线看起来比较平滑

## 绘图流水线架构

```
Application =>  Geometry => Rasterization => Screen
    应用            几何         栅格化          屏幕
```

OpenGL世界是3D, 但屏幕是2D的，所以很大一部分绘制工作，就是将3D坐标转换成2D坐标。

Graphics Pipeline的另一部分工作室，将转换的2D坐标，绘制成颜色像素点

## 绘图流水线

1. 流水线通常意味着一条线的输出是另一条线的输入
2. 流水线可以同时进行

流水线上的操作处理程序，称作shaders，阳光下的暗影，但shaders一词已经进化成为处理图形渲染的专门程序

![Graphics Pipeline]({{site.static}}/images/Graphics_pipeline.png)

流水线的输入位Vertex，也就是3D空间的数据(坐标，颜色等)

## GLSL

### vertex shader

```cpp
#version 330 core
layout (location = 0) in vec3 aPos;

void main()
{
    gl_Position = vec4(aPos.x, aPos.y, aPos.z, 1.0);
}
```

### frament shader

```cpp
#version 330 core
out vec4 FragColor;

void main()
{
    // RGBA, value = [0.0 - 1.0]
    FragColor = vec4(1.0f, 0.5f, 0.2f, 1.0f);
} 
```

## [代码](https://github.com/geemaple/learning/blob/main/learn_opengl/learn_opengl/lesson/lesson_01.cpp)

```cpp
static unsigned int comipleShader(GLenum shaderType, const GLchar **code) {
    // shader
    unsigned int shader = glCreateShader(shaderType);
    
    // compile
    glShaderSource(shader, 1, code, NULL);
    glCompileShader(shader);
    
    int  success;
    char infoLog[512];
    glGetShaderiv(shader, GL_COMPILE_STATUS, &success);
    if(!success)
    {
        glGetShaderInfoLog(shader, 512, NULL, infoLog);
        std::cout << "ERROR::SHADER::COMPILATION_FAILED\n" << infoLog << std::endl;
    }
    
    return shader;
}

static unsigned int createShaderProgram() {

    unsigned int vertexShader = comipleShader(GL_VERTEX_SHADER, &vertexShaderSource);
    unsigned int fragmentShader = comipleShader(GL_FRAGMENT_SHADER, &fragmentShaderSource);

    // create shader program
    unsigned int shaderProgram;
    shaderProgram = glCreateProgram();
    glAttachShader(shaderProgram, vertexShader);
    glAttachShader(shaderProgram, fragmentShader);
    glLinkProgram(shaderProgram);
    
    int  success;
    char infoLog[512];
    glGetProgramiv(shaderProgram, GL_LINK_STATUS, &success);
    if(!success) {
        glGetProgramInfoLog(shaderProgram, 512, NULL, infoLog);
        std::cout << "ERROR::PROGRAM::COMPILATION_FAILED\n" << infoLog << std::endl;
    }
    
    glDeleteShader(vertexShader);
    glDeleteShader(fragmentShader);
    
    return shaderProgram;
}

int Lesson02::entry(void) {

    // create window
    GLFWwindow* window = createGraphicWindow("OpenGL Lesson 02", 800, 600);

    float vertices[] = {
        -0.5f, -0.5f, 0.0f, //left
         0.5f, -0.5f, 0.0f, //right
         0.0f,  0.5f, 0.0f  // top
    };
    
    unsigned int VBO, VAO;
    // create vertex buffer/Array objects on GPU
    glGenBuffers(1, &VBO);
    glGenVertexArrays(1, &VAO);
    
    // bind
    glBindVertexArray(VAO);
    glBindBuffer(GL_ARRAY_BUFFER, VBO);
    
    // copy data to the bond buffer
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
    
    // agttributes
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3 * sizeof(float), (void*)0);
    glEnableVertexAttribArray(0);
    
    // unbind
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindVertexArray(0);
    
    unsigned int shaderProgram = createShaderProgram();
    
    // render loop, each iteration is called a frame
    while(!glfwWindowShouldClose(window))
    {
        processInput(window);
        
        // rendering commands here
        glClearColor(0.2f, 0.3f, 0.3f, 1.0f);
        glClear(GL_COLOR_BUFFER_BIT);
        
        // triangle
        glUseProgram(shaderProgram);
        glBindVertexArray(VAO);
        glDrawArrays(GL_TRIANGLES, 0, 3);
        
        glfwSwapBuffers(window);
        glfwPollEvents();
    }
    
    // clean up all the resources
    glDeleteVertexArrays(1, &VAO);
    glDeleteBuffers(1, &VBO);
    glDeleteProgram(shaderProgram);
    glfwTerminate();
    
    return 0;
}
```
