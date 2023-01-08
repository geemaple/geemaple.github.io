---
layout: post
title: "OpenGL坐标转换Transform"
date: 2023-01-09
categories: Graphics
tags: OpenGL
excerpt: 高等代数
---

* content
{:toc}

## 向量

向量拥有**数值**和**方向**, 数学表示如下:

$
\vec{v} = \begin{pmatrix} x  \\\ y  \\\ z  \end{pmatrix}
$

### 向量与标量运算

向量与标量加法如下:

$
\begin{pmatrix} 1  \\\ 2  \\\ 3  \end{pmatrix} + x \rightarrow
\begin{pmatrix} 1  \\\ 2  \\\ 3  \end{pmatrix} + \begin{pmatrix} x  \\\ x  \\\ x  \end{pmatrix} =
\begin{pmatrix} 1 + x  \\\ 2 + x  \\\ 3 + x  \end{pmatrix}
$

上面的`+`可以换成减号`-`, 乘号`*`, 除号`÷`

### 向量取反

向量取反后，方向相反，相当于-1数乘向量

$
-\vec{v} = -\begin{pmatrix} x  \\\ y  \\\ z  \end{pmatrix} =
\begin{pmatrix} -x  \\\ -y  \\\ -z  \end{pmatrix}
$

### 向量加法

#### 几何

![三角形法则]({{site.static}}/images/pengl-vectors_addition.png)
)

#### 数学

$
\vec{v} = \begin{pmatrix} 1  \\\ 2  \\\ 3  \end{pmatrix},
\vec{k} = \begin{pmatrix} 4  \\\ 5  \\\ 6  \end{pmatrix} \rightarrow
\vec{v} + \vec{k} = 
\begin{pmatrix} 1 + 4  \\\ 2 + 5  \\\ 3 + 6  \end{pmatrix} =
\begin{pmatrix} 5  \\\ 7  \\\ 9  \end{pmatrix}
$

### 向量减法

#### 几何

向量方向取反之后，在相加

#### 数学

$
\vec{v} = \begin{pmatrix} 1  \\\ 2  \\\ 3  \end{pmatrix},
\vec{k} = \begin{pmatrix} 4  \\\ 5  \\\ 6  \end{pmatrix} \rightarrow
\vec{v} + -\vec{k} = 
\begin{pmatrix} 1 + (-4)  \\\ 2 + (-5)  \\\ 3 + (-6)  \end{pmatrix} =
\begin{pmatrix} -3  \\\ -3  \\\ -3  \end{pmatrix}
$

### 向量长度

将向量起点平移到坐标原点，终点到原点的距离
$
｜\vec{v}｜ = \sqrt{x^2 + y^2}
$

### 单位向量

长度为1的向量

$
n\hat{} = \frac{\vec{v}}{｜\vec{v}｜}
$

### 向量内积(点乘)

#### 几何

点乘的结果表示$\vec{v}$在$\vec{k}$方向上的投影与$｜\vec{k}｜$的乘积

1. $\vec{v}\cdot\vec{k} > 0$则方向基本相同，夹角在0°到90°之间
2. $\vec{v}\cdot\vec{k} = 0$则正交，相互垂直
3. $\vec{v}\cdot\vec{k} < 0$则方向基本相反，夹角在90°到180°之间

$
\vec{v}\cdot\vec{k} = ｜\vec{v}｜ * ｜\vec{k}｜ * \cos\theta
$

#### 数学

$
\begin{pmatrix} A_1 \\\ A_2  \\\ A_3  \end{pmatrix} \cdot 
\begin{pmatrix} B_1  \\\ B_2  \\\ B_3  \end{pmatrix} =
(A_1 * B_1) + (A_2 * B_2) + (A_3 * B_3) = -0.8
$

## 向量外积(叉乘)

外积是3D空间中的定义，两个不平行的向量，可以确定一个平面，外积的方向垂直于这个平面，通过右手法则确定。
如果输入的两个向量也是正交的，那么叉乘之后将会产生3个互相正交的向量

#### 几何

如果以向量$\vec{a}$与$\vec{b}$为边构成一个平行四边形，那么这两个向量外积的模长与这个平行四边形的面积相等。

$\vec{a}\times\vec{b} = ｜\vec{b}｜ * ｜\vec{b}｜ * \sin\theta\vec{n}$

#### 数学

$
\begin{pmatrix} A_1  \\\ A_2  \\\ A_3  \end{pmatrix} \times
\begin{pmatrix} B_1  \\\ B_2  \\\ B_3  \end{pmatrix} =
\begin{pmatrix} A_2\cdot{B_3} - A_3\cdot{B_2}   \\\ A_3\cdot{B_1} - A_1\cdot{B_3}   \\\ A_1\cdot{B_2} - A_2\cdot{B_1}   \end{pmatrix}
$

### 矩阵