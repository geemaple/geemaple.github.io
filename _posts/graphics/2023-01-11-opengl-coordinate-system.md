---
layout: post
title: "OpenGL坐标系统"
date: 2023-01-11
categories: Graphics
tags: OpenGL
excerpt: 坐标系
mathjax: true
---

* content
{:toc}

OpenGL需要所有的`Vertex Shader`值输出在`[-1.0, 1.0]`范围中，也就是`标准化设备坐标(Normalized Device Coordinate)`，超出范围将不可见。

通常会自己设定一个坐标的范围，之后再在`Vertex Shader`将这些坐标变换为`标准化设备坐标(Normalized Device Coordinate)`，然后再传递给后续的流水线处理。

将坐标变换为`标准化设备坐标(Normalized Device Coordinate)`，通常有指定的几个步骤:

![坐标转换]({{site.static}}/images/opengl-coordinate-systems.png)

为了将坐标从一个坐标系变换到另一个坐标系，我们需要用到几个变换矩阵，最重要的几个分别是模型(Model)、观察(View)、投影(Projection)三个矩阵。

## 本地空间

本地空间`Local Sapce`即Vertex的初始定义值。根据项目和使用工具的规范不同，输入可能不同

```cpp
    float vertices[] = {
        -0.5f, -0.5f, 0.0f, //left
         0.5f, -0.5f, 0.0f, //right
         0.0f,  0.5f, 0.0f  // top
    };
```

## 世界空间

世界空间`World space`, 也就是你定义的物体应该放在(游戏世界)空间的哪个位置。

`model`矩阵就是贱个物体位移，缩放，旋转之后放在指定的世界空间中。

## 观察空间

`横看成岭侧成峰，远近高低各不同`, OpenGL里有个叫`camera`的对象, 观察空间`View Space`就是将3D世界从某个观察视角来看的结果。

移动视角，相当于移动世界物体，`view`变换矩阵包含着转换信息

## 裁剪空间


`gl_Position`=$V_{clip}=M_{projection}⋅M_{view}⋅M_{model}⋅V_{local}$


`Vertex Shader`需要输出`[-1, 1]`，其余部分被剪裁掉，这也就是裁剪空间(Clip Space)名字的由来

### 正射投影

`Projection`矩阵指定了一个范围的坐标，比如在每个维度上的-1000到1000。投影矩阵接着会将在这个指定的范围内的坐标变换为`标准化设备坐标(Normalized Device Coordinate)`的范围(-1.0, 1.0)。所有在范围外的坐标不会被映射到在-1.0到1.0的范围之间，所以会被裁剪掉。

`平截头体`指一个棱锥被平行于它的底面的一个平面所截后，截面与底面之间的几何形体

![平截头体]({{site.static}}/images/opengl-projection-frustum.png)

`Projection`矩阵定义了一个类似立方体的`平截头箱`(如上图)，它定义了一个裁剪空间，在这空间之外的顶点都会被裁剪掉, 即任何出现在近平面之前或远平面之后的坐标都会被裁剪掉, 空间之内的变换为`标准化设备坐标(Normalized Device Coordinate)`

![正射投影]({{site.static}}/images/opengl-orthographic-projection.png)

```cpp
glm::ortho(0.0f, 800.0f, 0.0f, 600.0f, 0.1f, 100.0f);
```

前四个参数指定了`平截头体`的左右下上坐标，这四个参数定义了近平面和远平面的大小，然后第五和第六个参数则定义了近平面和远平面的距离。

正射投影矩阵直接将坐标映射到2D平面中，即你的屏幕，但实际上一个直接的投影矩阵会产生不真实的结果，因为这个投影没有将透视(Perspective)考虑进去。所以我们需要透视投影矩阵来解决这个问题。

### 透视投影

`透视`也就是近大远小，`vertex`坐标的每个分量都会除以它的`w`分量，距离观察者越远顶点坐标就会越小。这也是w分量非常重要的原因，除了`Transform`之外，它能够帮助我们进行透视投影

$
out=\begin{pmatrix} x/w  \\\ y/w  \\\ z/w  \end{pmatrix}
$

![透视投影]({{site.static}}/images/opengl-perspective-projection.png)

```cpp
glm::mat4 proj = glm::perspective(glm::radians(45.0f), (float)width/(float)height, 0.1f, 100.0f);
```

它的第一个参数定义了fov的值，它表示的是视野(Field of View)，并且设置了观察空间的大小。如果想要一个真实的观察效果，它的值通常设置为45.0f，但想要一个末日风格的结果你可以将其设置一个更大的值。

第二个参数设置了宽高比，由视口的宽除以高所得。

第三和第四个参数设置了平截头体的近和远平面。我们通常设置近距离为0.1f，而远距离设为100.0f。所有在近平面和远平面内且处于平截头体内的顶点都会被渲染。

> 当你把透视矩阵的 near 值设置太大时（如10.0f），OpenGL会将靠近摄像机的坐标（在0.0f和10.0f之间）都裁剪掉，这会导致一个你在游戏中很熟悉的视觉效果：在太过靠近一个物体的时候你的视线会直接穿过去

### 投影对比

当使用正射投影时，每一个`vertex`都会直接映射到裁剪空间中而不经过任何精细的透视除法（它仍然会进行透视除法，只是w分量没有被改变（它保持为1），因此没有起作用）。

因为正射投影没有使用透视，远处的物体不会显得更小，所以产生奇怪的视觉效果。

由于这个原因，正射投影主要用于二维渲染以及一些建筑或工程的程序，在这些场景中我们更希望顶点不会被透视所干扰。

例如`Blender`进行三维建模的软件有时在建模时也会使用正射投影，因为它在各个维度下都更准确地描绘了每个物体。下面你能够看到在Blender里面使用两种投影方式的对比：

![投影对比]({{site.static}}/images/opengl-projection-comparison.png)

## 屏幕空间

OpenGL会将`标准化设备坐标(Normalized Device Coordinate)`变换到由`glViewport`函数所定义的坐标范围内, 也就是屏幕大小

## 3D

创建`model`矩阵(沿着x轴旋转`-55`度, 也就是物品在3D世界该怎么摆放):

```cpp
glm::mat4 model = glm::mat4(1.0f); // indentity matrix
model = glm::rotate(model, glm::radians(-55.0f), glm::vec3(1.0f, 0.0f, 0.0f)); //rotate along x axis
```

创建`view`矩阵(将世界向后移动`-3`，视角放置，移动世界相当于移动了视角): 

```cpp
glm::mat4 view = glm::mat4(1.0f);
// note that we're translating the scene in the reverse direction of where we want to move
view = glm::translate(view, glm::vec3(0.0f, 0.0f, -3.0f)); 
```

创建`projection`: 

```cpp
glm::mat4 projection = glm::perspective(glm::radians(45.0f), 800.0f / 600.0f, 0.1f, 100.0f);
```

## GLSL

### Vertex Shader

定义3个`uniform`变量

```cpp
#version 330 core
layout (location = 0) in vec3 aPos;
layout (location = 1) in vec3 aColor;
layout (location = 2) in vec2 aTexCoord;

out vec3 ourColor;
out vec2 TexCoord;

uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;

void main()
{
    gl_Position = projection * view * model * vec4(aPos, 1.0);
    ourColor = aColor;
    TexCoord = aTexCoord;
}
```

### Fragment Shader

```cpp
#version 330 core
out vec4 FragColor;
  
in vec3 ourColor;
in vec2 TexCoord;

void main()
{
    FragColor = vec4(ourColor, 1.0);
}
```

opengl-right-handed-coordinate-systems.png

## 绘制

绘制一个立方体需要6个面，每个面2个三角形, 每个三角形3个点, 一共36个`vertices`

![右手坐标系]({{site.static}}/images/opengl-right-handed-coordinate-systems.png)

![结果]({{site.static}}/images/opengl-lesson-07-result.png)

## 更多

1. [https://learnopengl.com/Getting-started/Coordinate-Systems](https://learnopengl.com/Getting-started/Coordinate-Systems)
2. [http://www.songho.ca/opengl/gl_projectionmatrix.html](http://www.songho.ca/opengl/gl_projectionmatrix.html)
3. [https://www.youtube.com/watch?v=2YtdGVzDFkw&ab_channel=ClanMacCAD](https://www.youtube.com/watch?v=2YtdGVzDFkw&ab_channel=ClanMacCAD)