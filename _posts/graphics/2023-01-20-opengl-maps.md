---
layout: post
title: "OpenGL2.2 - 材质贴图Maps"
categories: Graphics
tags: C++ OpenGL
excerpt: "贴图"
---

* content
{:toc}

颜色是物体对光反色，被眼睛看到的结果。

## 材质

真实世界，不同物质反射光的性质千差万别，金属通常比粘土更耀眼，在OpenGL中定义材质如下，分别对应冯氏光照模型对应分量的影响:

```cpp
#version 330 core
struct Material {
    vec3 ambient;
    vec3 diffuse;
    vec3 specular;
    float shininess;
}; 
  
uniform Material material;
```

设置struct uniform值

```cpp
glUniform3f(glGetUniformLocation(shaderProgram, "material.ambient"), 1.0f, 0.5f, 0.31f);
glUniform3f(glGetUniformLocation(shaderProgram, "material.diffuse"), 1.0f, 0.5f, 0.31f);
glUniform3f(glGetUniformLocation(shaderProgram, "material.specular"), 0.5f, 0.5f, 0.5f);
glUniform1f(glGetUniformLocation(shaderProgram, "material.shininess"), 32.0f); // 反光度=32
```

### 数值表

![材质]({{site.static}}/images/opengl-lighting-material.png)

获得每种材质的数值是一个比较难的，通常需要大量实验和经验。[材质数值表](http://devernay.free.fr/cours/opengl/materials.html)

| Name           | Ambient  | Diffuse  | Specular | Shininess |
| -------------- | -------- | -------- | -------- | --------- |
|emerald(绿宝石) | 0.0215 0.1745 0.0215 | 0.07568 0.61424 0.07568 | 0.633 0.727811 0.633 | 0.6 |
|jade(玉) | 0.135 0.2225 0.1575 | 0.54 0.89 0.63 | 0.316228 0.316228 0.316228 | 0.1 |
|obsidian(黑曜石) | 0.05375 0.05 0.06625 | 0.18275 0.17 0.22525 | 0.332741 0.328634 0.346435 | 0.3 | 
|pearl(珍珠) | 0.25 0.20725 0.20725 | 1 0.829 0.829 | 0.296648 0.296648 0.296648 | 0.088 |
|ruby(红宝石) | 0.1745 0.01175 0.01175 | 0.61424 0.04136 0.04136 | 0.727811 0.626959 0.626959 | 0.6 |
|turquoise(蓝宝石) | 0.1 0.18725 0.1745 | 0.396 0.74151 0.69102 | 0.297254 0.30829 0.306678 | 0.1 |
|brass(黄铜) | 0.329412 0.223529 0.027451 | 0.780392 0.568627 0.113725 | 0.992157 0.941176 0.807843 | 0.21794872 |
|bronze(青铜) | 0.2125 0.1275 0.054 | 0.714 0.4284 0.18144 | 0.393548 0.271906 0.166721 | 0.2 |
|chrome(铬) | 0.25 0.25 0.25 0.4 | 0.4 0.4 0.774597 | 0.774597 0.774597 | 0.6 |
|copper(铜) | 0.19125 0.0735 0.0225 | 0.7038 0.27048 0.0828 | 0.256777 0.137622 0.086014 | 0.1 |
|gold(金) | 0.24725 0.1995 0.0745 | 0.75164 0.60648 0.22648 | 0.628281 0.555802 0.366065 | 0.4 |
|silver(银) | 0.19225 0.19225 0.19225 | 0.50754 0.50754 0.50754 | 0.508273 0.508273 0.508273 | 0.4 |
|black plastic(塑料) | 0.0 0.0 0.0 | 0.01 0.01 0.01 | 0.50 0.50 0.50 | .25 |
|cyan plastic | 0.0 0.1 0.06 | 0.0 0.50980392 0.50980392 | 0.50196078 0.50196078 0.50196078 | .25 |
|green plastic | 0.0 0.0 0.0 | 0.1 0.35 0.1 | 0.45 0.55 0.45 | .25 |
|red plastic | 0.0 0.0 0.0 | 0.5 0.0 0.0 | 0.7 0.6 0.6 | .25 |
|white plastic | 0.0 0.0 0.0 | 0.55 0.55 0.55 | 0.70 0.70 0.70 | .25 |
|yellow plastic | 0.0 0.0 0.0 | 0.5 0.5 0.0 | 0.60 0.60 0.50 | .25 |
|black rubber(橡胶) | 0.02 0.02 0.02 | 0.01 0.01 0.01 | 0.4 0.4 0.4 | .078125 |
|cyan rubber | 0.0 0.05 0.05 | 0.4 0.5 0.5 | 0.04 0.7 0.7 | .078125 |
|green rubber | 0.0 0.05 0.0 | 0.4 0.5 0.4 | 0.04 0.7 0.04 | .078125 |
|red rubber | 0.05 0.0 0.0 | 0.5 0.4 0.4 | 0.7 0.04 0.04 | .078125 |
|white rubber | 0.05 0.05 0.05 | 0.5 0.5 0.5 | 0.7 0.7 0.7 | .078125 |
|yellow rubber | 0.05 0.05 0.0 | 0.5 0.5 0.4 | 0.7 0.7 0.04 | .078125 |

注意，该表并未考虑下文提到的光属性, 所以光属性应该全部为1

![结果]({{site.static}}/images/opengl-lesson-12-result-01.gif)

## 光属性

一切看起来还不错，就是太亮了，不同的灯光也有不同的属性值，定义如下：

```cpp
struct Light {
    vec3 position;
  
    vec3 ambient;  // 上一节 ambientStrength=0.1
    vec3 diffuse;  // 为设置， 默认1
    vec3 specular;  // specularStrength=0.5
};
```

由于未指定灯光属性，默认是`1.0`，所以每个材质属性返回的是满值。通常`ambiant`分量不会这么高，所以需要调整一下。

```cpp
vec3 ambient  = vec3(1.0) * material.ambient;
vec3 diffuse  = vec3(1.0) * (diff * material.diffuse);
vec3 specular = vec3(1.0) * (spec * material.specular); 
```

修改之后，物体变暗了一些

```cpp
glUniform3f(glGetUniformLocation(shaderProgram, "light.position"), 1.2f, 1.0f, 2.0f);
glUniform3f(glGetUniformLocation(shaderProgram, "light.ambient"), 0.2f, 0.2f, 0.2f);
glUniform3f(glGetUniformLocation(shaderProgram, "light.diffuse"), 0.5f, 0.5f, 0.5f);
glUniform3f(glGetUniformLocation(shaderProgram, "light.specular"), 1.0f, 1.0f, 1.0f);
```

![结果]({{site.static}}/images/opengl-lesson-12-result-02.gif)

动态灯光颜色的结果:

```cpp
glm::vec3 lightColor;
lightColor.x = sin(glfwGetTime() * 2.0f);
lightColor.y = sin(glfwGetTime() * 0.7f);
lightColor.z = sin(glfwGetTime() * 1.3f);

glm::vec3 diffuseColor = lightColor   * glm::vec3(0.5f);
glm::vec3 ambientColor = diffuseColor * glm::vec3(0.2f);

glUniform3f(glGetUniformLocation(shaderProgram, "light.position"), 1.2f, 1.0f, 2.0f);
glUniform3fv(glGetUniformLocation(shaderProgram, "light.ambient"), 1, glm::value_ptr(ambientColor));
glUniform3fv(glGetUniformLocation(shaderProgram, "light.diffuse"), 1, glm::value_ptr(diffuseColor));
glUniform3f(glGetUniformLocation(shaderProgram, "light.specular"), 1.0f, 1.0f, 1.0f);
```

![结果]({{site.static}}/images/opengl-lesson-12-result-03.gif)

[源码](https://github.com/geemaple/learning/blob/main/learn_opengl/learn_opengl/lesson/lesson_12_material.cpp)

## 贴图

有了材质属性，讨论了不同材质对光的反射能力，但它只适用于简单的物体。

对于复杂的物体，比如一辆车，有不同的组成部分，如果继续用材质一个个设置，显然不是特别高效。

### 漫反射贴图

![漫反射贴图]({{site.static}}/images/opengl-maps-diffuse.png)

在光照场景中，对于漫反射贴图`diffuse maps`, 我们希望对于不同的坐标，能够返回不同的漫反射`diffuse`值。 听起来和`纹理`差不多。

虽然与`纹理`原理一致，但是我们使用不同的命名`贴图`，用一张图片包裹物体，这样便能够在不同的位置获取`fragment`颜色值。它是一个表现了物体所有的`漫反射颜色分量`的贴图。

与`纹理`使用方法一致，在材质中定义`sampler2D`如下:

```cpp
// sampler2D是一个抽象类型，只能定义成uniform, 如果struct中包含sampler2D，整个struct也只能定义成uniform
struct Material {
    sampler2D diffuse;
    vec3      specular;
    float     shininess;
};
in vec2 TexCoords;
```

由于`ambiant`和`diffuse`应该是一致的，所以`ambiant`也省略。但如果不一致，可以单独设置。

```cpp
vec3 ambient = light.ambient * vec3(texture(material.diffuse, TexCoords));
...
vec3 diffuse = light.diffuse * diff * vec3(texture(material.diffuse, TexCoords));  
```

接下来需要更改`vetex`，添加纹理值，加载纹理

```cpp
float vertices[] = {
    // positions          // normals           // texture coords
    -0.5f, -0.5f, -0.5f,  0.0f,  0.0f, -1.0f,  0.0f, 0.0f,
     0.5f, -0.5f, -0.5f,  0.0f,  0.0f, -1.0f,  1.0f, 0.0f,
     0.5f,  0.5f, -0.5f,  0.0f,  0.0f, -1.0f,  1.0f, 1.0f,
     0.5f,  0.5f, -0.5f,  0.0f,  0.0f, -1.0f,  1.0f, 1.0f,
    -0.5f,  0.5f, -0.5f,  0.0f,  0.0f, -1.0f,  0.0f, 1.0f,
    -0.5f, -0.5f, -0.5f,  0.0f,  0.0f, -1.0f,  0.0f, 0.0f,
    
    ...x6
};

...
glVertexAttribPointer(2, 2, GL_FLOAT, GL_FALSE, 8 * sizeof(float), (void*)(6 * sizeof(float)));
glEnableVertexAttribArray(2);
```

绘制结果

![结果]({{site.static}}/images/opengl-lesson-13-result-01.gif)

### 镜面光贴图

![镜面光贴图]({{site.static}}/images/opengl-maps-specular.png)

`镜面光贴图`与上面不大一样，主要是因为木头基本不反光，只有周围的金属条反光。

我们需要一个黑白的(如果你想得话也可以是彩色的)贴图，来定义物体每部分的`镜面光强度`。

`黑色=0, 灰色=0.5, 白色=1`，然后用这个强度来设置`镜面光`强度。

> 使用Photoshop或Gimp之类的工具，将漫反射纹理转换为镜面光纹理还是比较容易的，只需要剪切掉中间部分，将图像转换为黑白的，并增加亮度/对比度就好了。

从新定义`材质`如下：
```cpp
struct Material {
    sampler2D diffuse;
    sampler2D specular;
    float     shininess;
}; 
```

将对应的`specular`部分改成使用`贴图`

```cpp
vec3 ambient  = light.ambient  * vec3(texture(material.diffuse, TexCoords));
vec3 diffuse  = light.diffuse  * diff * vec3(texture(material.diffuse, TexCoords));  
vec3 specular = light.specular * spec * vec3(texture(material.specular, TexCoords));
FragColor = vec4(ambient + diffuse + specular, 1.0);   
```

![结果]({{site.static}}/images/opengl-lesson-13-result-02.gif)

可以给`镜面光贴图`设置颜色，这样不仅有`镜面光强度`还有`镜面光颜色`， 但从现实角度来说，镜面光大部分(甚至全部)都来自于光源，所以设置颜色会有不真实的效果，这也是为什么贴图通常是黑白的

![结果]({{site.static}}/images/opengl-lesson-13-result-03.gif)

### 放射光贴图

放射光贴图，通常是游戏里面的效果，物体本身会发光，就可以忽略光源的影响

![结果]({{site.static}}/images/opengl-lesson-13-result-04.gif)

[源码](https://github.com/geemaple/learning/blob/main/learn_opengl/learn_opengl/lesson/lesson_13_maps.cpp)

## 更多

1. [https://learnopengl.com/Lighting/Materials](https://learnopengl.com/Lighting/Materials)
2. [https://learnopengl.com/Lighting/Lighting-maps](https://learnopengl.com/Lighting/Lighting-maps)