---
layout: post
title: "算法 - 分治算法D&C"
categories: Algorithm
tags: D&C
excerpt: "分而治之"
mathjax: true
---

* content
{:toc}

## 分治算法

分治算法主要为"分"和"治"

通过把原问题分为子问题，再将子问题进行处理合并，从而实现对原问题的求解, 归并排序就是典型的分治问题

另外，如果分治和缓存(memoization)结合，消除了重复子问题，就变成了动态规划

### 分治与二叉树

分治算法常用于二叉树中的问题，主要因为树结构天然符合分治的思路：将一个树节点的操作分解为处理左右子树。具体来说，分治算法在二叉树中的应用包括：

#### 1. 树的遍历

* **前序遍历（Preorder Traversal）**：访问根节点，然后递归访问左子树和右子树。
* **中序遍历（Inorder Traversal）**：递归访问左子树，访问根节点，然后递归访问右子树。
* **后序遍历（Postorder Traversal）**：递归访问左子树和右子树，然后访问根节点。

#### 2. 树的操作

* **查找**：在二叉搜索树中查找一个值，递归地在左子树或右子树中继续查找。
* **插入**：在二叉搜索树中插入一个新节点，递归地找到合适的位置并插入。

#### 3. 树的平衡

* **AVL树**：在每次插入或删除操作后，递归地检查树的平衡因子，并进行旋转以保持平衡。
* **红黑树**：类似地，在插入或删除节点时，递归地调整树的颜色和结构以保持红黑树的性质.

#### 4. 树的计算

* **计算树的高度**：递归地计算左子树和右子树的高度，并取较大值加一。
* **计算树的大小**：递归地计算左子树和右子树的节点数，并加一.

#### 5. 树的删除

树的删除，由于删除一个节点需要它的父妾节点，而且还要处理好内存，避免内存泄漏。

使用分治会简单一些

```cpp
/**
 * Definition for a binary tree node.
 * struct TreeNode {
 *     int val;
 *     TreeNode *left;
 *     TreeNode *right;
 *     TreeNode() : val(0), left(nullptr), right(nullptr) {}
 *     TreeNode(int x) : val(x), left(nullptr), right(nullptr) {}
 *     TreeNode(int x, TreeNode *left, TreeNode *right) : val(x), left(left), right(right) {}
 * };
 */
class Solution {
public:
    TreeNode* deleteNode(TreeNode* root, int key) {
        if (!root) {
            return nullptr;
        }

        if (root->val < key) {
            root->right = deleteNode(root->right, key);
        } else if (root->val > key) {
            root->left = deleteNode(root->left, key);
        } else {
            if (!root->left) {
                TreeNode* temp = root->right;
                delete root;
                return temp;
            }

            if (!root->right) {
                TreeNode* temp = root->left;
                delete root;
                return temp;
            }

            TreeNode *rigth_min = root->right;
            while (rigth_min->left) {
                rigth_min = rigth_min->left;
            } 
            root->val = rigth_min->val;
            root->right = deleteNode(root->right, root->val);
        }

        return root;
    }
};
```

### 时间复杂度

#### 主定理

为了更好的计算各种情况的时间复杂度，有下面主定理

假设:

分 = 分成a个，1/b的子问题(a > 0, b > 1)

治 = 需要O(N^d)的时间复杂度(d >= 0)

$  T(n) = aT\left(\frac{n}{b}\right) + f(n^d) $

最终的时间复杂度为：

$ if (d > \log_b a): \hspace{1em} T(N) = O(N^d) $

$ if (d = \log_b a): \hspace{1em} T(N) = O(N^d\log N)$

$ if (d < \log_b a): \hspace{1em} T(N) = O(N^{\log_b a})$

#### 使用举例

```python
# 分 = 2个一半的的子问题, 归并排序
# 治 = 花费O(N)的时间
T(N) = 2T(N/2) + O(N)
     = 2(2T(N/4) + O(N/2)) + O(N) = 4T(N/4) + O(N) + O(N) 
     = 8T(N/8) + 3O(N)
     = T(1) + logN * O(N)
     = N * LogN

a = 2, b = 2, d = 1
```

$ k = \log_2 2 = 1, \hspace{1em} d = k, \hspace{1em} T(N) = O(N\log N) $

```python
# 分 = 一半的的子问题， 二分法
# 治 = 花费O(1)的时间
T(N) = T(N/2) + O(1)
     = (T(N/4) + O(1)) + O(1)
     = ((T(N/8) + O(1)) + O(1)) + O(1)
     ...
     = T(1) + logN * O(1)
     = O(logN)

a = 1, b = 2, d = 0
```

$ k = \log_2 1 = 0, \hspace{1em} d = k, \hspace{1em} T(N) = O(\log N) $

```python
T(N) = 2T(N/2) + O(N^2)
a = 2, b = 2, d = 2
```

$ k = \log_2 2 = 1, \hspace{1em} d > k, \hspace{1em} T(N) = O(N^2) $

```python
T(N) = 4T(N/2) + O(N)

a = 4, b = 2, d = 1
```

$ k = \log_2 4 = 2, \hspace{1em} d < k, \hspace{1em} T(N) = O(N^2) $

```python
T(N) = 3T(N/2) + O(N)

a = 3, b = 2, d = 1
```

$ k = \log_2 3, \hspace{1em} d < k, \hspace{1em} T(N) = O(N^{\log_2 3}) $

--End--