# Definition for a binary tree node.
# class TreeNode(object):
#     def __init__(self, x):
#         self.val = x
#         self.left = None
#         self.right = None

class Solution(object):

    def findTilt(self, root):
        """
        :type root: TreeNode
        :rtype: int
        """
        if root == None:
            return 0
        else:
           l_val = 0 if root.left == None else root.left.val
           r_val = 0 if root.right == None else root.right.val
           count = abs(self.findTilt(root.left) - self.findTilt(root.right)) + abs(l_val - r_val)
           print count
           return count
