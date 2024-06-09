---
layout: post
title: "OpenGL1.5 - 纹理Texture"
categories: Graphics
tags: C++
excerpt: 纹理
---

* content
{:toc}

## Texture

纹理(Texture)是一张图片，同时纹理也能作为Shader的输入参数

将纹理贴在图形上，我们需要指定纹理坐标(texture coordinate)，纹理坐标指定图片的颜色采样(sampling)位置

纹理坐标如下:

![纹理坐标]({{site.static}}/images/opengl-texture-coordinate.png)

```cpp
float texCoords[] = {
    0.0f, 0.0f,  // lower-left corner  
    1.0f, 0.0f,  // lower-right corner
    0.5f, 1.0f   // top-center corner
};
```

## Texture Wrapping

当纹理坐标超过[0, 1]范围时，默认OpenGL会重复纹理图片，其他选项如下：

![纹理坐标]({{site.static}}/images/opengl-texture-wrapping.png)

```cpp
// s = x, t = y
glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_MIRRORED_REPEAT);
glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_MIRRORED_REPEAT)
```

如果设置```GL_CLAMP_TO_BORDER```需要指定一个颜色

```cpp
float borderColor[] = { 1.0f, 1.0f, 0.0f, 1.0f };
glTexParameterfv(GL_TEXTURE_2D, GL_TEXTURE_BORDER_COLOR, borderColor); 
```

## Texture Filtering

纹理坐标可以是任意数值[0.0 - 1.0], 但提供的纹理图片是有大小的，所以要设置OpenGL该使用哪个纹理像素(texel)

最常用的选项是`GL_NEAREST`和`GL_LINEAR`

![Texture Filtering]({{site.static}}/images/opengl-texture-filtering.png)

### GL_NEAREST

`GL_NEAREST`使用坐标最近的邻居texel, 哪个texel的中心最接近纹理坐标就用那个

![GL_NEAREST]({{site.static}}/images/opengl-texture-filter-nearest.png)

### GL_LINEAR

`GL_LINEAR`使用插值结果，哪个texel中心里坐标越近，对最终差值结果贡献值越高

![GL_LINEAR]({{site.static}}/images/opengl-texture-filter-linear.png)

### 放大缩小

指定放大时使用`GL_NEAREST`, 缩小是使用`GL_NEAREST`

```cpp
glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
```

## Texture Mipmaps

![Mipmaps]({{site.static}}/images/opengl-texture-mipmaps.png)

Mipmaps是一组纹理图片，每一张长宽都比前一张缩小1/2

假如一个3D场景有很多带纹理的对象，那么远处的对象最终绘制会很小一部分，绘制纹理时，相当于现将纹理图片放大缩小之后，在贴到对象上，有了`Mipmaps`之后，OpenGL可以选择合适大小的纹理，采样时可以节省空间

在`Mipmaps`切换纹理时，也会出现失真的效果，可以使用Filtering

### Filtering

```cpp
GL_NEAREST_MIPMAP_NEAREST
GL_LINEAR_MIPMAP_NEAREST
GL_NEAREST_MIPMAP_LINEAR
GL_LINEAR_MIPMAP_LINEAR
```

一个常见的错误是，放大时设置`Mipmaps Filtering`, 因为`Mipmaps`只有在缩小的时候才使用

```cpp
glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
```

## 加载图片

这里使用[stb_image](https://github.com/nothings/stb)加载图片

`glTexImage2D`函数:

1. 第二个参数指定生成多少level的`Mipmaps`, 后续通过`glGenerateMipmap`函数生成
2. 第三个参数指定`Texture`存储类型
3. 倒数第三个为源图片`结构(format)`
4. 倒数第二个为源图片`数据类型(datatype)`

```cpp
#define STB_IMAGE_IMPLEMENTATION
#include "stb_image.h"

int width, height, nrChannels;
unsigned char *data = stbi_load("container.jpg", &width, &height, &nrChannels, 0); 

GLuint texture;
glGenTextures(1, &texture);
glBindTexture(GL_TEXTURE_2D, texture);

glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, width, height, 0, GL_RGB, GL_UNSIGNED_BYTE, data);
glGenerateMipmap(GL_TEXTURE_2D);

stbi_image_free(data);
```

## Texture Units

Texture也使用一个下标叫做`texture unit`, 0是默认值, 在`bind`之前先要激活对应的`texture unit`, 取直范围`[GL_TEXTURE0, GL_TEXTURE15]`.

只有一个`GL_TEXTURE0`的话，可以不用激活，不用设置`glUniformXY`
```cpp
// GL_TEXTURE8 = GL_TEXTURE0 + 8 
glActiveTexture(GL_TEXTURE0); // activate the texture unit first before binding texture
glBindTexture(GL_TEXTURE_2D, texture);
```

OpenGL有一个内置数据对象叫做`samplerXD`, X代表纬度取值范围`[1 - 3]`, 设置`glUniformXY`

```cpp
glUseProgram(shaderProgram);
glUniform1i(glGetUniformLocation(shaderProgram, "texture1"), 0);
glUniform1i(glGetUniformLocation(shaderProgram, "texture2"), 1);
```


## GLSL

### Vertex Shader

两个输出变量，作为`Fragment Shader`的输入

```cpp
#version 330 core
layout (location = 0) in vec3 aPos;
layout (location = 1) in vec3 aColor;
layout (location = 2) in vec2 aTexCoord;

out vec3 ourColor;
out vec2 TexCoord;

void main()
{
    gl_Position = vec4(aPos, 1.0);
    ourColor = aColor;
    TexCoord = aTexCoord;
}
```

### Fragment Shader

`texture`函数根据纹理图片和坐标获取对应颜色

```cpp
#version 330 core
out vec4 FragColor;
  
in vec3 ourColor;
in vec2 TexCoord;

uniform sampler2D texture1;
uniform sampler2D texture2;

void main()
{
//    FragColor = texture(texture1, TexCoord);
//    FragColor = texture(texture2, TexCoord);
//    FragColor = mix(texture(texture1, TexCoord), texture(texture2, TexCoord), 0.5)
    FragColor = mix(texture(texture1, TexCoord), texture(texture2, TexCoord), 0.5) * vec4(ourColor, 1.0);
}

```

## 绘制

```
                            (0, 0)
|                            |---------------------
|                            |
|                            |       
|        OpenGL              |       Image
|                            |
| ----------------------     |
(0,0)
```

由于OpenGL和图片坐标系`(0, 0)`的位置不同，所以纹理是上下颠倒的, 可以将图片上下翻转下，在传递给OpenGL

```cpp
stbi_set_flip_vertically_on_load(true);
```

![结果]({{site.static}}/images/opengl-lesson-05-result.png)

[源码](https://github.com/geemaple/learning/blob/main/learn_opengl/learn_opengl/lesson/lesson_05_texture.cpp)

## 更多

1. [https://learnopengl.com/Getting-started/Textures](https://learnopengl.com/Getting-started/Textures)