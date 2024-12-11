import 'package:flutter/material.dart';
import 'package:tickets/shared/widgets/bar/sidebar_item.dart';
import 'package:tickets/shared/widgets/bar/sidebar_item_widget.dart';

class SidebarMultiLevelItemWidget extends StatefulWidget {
  const SidebarMultiLevelItemWidget({
    required this.onHoverPointer,
    required this.textStyle,
    required this.padding,
    required this.offsetX,
    required this.scale,
    required this.mainLevel,
    required this.subItems,
    required this.extendable,
    required this.disable,
    this.iconColor,
    this.iconSize,
    this.onTapMainLevel,
    this.onHold,
    this.isCollapsed,
    this.isSelected,
    this.minWidth,
    this.parentComponent,
    this.mouseCursor,
  });

  final Widget mainLevel;
  final MouseCursor onHoverPointer;
  final TextStyle textStyle;
  final double offsetX, scale, padding;
  final bool? isCollapsed;
  final bool? isSelected;
  final double? minWidth;
  final List<SidebarItem> subItems;
  final bool extendable;
  final bool? disable;
  final double? iconSize;
  final Color? iconColor;
  final VoidCallback? onTapMainLevel, onHold;
  final bool? parentComponent;
  final bool? mouseCursor;

  @override
  _CollapsibleMultiLevelItemWidgetState createState() =>
      _CollapsibleMultiLevelItemWidgetState();
}

class _CollapsibleMultiLevelItemWidgetState
    extends State<SidebarMultiLevelItemWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool isOpen = false;
  bool? isOpenFirst = true;
  bool selected = true;
  bool _underline = false;
  final GlobalKey _gestureDetectorKey = GlobalKey();
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if(widget.extendable == false){
      if(isOpenFirst != null && selected == true){
        isOpen = false;
        isOpenFirst = null;
        selected = false;
      }else if(isOpenFirst != null && selected == false){
        selected = true;
      }
    }
    return widget.mouseCursor!? MouseRegion(
        onEnter: (event) {
          setState(() {
            _underline = true && widget.onTapMainLevel != null;
          });
        },
        onExit: (event) {
          setState(() {
            _underline = false;
          });
        },
        cursor: widget.onHoverPointer,
        child: body()
    ) : body();

  }
  Widget body(){
    return Column(
      children: [
        GestureDetector(
          key: _gestureDetectorKey,
          onTap: () async {
            if(widget.isCollapsed == true){
              final RenderBox renderBox = _gestureDetectorKey.currentContext!.findRenderObject() as RenderBox;
              final position = renderBox.localToGlobal(Offset.zero);
              final size = renderBox.size;
              var result = await showMenu(
              context: context,
              position: RelativeRect.fromLTRB(position.dx+25,  position.dy+25,  position.dx + size.width, position.dy + size.height),
              items: widget.subItems.map((subItem) {
                return PopupMenuItem<String>(
                  value: subItem.text,
                  child: Text(subItem.text),
                );
              }).toList(),
              );
              if(result != null){
                for(var item in widget.subItems){
                  item.isSelected = false;
                  if(item.text == result){
                    item.isSelected = true;
                    if (widget.onTapMainLevel != null) {
                      widget.onTapMainLevel!();
                    }
                    item.onPressed();
                  }
                }
              }
            }else{

              setState(() {
                if(isOpenFirst == null){
                  isOpen = true;
                  isOpenFirst = true;
                }else{
                  if(isOpenFirst == true){
                    isOpen = true;
                  }else{
                    isOpen = !isOpen;
                  }
                  isOpenFirst = false;
                }
              });
            }
          },
          onLongPress: widget.onHold,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: widget.mainLevel,
              ),
              if (widget.disable != null && widget.disable == false)
                Icon(
                  isOpen ? Icons.expand_less : Icons.expand_more,
                  color: widget.iconColor,
                )
            ],
          ),
        ),
        if (widget.disable != null && widget.disable == false)
          AnimatedSize(
            duration: Duration(milliseconds: 300),
            child: Container(
              height: isOpen ? null : 0,
              child: Column(
                children: widget.subItems.map((subItem) => SidebarItemWidget(
                  isSelected: subItem.isSelected,
                  onHoverPointer: widget.onHoverPointer,
                  padding: widget.padding,
                  offsetX: widget.offsetX,
                  scale: widget.scale,
                  leading: subItem.iconImage != null
                      ? CircleAvatar(radius: widget.iconSize! / 2,
                    backgroundImage: subItem.iconImage, backgroundColor: Colors.transparent,
                  )
                      : (subItem.icon != null ? Icon(subItem.icon, size: widget.iconSize,
                    color: widget.iconColor,)
                      : SizedBox(width: widget.iconSize, height: widget.iconSize,)),
                  iconSize: widget.iconSize,
                  iconColor: widget.iconColor,
                  title: subItem.text,
                  textStyle: widget.textStyle,
                  isCollapsed: widget.isCollapsed,
                  minWidth: widget.minWidth,
                  onTap: () {
                    if (widget.onTapMainLevel != null) {
                      widget.onTapMainLevel!();
                    }
                    for(var item in widget.subItems){
                      item.isSelected = false;
                    }
                    subItem.isSelected = true;
                    subItem.onPressed();
                  },
                  onLongPress: () {
                    if (subItem.onHold != null) {
                      subItem.onHold!();
                    }
                  },
                  subItems: subItem.subItems,
                )).toList(),
              ),
            ),
          ),
      ],
    );
  }
}
