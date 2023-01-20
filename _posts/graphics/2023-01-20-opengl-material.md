---
layout: post
title: "OpenGL2.2光材质Material"
date: 2023-01-20
categories: Graphics
tags: OpenGL
excerpt: ""
mathjax: true
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

### 绘制

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

由于未指定灯光属性，默认是1，所以每个材质属性返回的是满值。通常`ambiant`分量不会这么高，所以需要调整一下。

```cpp
vec3 ambient  = vec3(1.0) * material.ambient;
vec3 diffuse  = vec3(1.0) * (diff * material.diffuse);
vec3 specular = vec3(1.0) * (spec * material.specular); 
```

设置

### 绘制

修改之后，物体变暗了一些

```cpp
glUniform3f(glGetUniformLocation(shaderProgram, "light.position"), 1.2f, 1.0f, 2.0f);
glUniform3fv(glGetUniformLocation(shaderProgram, "light.ambient"), 0.2f, 0.2f, 0.2f);
glUniform3fv(glGetUniformLocation(shaderProgram, "light.diffuse"), 0.5f, 0.5f, 0.5f);
glUniform3f(glGetUniformLocation(shaderProgram, "light.specular"), 1.0f, 1.0f, 1.0f);
```

![结果]({{site.static}}/images/opengl-lesson-12-result-02.gif)

动态改变下灯光颜色的结果:

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