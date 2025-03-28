---
layout: post
title: "OpenGL2.4 - 多光源"
categories: Graphics
tags: C++ OpenGL
excerpt: "多光源"
mathjax: true
---

* content
{:toc}

## 多光源

这里是总结篇章，基本上全是代码。

我们要混合多光源的使用，包含类似平行光(比如太阳)， 4个点光源 + 手电筒光束

和C/C++语言类似， GLSL也是有**函数**的，这样可以更好的组织我们的代码。 

这里我们定义四种函数，每一种函数处理特定光源对最终颜色分量的影响。

```c
out vec4 FragColor;
  
void main()
{
  // define an output color value
  vec3 output = vec3(0.0);
  // add the directional light's contribution to the output
  output += someFunctionToCalculateDirectionalLight(); 
  // do the same for all point lights
  for(int i = 0; i < nr_of_point_lights; i++) {
      output += someFunctionToCalculatePointLight();
  }
  // and add others lights as well (like spotlights)
  output += someFunctionToCalculateSpotLight();
  
  FragColor = vec4(output, 1.0);
}  
```

### [平行光]({{site.static}}/graphics/opengl-lighting-caster#平行光)

```cpp
struct DirLight {
    vec3 direction;
  
    vec3 ambient;
    vec3 diffuse;
    vec3 specular;
};  
uniform DirLight dirLight; // 用来传递参数


vec3 CalcDirLight(DirLight light, vec3 normal, vec3 viewDir)
{
    vec3 lightDir = normalize(-light.direction); // 从片段到光源的单位方向向量
    // diffuse shading
    float diff = max(dot(normal, lightDir), 0.0); // 计算散射光的强度，反映表面法线与光照方向的关系。
    // specular shading
    vec3 reflectDir = reflect(-lightDir, normal);
    float spec = pow(max(dot(viewDir, reflectDir), 0.0), material.shininess); // 计算镜面反射光的强度，考虑镜面反射的光泽度, 反应反射光与眼睛位置的关系
    // combine results
    vec3 ambient  = light.ambient  * vec3(texture(material.diffuse, TexCoords));
    vec3 diffuse  = light.diffuse  * diff * vec3(texture(material.diffuse, TexCoords));
    vec3 specular = light.specular * spec * vec3(texture(material.specular, TexCoords));
    return (ambient + diffuse + specular);
}  
```

### [点光源]({{site.static}}/graphics/opengl-lighting-caster#点光源)

```cpp
struct PointLight {    
    vec3 position;
    
    float constant;
    float linear;
    float quadratic;  

    vec3 ambient;
    vec3 diffuse;
    vec3 specular;
};  
#define NR_POINT_LIGHTS 4  
uniform PointLight pointLights[NR_POINT_LIGHTS]; // 宏定义


vec3 CalcPointLight(PointLight light, vec3 normal, vec3 fragPos, vec3 viewDir)
{
    vec3 lightDir = normalize(light.position - fragPos);
    // diffuse shading
    float diff = max(dot(normal, lightDir), 0.0);
    // specular shading
    vec3 reflectDir = reflect(-lightDir, normal);
    float spec = pow(max(dot(viewDir, reflectDir), 0.0), material.shininess); // 镜面反射的高光分量，材质光泽度决定反射光的大小
    // attenuation
    float distance    = length(light.position - fragPos);
    float attenuation = 1.0 / (light.constant + light.linear * distance +  // 根据距离计算点光源的衰减
  			     light.quadratic * (distance * distance));    
    // combine results
    vec3 ambient  = light.ambient  * vec3(texture(material.diffuse, TexCoords));
    vec3 diffuse  = light.diffuse  * diff * vec3(texture(material.diffuse, TexCoords));
    vec3 specular = light.specular * spec * vec3(texture(material.specular, TexCoords));
    ambient  *= attenuation;
    diffuse  *= attenuation;
    specular *= attenuation;
    return (ambient + diffuse + specular);
} 
```

### [聚光]({{site.static}}/graphics/opengl-lighting-caster#聚光)

```cpp
struct SpotLight {
    vec3 position;
    vec3 direction;
    float cutOff;
    float outerCutOff;
    
    vec3 ambient;
    vec3 diffuse;
    vec3 specular;
};
uniform SpotLight spotLight;

vec3 CalcSpotLight(SpotLight light, vec3 normal, vec3 fragPos, vec3 viewDir) {
    vec3 lightDir = normalize(light.position - FragPos);
    float theta = dot(lightDir, normalize(-light.direction));   // 计算光线方向与聚光灯方向的夹角（余弦值）
    float epsilon = light.cutOff - light.outerCutOff;  // 计算聚光灯的模糊边界
    float intensity = clamp((theta - light.outerCutOff) / epsilon, 0.0, 1.0);  // 计算光照强度，使用插值模糊边界

    // ambient
    vec3 ambient = light.ambient * vec3(texture(material.diffuse, TexCoords));

    // diffuse
    float diff = max(dot(normal, lightDir), 0.0);
    vec3 diffuse = light.diffuse * diff * vec3(texture(material.diffuse, TexCoords));

    // specular
    vec3 reflectDir = reflect(-lightDir, normal);
    float spec = pow(max(dot(viewDir, reflectDir), 0.0), material.shininess);
    vec3 specular = light.specular * spec * vec3(texture(material.specular, TexCoords));
    
    return ambient + (diffuse + specular) * intensity;
}
```
![结果]({{site.static}}/images/opengl-lesson-16-result.gif)

[代码](https://github.com/geemaple/learning/blob/main/learn_opengl/learn_opengl/lesson/lesson_16_multiple_lights.cpp)


## 更多

1. [https://learnopengl.com/Lighting/Multiple-lights](https://learnopengl.com/Lighting/Multiple-lights)



