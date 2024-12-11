import 'package:flutter/material.dart';

class SideBarContainer extends StatelessWidget {
  const SideBarContainer(
      {required this.height,
        required this.width,
        required this.padding,
        required this.borderRadius,
        required this.color,
        required this.child,
        required this.sidebarBoxShadow});

  final double height, width, padding, borderRadius;
  final Color color;
  final Widget child;
  final List<BoxShadow> sidebarBoxShadow;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(borderRadius)),
        color: color,
        // boxShadow: sidebarBoxShadow,
      ),
      child: child,
    );
  }
}
