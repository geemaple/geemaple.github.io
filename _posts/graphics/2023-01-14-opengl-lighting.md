---
layout: post
title: "OpenGL2.1光Lighting"
date: 2023-01-12
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

## 光源

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

## 灯光场景

![结果]({{site.static}}/images/opengl-lesson-10-result.gif)

[源码](https://github.com/geemaple/learning/blob/main/learn_opengl/learn_opengl/lesson/lesson_10_lighting.cpp)

// TBD