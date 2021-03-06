// https://leetcode.com/problems/binary-tree-inorder-traversal/submissions/
Solution {
public:
    vector<int> inorderTraversal(TreeNode* root) {
        vector<int>ans;
        stack<TreeNode*>st;
        while(!st.empty() || root){
            while(root){
                st.push(root);
                root = root->left;
            }
            root = st.top(); st.pop();
            ans.push_back(root->val);
            root = root->right;
        }
        return ans;
    }
};