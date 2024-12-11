import 'package:flutter/material.dart';
import 'package:animated_tree_view/animated_tree_view.dart';

class TreeNodeData extends TreeNode<Object?> {
  final String title;
  final IconData icon;
  

  TreeNodeData({required this.title, required this.icon}) : super();

  void addChildren(List<TreeNodeData> children) {
    for (var child in children) {
      add(child);
    }
  }
}

class ThreeLevelTreeView extends StatelessWidget {
  final List<TreeNodeData> data;

  const ThreeLevelTreeView({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final root = TreeNodeData(title: 'Root', icon: Icons.folder);
    root.addChildren(data);

    return TreeView.simple(
      tree: root,
      builder: (context, node) {
        final treeNode = node as TreeNodeData;
        return ListTile(
          leading: Icon(treeNode.icon, color: Colors.grey),
          title: Text(treeNode.title),
          contentPadding: EdgeInsets.only(left: node.level * 16.0),
        );
      },
      indentation: const Indentation(
        style: IndentStyle.squareJoint,
        width: 16.0,
      ),
    );
  }
}
