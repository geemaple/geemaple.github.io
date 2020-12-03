#
# @lc app=leetcode id=109 lang=python3
#
# [109] Convert Sorted List to Binary Search Tree
#
# https://leetcode.com/problems/convert-sorted-list-to-binary-search-tree/description/
#
# algorithms
# Medium (49.27%)
# Total Accepted:    269.6K
# Total Submissions: 547.3K
# Testcase Example:  '[-10,-3,0,5,9]'
#
# Given the head of a singly linked list where elements are sorted in ascending
# order, convert it to a height balanced BST.
# 
# For this problem, a height-balanced binary tree is defined as a binary tree
# in which the depth of the two subtrees of every node never differ by more
# than 1.
# 
# 
# Example 1:
# 
# 
# Input: head = [-10,-3,0,5,9]
# Output: [0,-3,9,-10,null,5]
# Explanation: One possible answer is [0,-3,9,-10,null,5], which represents the
# shown height balanced BST.
# 
# 
# Example 2:
# 
# 
# Input: head = []
# Output: []
# 
# 
# Example 3:
# 
# 
# Input: head = [0]
# Output: [0]
# 
# 
# Example 4:
# 
# 
# Input: head = [1,3]
# Output: [3,1]
# 
# 
# 
# Constraints:
# 
# 
# The number of nodes in head is in the range [0, 2 * 10^4].
# -10^5 <= Node.val <= 10^5
# 
# 
#
# Definition for singly-linked list.
# class ListNode:
#     def __init__(self, val=0, next=None):
#         self.val = val
#         self.next = next
# Definition for a binary tree node.
# class TreeNode:
#     def __init__(self, val=0, left=None, right=None):
#         self.val = val
#         self.left = left
#         self.right = right
class Solution:
    def sortedListToBST(self, head: ListNode) -> TreeNode:
        left, cur, right = self.splitLinkedList(head)
        
        root = None
        
        if cur is not None:
            root = TreeNode(cur.val)
            
            if left is not None:
                root.left = self.sortedListToBST(left)
                
            if right is not None:
                root.right = self.sortedListToBST(right)
                
        return root

    def splitLinkedList(self, head: ListNode) -> Tuple[ListNode, ListNode, ListNode]:
    
        if head is None:
            return (None, None, None)
    
        sentryHead = ListNode(0)
        sentryHead.next = head
        
        fast = sentryHead
        slow = sentryHead

        while fast.next is not None and fast.next.next is not None:
            fast = fast.next.next
            slow = slow.next
            
        cur = slow.next
        right = slow.next.next
        slow.next = None
        
        return (sentryHead.next, cur, right)
