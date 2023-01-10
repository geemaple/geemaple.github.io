---
layout: post
title: "OpenGL相机"
date: 2023-01-12
categories: Graphics
tags: OpenGL
excerpt: 坐标系
mathjax: true
---

* content
{:toc}

OpenGL本身没有`Camera`定义，但是可以通过移动世界，给一个我们自己在动的错觉

## 观察空间

`观察空间(View Space)`也叫`Camera Space`或者`Eye Space`

也就是从相机的视角，观察`世界空间`的样子。定义相机，我们需要它在`世界空间`中的位置、观察的方向、一个指向它右侧的向量以及一个指向它上方的向量。也就是以相机**位置**为**原点**的一个坐标系。

![相机坐标系]({{site.static}}/images/opengl-camera-coordinate.png)

### 相机位置

如图，在`世界空间`定义相机的位置如下:

```cpp
glm::vec3 cameraPos = glm::vec3(0.0f, 0.0f, 2.0f);  
```

### 相机方向Z

尽管相机指向`z`的负方向，但是作为`View Space`我们希望坐标轴指向为正

让相机指向`世界空间`原点，根据向量相减的几何意义，得到一新的向量，新的向量由`target`坐标指向`pos`坐标，也就是我们想要的z的方向。

```cpp
glm::vec3 cameraTarget = glm::vec3(0.0f, 0.0f, 0.0f);
glm::vec3 cameraDirection = glm::normalize(cameraPos - cameraTarget);
```

### 相机右轴X

首先在`世界空间`定义个向上的`单位向量`， 然后将该向量与`相机方向`做`叉乘`, 会得到一个垂直于`单位向量`和`相机方向`的新向量，根据右手定则，新的向量即使我们想要的`View Space`的x轴

```cpp
glm::vec3 up = glm::vec3(0.0f, 1.0f, 0.0f); 
glm::vec3 cameraRight = glm::normalize(glm::cross(up, cameraDirection));
```

有了`x`轴和`z`轴, 那么`z`轴于`x`轴，就是我们想要的`y`轴

### 相机上轴Y
```cpp
glm::vec3 cameraUp = glm::cross(cameraDirection, cameraRight);
```

### 相机注视

矩阵的好处是，如果有一个3个两两垂直(或非线性)的轴定义一个坐标空间，可以用这三个轴外加一个平移向量来创建一个矩阵。并且用这个矩阵乘以任何向量，将其转换空间。

$
LookAt = \begin{bmatrix} \color{red}{R_x} & \color{red}{R_y} & \color{red}{R_z} & 0 \\\ \color{green}{U_x} & \color{green}{U_y} & \color{green}{U_z} & 0 \\\ \color{blue}{D_x} & \color{blue}{D_y} & \color{blue}{D_z} & 0 \\\ 0 & 0 & 0  & 1 \end{bmatrix} \cdot \begin{bmatrix} 1 & 0 & 0 & -\color{purple}{P_x} \\\ 0 & 1 & 0 & -\color{purple}{P_y} \\\ 0 & 0 & 1 & -\color{purple}{P_z} \\\ 0 & 0 & 0  & 1 \end{bmatrix}
$

`R`为相机右轴，`U`为相机上轴, `D`为相机方向， `P`位相机位置。注意

GLM已经做了这项任务，我们只需要传入相机坐标`P`， `Target`坐标, `世界空间`的向上坐标

```cpp
glm::mat4 view;
view = glm::lookAt(glm::vec3(0.0f, 0.0f, 2.0f), 
                   glm::vec3(0.0f, 0.0f, 0.0f), 
                   glm::vec3(0.0f, 1.0f, 0.0f));
```

## 移动相机

![三角学]({{site.static}}/images/opengl-trigonometry.png)

用三角学创建一个圆圈，让相机的位置圆圈上旋转，始终看向`世界空间`的原点

```cpp
const float radius = 10.0f;
float camX = sin(glfwGetTime()) * radius;
float camZ = cos(glfwGetTime()) * radius;
glm::mat4 view;
view = glm::lookAt(glm::vec3(camX, 0.0, camZ), glm::vec3(0.0, 0.0, 0.0), glm::vec3(0.0, 1.0, 0.0));
```

[结果]({{site.static}}/images/opengl-lesson-08-result.mp4)


## 更多

1. [https://en.wikipedia.org/wiki/Gram%E2%80%93Schmidt_process](https://en.wikipedia.org/wiki/Gram%E2%80%93Schmidt_process)