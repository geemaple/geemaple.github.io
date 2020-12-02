#
# @lc app=leetcode id=105 lang=python3
#
# [105] Construct Binary Tree from Preorder and Inorder Traversal
#
# https://leetcode.com/problems/construct-binary-tree-from-preorder-and-inorder-traversal/description/
#
# algorithms
# Medium (50.58%)
# Total Accepted:    424.1K
# Total Submissions: 838.3K
# Testcase Example:  '[3,9,20,15,7]\n[9,3,15,20,7]'
#
# Given preorder and inorder traversal of a tree, construct the binary tree.
# 
# Note:
# You may assume that duplicates do not exist in the tree.
# 
# For example, given
# 
# 
# preorder = [3,9,20,15,7]
# inorder = [9,3,15,20,7]
# 
# Return the following binary tree:
# 
# 
# ⁠   3
# ⁠  / \
# ⁠ 9  20
# ⁠   /  \
# ⁠  15   7
# 
#
# Definition for a binary tree node.
# class TreeNode:
#     def __init__(self, val=0, left=None, right=None):
#         self.val = val
#         self.left = left
#         self.right = right
from typing import List
class Solution:
    def buildTree(self, preorder: List[int], inorder: List[int]) -> TreeNode:
        if len(preorder) == 0:
            return None
        
        val = preorder[0]
        root = TreeNode(val)
        j = inorder.index(val)
        left = set(inorder[:j])
        i = 1
        while i < len(preorder):
            if preorder[i] not in left:
                break
            i += 1
    
        root.left = self.buildTree(preorder[1:i], inorder[:j])
        root.right = self.buildTree(preorder[i:], inorder[j + 1:])
        
        return root
