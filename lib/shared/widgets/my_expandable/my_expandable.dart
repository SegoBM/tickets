import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';


class MyExpandable extends StatelessWidget {
  final Widget header;
  final Widget? collapse;
  final Widget expanded;
  final ExpandableThemeData? theme;
  final Color? backgroundColor;
  final double? borderRadius;
  final BoxBorder? boxBorder;
  final bool? isExpanded;

  const MyExpandable({
    super.key,
    required this.header,
    required this.expanded,
    this.collapse,
    this.theme,
    this.backgroundColor,
    this.borderRadius,
    this.boxBorder,
    this.isExpanded
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            color:  backgroundColor,
            borderRadius: BorderRadius.circular(borderRadius?? 15),
            border: boxBorder
        ),
        child: ExpandableNotifier(
          initialExpanded: isExpanded,
          child: ExpandablePanel(
              theme: theme,
              header: header,
              collapsed: collapse?? Container(),
              expanded: expanded
          ),
        )
    );
  }
}
