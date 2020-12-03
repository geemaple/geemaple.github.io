#
# @lc app=leetcode id=106 lang=python3
#
# [106] Construct Binary Tree from Inorder and Postorder Traversal
#
# https://leetcode.com/problems/construct-binary-tree-from-inorder-and-postorder-traversal/description/
#
# algorithms
# Medium (48.63%)
# Total Accepted:    266.5K
# Total Submissions: 547.8K
# Testcase Example:  '[9,3,15,20,7]\n[9,15,7,20,3]'
#
# Given inorder and postorder traversal of a tree, construct the binary tree.
# 
# Note:
# You may assume that duplicates do not exist in the tree.
# 
# For example, given
# 
# 
# inorder = [9,3,15,20,7]
# postorder = [9,15,7,20,3]
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
#
# Definition for a binary tree node.
from typing import List
class TreeNode:
    def __init__(self, val=0, left=None, right=None):
        self.val = val
        self.left = left
        self.right = right
class Solution:
    def buildTree(self, inorder: List[int], postorder: List[int]) -> TreeNode:
        if len(postorder) == 0:
            return None

        val = postorder[-1]
        root = TreeNode(val)
        i = inorder.index(val)
        right = set(inorder[i + 1:])
        j = len(postorder) - 2
        while j >= 0:
            if postorder[j] not in right:
                break
            j -= 1
        
        root.right = self.buildTree(inorder[i + 1:], postorder[j + 1: -1])
        root.left = self.buildTree(inorder[:i], postorder[:j + 1])
        
        return root
