---
layout: post
title: "OpenGL3.1 - 模型工具"
categories: Graphics
tags: C++ OpenGL
excerpt: "模型工具"
mathjax: true
---

* content
{:toc}

我们一直在 OpenGL 中绘制立方体，但在实际项目中，模型通常要复杂得多。由于 OpenGL 只能处理三角形，哪怕是绘制一个球体也相对复杂。

在实际开发中，设计师通常使用 **Blender、3DS Max、Maya** 等建模工具创建模型，并将其导出为文件。

这些 3D 建模工具允许艺术家创建复杂的形状，并通过 **UV 映射（UV-mapping）** 应用纹理。工具会自动生成顶点坐标、法线和纹理坐标，并导出为适用于渲染的模型文件格式。

虽然设计师不需要关心技术细节，但作为开发者，我们需要理解模型导出的技术细节，以便正确加载和渲染它们。

## 模型导入

在实际开发中，我们需要解析导出的模型文件，并提取所有相关信息，以便将其存储为 OpenGL 能够理解的格式。然而，常见的问题是模型文件格式种类繁多，每种格式都有自己的数据组织方式。

例如：

- **Wavefront(.obj)**]：仅包含模型数据，以及少量的材质信息，如颜色和漫反射/镜面反射贴图。它被认为是易于解析的模型格式。
- **Collada（.dae）**：基于 XML 的格式，包含丰富的模型信息，包括灯光、材质、动画、摄像机、完整的场景数据等。

建议至少访问一次 [**Wavefront(.obj)** 的wiki页面](https://en.wikipedia.org/wiki/Wavefront_.obj_file)，了解其数据结构，这有助于建立对模型文件格式的基本认知。

由于不同的模型文件格式之间通常没有统一的结构，如果要导入模型，我们需要为每种格式编写独立的解析器。这无疑会增加开发成本和复杂度。

幸运的是，市面上已经有专门的库可以帮助我们处理这一问题，从而避免手动解析每种格式的麻烦。

### [Assimp](https://github.com/assimp/assimp/blob/master/Build.md)

**Assimp** 支持加载 40 多种 3D 文件格式，并将它们转换为统一且整洁的数据结构

![assimp-structure]({{site.static}}/images/opengl-assimp-structure.png)

Mesh 是渲染的核心, 设计稿里面的每个小的元素都是个Mesh(例如人体模型，有头，四肢，衣服，武器等等)

Mesh包含：

- 顶点位置、法线向量、纹理坐标。
- 面（Faces）：每个面由顶点索引组成，通常是三角形。
- 材质（Material）：控制网格的颜色和纹理。

首先加载模型到Scene对象，从root节点找到所有节点的Mesh，拿到vertex数据，indices和material属性

### 环境配置

```sh
brew install assimp # Mac上我们使用已经变编译好的版本。
open $(brew --prefix)/Cellar/assimp/ #查看安装版本

# 然后在Xcode中"Build Settings"对应的`Header Search Paths`和`Library Search Paths`
# 最后在Xcode中"Build Phases"中加入对应的`.dylib`
```

## Mesh

有了Assimp的统一格式，但是我们要将它的格式转换成OpenGL能理解的。

Mesh是最小的可绘制实体，他至少应该包含Vertext和Texture:

```cpp
struct Vertex {
    glm::vec3 Position;
    glm::vec3 Normal;
    glm::vec2 TexCoords;
};

struct Texture {
    unsigned int id;
    string type; // e.g.  a diffuse or specular texture.
};  

class Mesh {
    public:
        // mesh data
        vector<Vertex>       vertices;
        vector<unsigned int> indices;
        vector<Texture>      textures;

        Mesh(vector<Vertex> vertices, vector<unsigned int> indices, vector<Texture> textures);
        void Draw(Shader &shader);
    private:
        //  render data
        unsigned int VAO, VBO, EBO;
        void setupMesh();
}; 

```

### SetUp

```cpp
// 在C++中，结构体的内存布局是顺序的，变量按定义顺序存储。这使得我们可以将结构体直接转换为OpenGL所需的字节数组格式。
Vertex vertex;
vertex.Position  = glm::vec3(0.2f, 0.4f, 0.6f);
vertex.Normal    = glm::vec3(0.0f, 1.0f, 0.0f);
vertex.TexCoords = glm::vec2(1.0f, 0.0f);
// = [0.2f, 0.4f, 0.6f, 0.0f, 1.0f, 0.0f, 1.0f, 0.0f];

offsetof(Vertex, Normal) // 可以用宏返回对应的偏移， glm::vec3 是 12字节（通常它包含 3 个 float，每个 4 字节），

void setupMesh()
{
    glGenVertexArrays(1, &VAO);
    glGenBuffers(1, &VBO);
    glGenBuffers(1, &EBO);
  
    glBindVertexArray(VAO);
    glBindBuffer(GL_ARRAY_BUFFER, VBO);

    glBufferData(GL_ARRAY_BUFFER, vertices.size() * sizeof(Vertex), &vertices[0], GL_STATIC_DRAW);  

    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, EBO);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, indices.size() * sizeof(unsigned int), 
                 &indices[0], GL_STATIC_DRAW);

    // vertex positions
    glEnableVertexAttribArray(0);
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), (void*)0);
    // vertex normals
    glEnableVertexAttribArray(1);
    glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), (void*)offsetof(Vertex, Normal));
    // vertex texture coords
    glEnableVertexAttribArray(2);
    glVertexAttribPointer(2, 2, GL_FLOAT, GL_FALSE, sizeof(Vertex), (void*)offsetof(Vertex, TexCoords));

    glBindVertexArray(0);
}  
```

### Draw

对于`APP`代码，和`Shader`使用相同的命名，这样便于处理。这里的`Shader`是对应glsl程序

```cpp
uniform sampler2D texture_diffuse1;
uniform sampler2D texture_diffuse2;
uniform sampler2D texture_diffuse3;
uniform sampler2D texture_specular1;
uniform sampler2D texture_specular2;

void Draw(Shader &shader) 
{
    unsigned int diffuseNr = 1;
    unsigned int specularNr = 1;
    for(unsigned int i = 0; i < textures.size(); i++)
    {
        glActiveTexture(GL_TEXTURE0 + i); // activate proper texture unit before binding
        // retrieve texture number (the N in diffuse_textureN)
        string number;
        string name = textures[i].type;
        if(name == "texture_diffuse")
            number = std::to_string(diffuseNr++);
        else if(name == "texture_specular")
            number = std::to_string(specularNr++);

        shader.setInt(("material." + name + number).c_str(), i);
        glBindTexture(GL_TEXTURE_2D, textures[i].id);
    }
    glActiveTexture(GL_TEXTURE0);

    // draw mesh
    glBindVertexArray(VAO);
    glDrawElements(GL_TRIANGLES, indices.size(), GL_UNSIGNED_INT, 0);
    glBindVertexArray(0);
}  
```

## Model

TODO

## 更多

1. [https://learnopengl.com/Model-Loading/Assimp](https://learnopengl.com/Model-Loading/Assimp)
2. [https://learnopengl.com/Model-Loading/Mesh](https://learnopengl.com/Model-Loading/Mesh)
3. [https://learnopengl.com/Model-Loading/Model](https://learnopengl.com/Model-Loading/Model)


