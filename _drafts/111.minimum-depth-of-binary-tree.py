#
# @lc app=leetcode id=111 lang=python3
#
# [111] Minimum Depth of Binary Tree
#
# https://leetcode.com/problems/minimum-depth-of-binary-tree/description/
#
# algorithms
# Easy (38.91%)
# Total Accepted:    493.6K
# Total Submissions: 1.3M
# Testcase Example:  '[3,9,20,null,null,15,7]'
#
# Given a binary tree, find its minimum depth.
# 
# The minimum depth is the number of nodes along the shortest path from the
# root node down to the nearest leaf node.
# 
# Note: A leaf is a node with no children.
# 
# 
# Example 1:
# 
# 
# Input: root = [3,9,20,null,null,15,7]
# Output: 2
# 
# 
# Example 2:
# 
# 
# Input: root = [2,null,3,null,4,null,5,null,6]
# Output: 5
# 
# 
# 
# Constraints:
# 
# 
# The number of nodes in the tree is in the range [0, 10^5].
# -1000 <= Node.val <= 1000
# 
# 
#
# Definition for a binary tree node.
# class TreeNode:
#     def __init__(self, val=0, left=None, right=None):
#         self.val = val
#         self.left = left
#         self.right = right
class Solution:
    def minDepth(self, root: TreeNode) -> int:
        if root is None:
            return 0
            
        if root.left is None and root.right is None:
            return 1
            
        # ⚠️注意判断顺序
        if root.right is None:
            return self.minDepth(root.left) + 1
            
        if root.left is None:
            return self.minDepth(root.right) + 1
        
        return min(self.minDepth(root.left), self.minDepth(root.right)) + 1

