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

如下图，物体不是完全漆黑的，这就模拟了环境光照的效果

![结果]({{site.static}}/images/opengl-lesson-11-result-01.gif)

### 漫反射光照

漫反射光会对`物体`颜色有明显的效果，离光源越近，就越亮。

![漫反射光照]({{site.static}}/images/opengl-diffuse-light.png)

图中，左边的光源发射光线到`物体`的一个`Fragment`上。 需要知道光线以什么角度射入的，如果光线是垂直照射的，光线就有最大的影响力(更亮)。

#### 法向量

使用`法向量`(normal vector)来测量这个角度，也就是图中黄色的向量。角度可以用两个单位向量点乘获得。

$\theta$越小，单位向量点乘越接近1， 90度时为0。这与上面描述的漫反射影响效果一致

$
\vec{v}\cdot\vec{k} = ｜\vec{v}｜ * ｜\vec{k}｜ * \cos\theta
$

向量点乘的结果，就反映了光源对`物体`各个`Fragment`影响程度。

`法向量`是垂直`物体`表面的`单位向量`, 因为单个`vertex`并不是平面，只是一个点。我们需要计`物体`体表面的`法向量`，可以通过周围的点组成的平面做向量叉乘获得。

#### 计算漫反射

立方体`法向量`比较简单，直接放入`vertex`中, 然后再将数值传给`Fragment Shader`.

```cpp
float vertices[] = {
    -0.5f, -0.5f, -0.5f,  0.0f,  0.0f, -1.0f,
     0.5f, -0.5f, -0.5f,  0.0f,  0.0f, -1.0f, 
     0.5f,  0.5f, -0.5f,  0.0f,  0.0f, -1.0f, 
     0.5f,  0.5f, -0.5f,  0.0f,  0.0f, -1.0f, 
    -0.5f,  0.5f, -0.5f,  0.0f,  0.0f, -1.0f, 
    -0.5f, -0.5f, -0.5f,  0.0f,  0.0f, -1.0f, 

    ... x5
]
```

定义光源的位置变量`lightPos`, 然后在程序中设施。

```cpp
uniform vec3 lightPos;
```

最后，还需要`Fragment`的位置，光影是在`世界空间`完成的， 可以通过`mode`矩阵转换到世界空间，把结果传给`Fragment Shader`, 传参数时`FragPos`会被做差值处理

```cpp
out vec3 FragPos;  
out vec3 Normal;

void main()
{
    gl_Position = projection * view * model * vec4(aPos, 1.0);
    FragPos = vec3(model * vec4(aPos, 1.0));
    Normal = aNormal;
}
```

`FragPos`是世界的坐标，最后。 三个向量都有了，可以开始计算了

1. 获取法向量
2. 获得射入光线，通过向量差很容易获得，方向由被减数指向减数
3. 通过点乘获取`diff`系数，然后乘以光源得到`diffuse`影响系数
4. 合并`ambient`与`diffuse`在颜色个个分量上的影响系数

```cpp
vec3 norm = normalize(Normal);
vec3 lightDir = normalize(lightPos - FragPos); 
float diff = max(dot(norm, lightDir), 0.0);
vec3 diffuse = diff * lightColor;
```

为了确保大于90的光线不会产生负值，将`diff`与`0`做`max`处理

注意，做光影计算的时候，通常只在乎向量的方向，所以会用`normalize`函数将向量转换成`单位向量`， 这样会简化计算。忘记`normalize`是一个常见的错误

![结果]({{site.static}}/images/opengl-lesson-11-result-02.gif)

看上去怪怪的，主要是没有对`法向量`处理。使得光影停留在初始旋转时候的样子。

#### 法线矩阵

`法向量`需要转换到`世界空间`， 但是直接乘会有问题。

首先，法向量只是一个方向向量，不能表达空间中的特定位置。同时，法向量没有齐次坐标（`vertex`位置中的w分量）。这意味着，位移不应该影响到法向量。因此，如果我们打算把法向量乘以`model`矩阵，我们就要从矩阵中移除位移部分，只选用模型矩阵左上角3×3的矩阵（注意，我们也可以把法向量的w分量设置为0，再乘以4×4矩阵；这同样可以移除位移）。对于法向量，我们只希望对它实施缩放和旋转变换。

其次，如果模型矩阵执行了不等比缩放，顶点的改变会导致法向量不再垂直于表面了。因此，我们不能用这样的`model`矩阵来变换法向量。下面的图展示了应用了不等比缩放的模型矩阵对法向量的影响：

![结果]({{site.static}}/images/opengl-normal-vector-sacling.png)

每当我们应用一个不等比缩放时（注意：等比缩放不会破坏法线，因为法线的方向没被改变，仅仅改变了法线的长度，而这很容易通过标准化来修复），法向量就不会再垂直于对应的表面了，这样光照就会被破坏。

修复这个行为的诀窍是使用一个为法向量专门定制的模型矩阵。这个矩阵称之为法线矩阵(Normal Matrix)

法线矩阵被定义为`model`矩阵左上角3x3部分的逆矩阵的转置.

```cpp
Normal = mat3(transpose(inverse(model))) * aNormal;
```

注意，矩阵求逆是一项对于`shaders`开销很大，因为它必须在场景中的每一个Vertex上进行 最好先在CPU上计算出法线矩阵，再通过uniform把它传值

![结果]({{site.static}}/images/opengl-lesson-11-result-03.gif)

### 镜面光照

//TBD 累了累了 


## 更多

1. [https://learnopengl.com/Lighting/Basic-Lighting](https://learnopengl.com/Lighting/Basic-Lighting)
2. [http://www.lighthouse3d.com/tutorials/glsl-12-tutorial/the-normal-matrix/](http://www.lighthouse3d.com/tutorials/glsl-12-tutorial/the-normal-matrix/)