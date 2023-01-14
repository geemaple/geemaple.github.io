---
layout: post
title: "OpenGL2.1光影Lighting"
date: 2023-01-14
categories: Graphics
tags: OpenGL
excerpt: 想要彻底摆脱黑暗就努力站在有光的地方
mathjax: true
---

* content
{:toc}

## 颜色

每一种物体都有它自己的颜色，将无限的颜色映射到数字世界中，使用RGB，RGB是设备相关的颜色模型，每一种设备显示颜色会有不同。

```cpp
glm::vec3 coral(1.0f, 0.5f, 0.31f);  
```

物理世界中，我们看到的颜色，并不会物体的颜色，而是物体反色的光的颜色。

![光的反射]({{site.static}}/images/opengl-light-reflection.png)

物理的反色规则在显卡绘制中同样适用，定义`光源`的时候，指定一个颜色。

如果`光源`颜色与`物体`颜色相乘，结果将会反应出`物体`的视觉颜色(也就是物体反色光的颜色)

`物体`颜色的定义就是每一个颜色分量，`物体`能够反射的数值

例如白色`光源`与珊瑚红色`物体`:

```cpp
glm::vec3 lightColor(1.0f, 1.0f, 1.0f);
glm::vec3 toyColor(1.0f, 0.5f, 0.31f);
glm::vec3 result = lightColor * toyColor; // = (1.0f, 0.5f, 0.31f);
```

绿色`光源`与同样物体, 可以看出`物体`吸收了一半的绿光，没有红色蓝色光可以反射,`物体`的视觉颜色也就变成了`暗绿色`

```cpp
glm::vec3 lightColor(0.0f, 1.0f, 0.0f);
glm::vec3 toyColor(1.0f, 0.5f, 0.31f);
glm::vec3 result = lightColor * toyColor; // = (0.0f, 0.5f, 0.0f);
```

橄榄绿`光源`与同样物体

```cpp
glm::vec3 lightColor(0.33f, 0.42f, 0.18f);
glm::vec3 toyColor(1.0f, 0.5f, 0.31f);
glm::vec3 result = lightColor * toyColor; // = (0.33f, 0.21f, 0.06f);
```

由此可以看出，相同的物体，会展示不同的视觉颜色

## GLSL

### Vertex Shader

```cpp
#version 330 core
layout (location = 0) in vec3 aPos;

uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;

void main()
{
    gl_Position = projection * view * model * vec4(aPos, 1.0);
} 
```

### Fragment Shader

```cpp
#version 330 core
out vec4 FragColor;
  
uniform vec3 objectColor;
uniform vec3 lightColor;

void main()
{
    FragColor = vec4(lightColor * objectColor, 1.0);
}
```

## 场景

### 光源

为了方便学习，需要画出光源位置，但是作为光源不希望被上面`反射`代码干扰，所以单独设置光源的`Fragment Shader`代码, `Vertex Shader`没有改动

`Fragment Shader`

```cpp
#version 330 core
out vec4 FragColor;

void main()
{
    FragColor = vec4(1.0);
}
```

![结果]({{site.static}}/images/opengl-lesson-10-result.gif)

[源码](https://github.com/geemaple/learning/blob/main/learn_opengl/learn_opengl/lesson/lesson_10_lighting.cpp)

## 光影模型

物理世界的`光影`非常的复杂，OpenGL使用的`简单的模型来`模拟真实世界。

其中一种模型叫`冯氏光照模型(Phong lighting)`, 主要结构由3个分量组成：环境(Ambient)、漫反射(Diffuse)和镜面(Specular)光照: 

![冯氏光照模型]({{site.static}}/images/opengl-phong-lighting-model.png)

1. 环境(Ambient), 即使在夜晚，也会有一些光亮(比如月亮，星星)。所以，大部分场景物体不完全是漆黑的。`Ambient`常量用来模拟这种效果，用来给物体一些颜色。
2. 漫反射(Diffuse)，用来模拟光源位置对物体的影响，是光模型中最重要的组成部分，物体的某一部分越是正对着光源，它就会越亮。
3. 镜面(Specular), 模拟有光泽物体上面出现的亮点，它更接近光源的颜色。

### 环境光照

光源通常来自物体的各个方向，即使不是直接发光的物体。

光的一个特点是可以反射，根据环境物理特性不同，会导致光线反射的到处都是。

这些反射的光，会对`物体`产生间接的影响。`global illumination`会考虑这些反射。

我们这里采用`global illumination`里的一个非常简单的概念`ambient lighting`。

代码使用`ambientStrength`变量，这样环境就会始终有一些反射光存在

```cpp
void main()
{
    float ambientStrength = 0.1;
    vec3 ambient = ambientStrength * lightColor;

    vec3 result = ambient * objectColor;
    FragColor = vec4(result, 1.0);
}  
```

![结果]({{site.static}}/images/opengl-lesson-11-result-01.gif)

### 漫反射光照


### 镜面光照