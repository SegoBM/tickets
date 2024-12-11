import 'package:flutter/material.dart';
import 'package:tickets/shared/widgets/bar/sidebar_item.dart';
import 'package:tickets/shared/widgets/bar/sidebar_multi_level_item_widget.dart';

class SidebarItemWidget extends StatefulWidget {
  const SidebarItemWidget({
    required this.onHoverPointer, required this.leading,
    required this.title, required this.textStyle, required this.padding, required this.offsetX,
    required this.scale, this.isCollapsed, this.isSelected = false, this.minWidth,
    this.onTap, this.subItems, this.onLongPress, this.iconSize, this.iconColor,
    this.parentComponent, this.mouseCursor = true,
  });
  final MouseCursor onHoverPointer;
  final Widget leading;
  final String title;
  final TextStyle textStyle;
  final double offsetX, scale, padding;
  final bool? isCollapsed;
  final bool? isSelected;
  final double? minWidth;
  final VoidCallback? onTap;
  final List<SidebarItem>? subItems;
  final double? iconSize;
  final Color? iconColor;
  final bool? parentComponent;
  final VoidCallback? onLongPress;
  final bool? mouseCursor;

  @override
  _CollapsibleItemWidgetState createState() => _CollapsibleItemWidgetState();
}

class _CollapsibleItemWidgetState extends State<SidebarItemWidget> {
  bool _underline = false;

  @override
  Widget build(BuildContext context) {
    return widget.mouseCursor!? MouseRegion(
        onEnter: (event) {
          setState(() {
            _underline = true && widget.onTap != null;
          });
        },
        onExit: (event) {
          setState(() {
            _underline = false;
          });
        },
        cursor: widget.onHoverPointer,
        child: _body()
    ) : _body();
  }
  Widget _body(){
    return LayoutBuilder(builder: (context, boxConstraints) {
      return widget.subItems == null?
      (widget.isCollapsed!?
      Tooltip(waitDuration: const Duration(milliseconds: 600),
        message: widget.title,child: GestureDetector(
          onTap: (){
            widget.onTap!();
          },
          onLongPress: widget.onLongPress,
          child: Container(
            decoration: BoxDecoration(color: widget.isSelected! ? Theme.of(context).colorScheme.onPrimaryContainer : _underline ?
            Theme.of(context).colorScheme.onSecondaryContainer : Colors.transparent,
                borderRadius: BorderRadius.circular(10)),
            padding: EdgeInsets.all(widget.padding),
            child: Row(
              children: [
                widget.leading,
                _title,
              ],
            ),
          ),
        ),):
      GestureDetector(
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        child: Container(
          decoration: BoxDecoration(color: widget.isSelected! ? Theme.of(context).colorScheme.onPrimaryContainer : _underline ?
          Theme.of(context).colorScheme.onSecondaryContainer : Colors.transparent,
              borderRadius: BorderRadius.circular(10)),
          padding: EdgeInsets.all(widget.padding),
          child: Row(
            children: [
              widget.leading,
              _title,
            ],
          ),
        ),
      ))
          : SidebarMultiLevelItemWidget(
        mouseCursor: widget.mouseCursor,
        onHoverPointer: widget.onHoverPointer,
        textStyle: widget.textStyle,
        offsetX: widget.offsetX,
        isSelected: widget.isSelected,
        scale: widget.scale,
        padding: widget.padding,
        minWidth: widget.minWidth,
        isCollapsed: widget.isCollapsed,
        parentComponent: widget.parentComponent,
        onHold: widget.onLongPress,
        mainLevel: Container(
            decoration: BoxDecoration(color: _underline ? const Color.fromRGBO(100, 100, 100, 0.3) : Colors.transparent,
                borderRadius: BorderRadius.circular(10)),
            padding: EdgeInsets.all(widget.padding),
            child: Row(
              children: [
                Flexible(child: widget.leading),
                _title,
              ],
            )
        ),
        onTapMainLevel: widget.onTap,
        subItems: widget.subItems!,
        extendable: widget.isCollapsed != false || widget.isSelected != false,
        disable: widget.isCollapsed,
        iconColor: widget.iconColor,
        iconSize: widget.iconSize,
      );
    });
  }
  Widget get _title {
    return Expanded(
      child: Opacity(
        opacity: widget.scale,
        child: Transform.translate(
          offset: Offset(
            Directionality.of(context) == TextDirection.ltr
                ? widget.offsetX : 0, 0,
          ),
          child: Transform.scale(
            scale: widget.scale,
            child: Text(
              widget.title,
              style: widget.textStyle,
              softWrap: false,
              overflow: TextOverflow.fade,
            ),
          ),
        ),
      ),
    );
  }
}
