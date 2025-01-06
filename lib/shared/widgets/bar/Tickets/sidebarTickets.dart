import 'dart:io';
import 'dart:math' as math show pi;
import 'package:flutter/material.dart';
import 'package:tickets/config/theme/app_theme.dart';
import 'package:tickets/main.dart';
import 'package:tickets/shared/utils/color_palette.dart';
import 'package:tickets/shared/utils/icon_library.dart';
import 'package:tickets/shared/widgets/bar/Tickets/sidebar_item_widget.dart';
import 'package:tickets/shared/widgets/bar/Tickets/sidebarcontainer.dart';
import 'package:tickets/shared/widgets/bar/sidebar_avatar.dart';
import 'package:tickets/shared/widgets/bar/sidebar_group_item.dart';
import 'package:tickets/shared/widgets/bar/sidebar_item.dart';
import 'package:tickets/shared/widgets/bar/sidebar_item_widget.dart';
import 'package:tickets/shared/widgets/bar/sidebarcontainer.dart';

import '../../../../controllers/ConfigControllers/areaController.dart';
import '../../../../models/ConfigModels/area.dart';
import '../../../../pages/Tickets/loadingDialogTickets.dart';
import '../../../../pages/Tickets/ticket_registration_screen.dart';
import '../../../actions/my_show_dialog.dart';
import '../../../utils/texts.dart';


class SideBarTickets extends StatefulWidget {
  SideBarTickets({
    Key? key,
    required this.items, required this.body, this.title = 'Lorem Ipsum',
    this.titleStyle, this.titleBack = false, this.titleBackIcon = Icons.arrow_back,
    this.onHoverPointer = SystemMouseCursors.click, this.textStyle,
    this.toggleTitleStyle, this.toggleTitle = 'Ocultar', this.avatarImg,
    this.height = double.infinity, this.minWidth = 65, this.maxWidth = 200,
    this.borderRadius = 10, this.iconSize = 25, this.customContentPaddingLeft = -1,
    this.toggleButtonIcon = Icons.chevron_right,
    this.backgroundColor = const Color(0xff2B3138),
    this.avatarBackgroundColor = const Color(0xff6A7886),
    this.selectedIconBox = const Color(0xff2F4047),
    this.selectedIconColor = const Color(0xff4AC6EA),
    this.selectedTextColor = const Color(0xffF3F7F7),
    this.unselectedIconColor = const Color(0xff6A7886),
    this.unselectedTextColor = const Color(0xffC0C7D0),
    this.badgeBackgroundColor = const Color(0xffFF6767),
    this.badgeTextColor = const Color(0xffF3F7F7),
    this.duration = const Duration(milliseconds: 500),
    this.curve = Curves.fastLinearToSlowEaseIn,
    this.screenPadding = 0, this.showToggleButton = true, this.topPadding = 10,
    this.bottomPadding = 0, this.itemPadding = 10, this.customItemOffsetX = -1,
    this.fitItemsToBottom = false, this.onTitleTap, this.isCollapsed = true,
    this.collapseOnBodyTap = false, this.showTitle = true, this.sidebarBoxShadow = const [
      BoxShadow(color: Colors.grey, blurRadius: 0, spreadRadius: 0.0, offset: Offset(0, 0),),
    ],
  }) : super(key: key);
  final avatarImg;
  final String title, toggleTitle;
  final MouseCursor onHoverPointer;
  final TextStyle? titleStyle, textStyle, toggleTitleStyle;
  final IconData titleBackIcon;
  final Widget body;
  final bool showToggleButton, fitItemsToBottom, isCollapsed, titleBack, showTitle, collapseOnBodyTap;
  List<SidebarGroupItem> items;
  final double height, minWidth, maxWidth, borderRadius, iconSize, customItemOffsetX,
      padding = 10, itemPadding, topPadding, bottomPadding, screenPadding, customContentPaddingLeft;
  final IconData toggleButtonIcon;
  final Color backgroundColor, avatarBackgroundColor, selectedIconBox, selectedIconColor,
      selectedTextColor, unselectedIconColor, unselectedTextColor, badgeBackgroundColor, badgeTextColor;
  final Duration duration;
  final Curve curve;
  final VoidCallback? onTitleTap;
  final List<BoxShadow> sidebarBoxShadow;

  @override
  _CollapsibleSidebarState createState() => _CollapsibleSidebarState();
}

class _CollapsibleSidebarState extends State<SideBarTickets>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _widthAnimation;
  late CurvedAnimation _curvedAnimation;

  late AnimationController _animationController2;
  late Animation<double> _animation2;
  late double tempWidth;
  late double tempWidth2;
  late ThemeData theme;

  var _isCollapsed;
  late double _currWidth, _delta, _delta1By4, _delta3by4, _maxOffsetX, _maxOffsetY;
  late int _selectedItemIndex;

  @override
  void initState() {
    assert(widget.items.isNotEmpty);

    super.initState();

    tempWidth = widget.maxWidth > 270 ? 270 : widget.maxWidth;
    tempWidth2 = widget.maxWidth > 270 ? 270 : widget.maxWidth;
    _currWidth = widget.minWidth;
    _delta = tempWidth - widget.minWidth;
    _delta1By4 = _delta * 0.25;
    _delta3by4 = _delta * 0.75;
    _maxOffsetX = widget.padding * 2 + widget.iconSize;
    _maxOffsetY = widget.itemPadding * 2 + widget.iconSize;
    _selectedItemIndex = 0;
    for (int i = 0; i < widget.items.length; i++) {
      for (int j= 0; j < widget.items[i].items.length; j++) {
        if (widget.items[i].items[j].isSelected) break;
        _selectedItemIndex += 1;
      }
    }

    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _curvedAnimation = CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    );
    _controller.addListener(() {
      _currWidth = _widthAnimation.value;
      if (_controller.isCompleted) _isCollapsed = _currWidth == widget.minWidth;
      setState(() {});
    });
    _isCollapsed = widget.isCollapsed;
    var endWidth = _isCollapsed ? widget.minWidth : tempWidth;
    _animateTo(endWidth);

    _animationController2 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    )..addListener(() { setState(() { });
    });
    _animation2 = Tween<double>(begin: 0, end: 5)
        .chain(CurveTween(curve: Curves.fastEaseInToSlowEaseOut))
        .animate(_animationController2);
  }

  @override
  void didUpdateWidget(covariant SideBarTickets oldWidget) {
    if (widget.isCollapsed != oldWidget.isCollapsed) {
      _listenCollapseChange();
    }
    super.didUpdateWidget(oldWidget);
  }
  void _listenCollapseChange() {
    _isCollapsed = widget.isCollapsed;
    var endWidth = _isCollapsed ? widget.minWidth : tempWidth;
    _animateTo(endWidth);
  }

  void _animateTo(double endWidth) {
    _widthAnimation = Tween<double>(
      begin: _currWidth,
      end: endWidth,
    ).animate(_curvedAnimation);
    _controller.reset();
    _controller.forward();
  }
  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    if (details.primaryDelta != null) {
      if (Directionality.of(context) == TextDirection.ltr) {
        _currWidth += details.primaryDelta!;
      } else {
        _currWidth -= details.primaryDelta!;
      }
      if (_currWidth > tempWidth)
        _currWidth = tempWidth;
      else if (_currWidth < widget.minWidth)
        _currWidth = widget.minWidth;
      else
        setState(() {});
    }
  }
  void _onHorizontalDragEnd(DragEndDetails _) {
    if (_currWidth == tempWidth)
      setState(() => _isCollapsed = false);
    else if (_currWidth == widget.minWidth)
      setState(() => _isCollapsed = true);
    else {
      var threshold = _isCollapsed ? _delta1By4 : _delta3by4;
      var endWidth = _currWidth - widget.minWidth > threshold
          ? tempWidth
          : widget.minWidth;
      _animateTo(endWidth);
    }
  }
  bool _isPinned = false;
  @override
  Widget build(BuildContext context) {
    theme = Theme.of(context);
    Widget sidebar = Padding(
      padding: EdgeInsets.all(widget.screenPadding),
      child: Platform.isWindows? bodyPc() : bodyMobile(),
    );
    return Row(children: [
      sidebar,
      widget.body
    ],);
  }
  Widget bodyMobile(){
    return GestureDetector(
      onHorizontalDragUpdate: _onHorizontalDragUpdate, onHorizontalDragEnd: _onHorizontalDragEnd,
      child: SideBarContainerTickets(
        height: widget.height, width: _currWidth,
        padding: widget.padding, borderRadius: widget.borderRadius,
        color: widget.backgroundColor, sidebarBoxShadow: widget.sidebarBoxShadow,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            widget.showTitle ? _avatar : const SizedBox(),
            SizedBox(height: widget.topPadding,),
            Expanded(
              child: SingleChildScrollView(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for(int i = 0; i<widget.items.length;i++)...[
                      if(_fraction>0.3)...[
                        const SizedBox(height: 5,),
                        Row(children: [
                          Expanded(child: Opacity(
                              opacity: _fraction,
                              child: Transform.translate(
                                offset: Offset(
                                  Directionality.of(context) == TextDirection.ltr
                                      ? widget.customItemOffsetX-30 >= 0 ? widget.customItemOffsetX-30 : _offsetX-30
                                      : 0, 0,),
                                child:
                                Transform.scale(scale: _fraction,
                                  child: Text(widget.items[i].text, style: const TextStyle(color: Colors.white),),),
                              )
                          ),)
                        ],),
                        const SizedBox(height: 5,)
                      ],
                      Column(children: _items(widget.items[i].items),)
                    ]
                  ],
                ),
              ),
            ),
            SizedBox(height: widget.bottomPadding,),
             Divider(color: widget.unselectedIconColor, indent: 5, endIndent: 5, thickness: 1,),
           _addButton,
        widget.showToggleButton
            ? Divider(color: widget.unselectedIconColor, indent: 5, endIndent: 5, thickness: 1,)
            : const SizedBox(height: 5,),
        widget.showToggleButton ? _toggleButton : SizedBox(height: widget.iconSize,
        ),
          ],
        ),
      ),
    );
  }
  Widget bodyPc(){
    return Padding(
      padding: EdgeInsets.all(widget.screenPadding),
      child: MouseRegion(
        onHover: (event) {
          if (_isCollapsed && !_isPinned) {
            _isCollapsed = false;
            var endWidth = _isCollapsed ? widget.minWidth : tempWidth;
            _animateTo(endWidth);
          }
        },
        onExit: (event) {
          if (!_isCollapsed && !_isPinned) {
            _isCollapsed = true;
            var endWidth = _isCollapsed ? widget.minWidth : tempWidth;
            _animateTo(endWidth);
          }
        },
        child: bodyMobile()
      ),
    );
  }
  Widget get _avatar {
    return SidebarItemWidgetTickets(
      onHoverPointer: widget.onHoverPointer, padding: widget.itemPadding,
      offsetX: widget.customItemOffsetX >= 0 ? widget.customItemOffsetX : _offsetX,
      scale: _fraction, mouseCursor: false,
      leading: widget.titleBack ? Icon(widget.titleBackIcon, size: widget.iconSize,
        color: widget.avatarBackgroundColor,)
          : Transform.scale(scale: _fraction+1.2,
        child: SidebarAvatar(
          backgroundColor: widget.avatarBackgroundColor,
          avatarSize: widget.iconSize,
          name: widget.title,
          avatarImg: widget.avatarImg,
          textStyle: _textStyle(widget.backgroundColor, widget.titleStyle),
        ),),
      title: widget.title,
      textStyle: _textStyle(widget.unselectedTextColor, widget.titleStyle),
      isCollapsed: _isCollapsed,
      minWidth: widget.minWidth,
      onTap: widget.onTitleTap,
    );
  }
  List<Widget> _items (List<SidebarItem> items) {
     return List.generate(items.length, (index) {
        var item = items[index];
        var iconColor = widget.unselectedIconColor;
        var textColor = widget.unselectedTextColor;
        if (item.isSelected) {
          iconColor = widget.selectedIconColor;
          textColor = widget.selectedTextColor;
        }
        return SidebarItemWidgetTickets(
          onHoverPointer: widget.onHoverPointer,
          padding: widget.itemPadding,
          offsetX: widget.customItemOffsetX >= 0 ? widget.customItemOffsetX : _offsetX,
          scale: _fraction,
          leading: item.badgeCount != null && item.badgeCount! > 0
              ? Badge.count(backgroundColor: widget.badgeBackgroundColor,
              textColor: widget.badgeTextColor,
              count: item.badgeCount!,
              child: Icon(item.icon, size: widget.iconSize, color: iconColor,))
              : item.iconImage != null ? CircleAvatar(radius: widget.iconSize / 2,
            backgroundImage: item.iconImage, backgroundColor: Colors.transparent,
          )
              : (item.icon != null ? Icon(item.icon, size: widget.iconSize, color: iconColor,)
              : SizedBox(width: widget.iconSize, height: widget.iconSize,)
          ),
          iconSize: widget.iconSize, iconColor: iconColor,
          title: item.text, textStyle: _textStyle(textColor, widget.textStyle),
          isCollapsed: _isCollapsed, minWidth: widget.minWidth, isSelected: item.isSelected,
          parentComponent: true,
          onTap: () {
            if (item.isSelected) return;
            item.onPressed();
            for(int i = 0; i< widget.items.length; i++){
              for(int j = 0; j< widget.items[i].items.length; j++){
                widget.items[i].items[j].isSelected = false;
              }
            }
            item.isSelected = true;
            //setState(() => _selectedItemIndex = index);
          },
          onLongPress: () {
            if (item.onHold != null) {
              item.onHold!();
            }
          },
          subItems: item.subItems,
        );
    });
  }

  Widget get _toggleButton {
    return Platform.isWindows?Container(
      decoration: BoxDecoration(
        color: _isPinned ? theme.colorScheme.onPrimaryContainer : Colors.transparent, // Cambia el color de fondo cuando está seleccionado
        borderRadius: BorderRadius.circular(8.0), // Añade bordes redondeados
        boxShadow: _isPinned ? [
          BoxShadow(
            color: theme.colorScheme.onPrimaryContainer.withOpacity(0.1),
            offset: const Offset(0, 1), // Cambia la posición de la sombra
          ),
        ] : null,
      ),
      child: SidebarItemWidget(
        onHoverPointer: widget.onHoverPointer,
        padding: widget.itemPadding,
        offsetX: widget.customItemOffsetX >= 0 ? widget.customItemOffsetX : _offsetX,
        scale: _fraction,
        leading: Icon(Icons.push_pin, size: widget.iconSize, color: widget.unselectedIconColor,),
        title: 'Fijar',
        textStyle: _textStyle(widget.unselectedTextColor, widget.toggleTitleStyle),
        isCollapsed: _isCollapsed,
        minWidth: widget.minWidth,
        onTap: () {
          _isPinned = !_isPinned;
          setState(() {

          });
        },
      ),
    ): SidebarItemWidget(
      onHoverPointer: widget.onHoverPointer,
      padding: widget.itemPadding,
      offsetX: widget.customItemOffsetX >= 0 ? widget.customItemOffsetX : _offsetX,
      scale: _fraction,
      leading: Transform.rotate(angle: _currAngle,
        child: Icon(widget.toggleButtonIcon, size: widget.iconSize, color: widget.unselectedIconColor,),
      ),
      title: widget.toggleTitle,
      textStyle: _textStyle(widget.unselectedTextColor, widget.toggleTitleStyle),
      isCollapsed: _isCollapsed,
      minWidth: widget.minWidth,
      onTap: () {
        _isCollapsed = !_isCollapsed;
        var endWidth = _isCollapsed ? widget.minWidth : tempWidth;
        _animateTo(endWidth);
      },
    );
  }

  Widget get _addButton {
    return Platform.isWindows ? Container(
      decoration: BoxDecoration(
        color: ColorPalette.ticketsColor, // Color distintivo para el botón
        borderRadius: BorderRadius.circular(8.0), // Bordes redondeados
      ),
      child: SidebarItemWidget(
        onHoverPointer: widget.onHoverPointer,
        padding: 8.0, // Ajustar el padding a un valor double
        offsetX: widget.customItemOffsetX >= 0 ? widget.customItemOffsetX : _offsetX,
        scale: _fraction,
        leading: Icon(Icons.add, size: widget.iconSize, color: Colors.white), // Icono blanco
        title: 'Agregar Ticket',
        textStyle: _textStyle(Colors.white, widget.toggleTitleStyle?.copyWith(fontSize: 15.0)), // Texto blanco con tamaño de fuente más pequeño
        isCollapsed: _isCollapsed,
        minWidth: widget.minWidth,
        onTap: () {
          addTicket();
        },
      ),
    ) : SidebarItemWidget(
      onHoverPointer: widget.onHoverPointer,
      padding: 8.0, // Ajustar el padding a un valor double
      offsetX: widget.customItemOffsetX >= 0 ? widget.customItemOffsetX : _offsetX,
      scale: _fraction,
      leading: Transform.rotate(angle: _currAngle,
        child: Icon(widget.toggleButtonIcon, size: widget.iconSize, color: widget.unselectedIconColor),
      ),
      title: widget.toggleTitle,
      textStyle: _textStyle(widget.unselectedTextColor, widget.toggleTitleStyle?.copyWith(fontSize: 12.0)), // Texto con tamaño de fuente más pequeño
      isCollapsed: _isCollapsed,
      minWidth: widget.minWidth,
      onTap: () {
        _isCollapsed = !_isCollapsed;
        var endWidth = _isCollapsed ? widget.minWidth : tempWidth;
        _animateTo(endWidth);
      },
    );
  }
  Future<void> addTicket() async {
    final size = MediaQuery.of(context).size; // Define the size variable

    LoadingDialogTickets.showLoadingDialogTickets(context, Texts.loadingData);
    AreaController areaController = AreaController();
    List<AreaModels> listArea = await areaController.getAreasConUsuario();
    LoadingDialogTickets.hideLoadingDialogTickets(context);
    if (size.width < 500) {
      await Navigator.of(context).push(MaterialPageRoute(builder: (context) => ticketRegistrationScreen(areas: listArea)));
    } else {
      await myShowDialogScale(ticketRegistrationScreen(areas: listArea), context, width: 1140, background: ColorPalette.ticketsColor4);
    }
    LoadingDialogTickets.showLoadingDialogTickets(context, Texts.loadingData);
    Future.delayed(const Duration(milliseconds: 400), () {
      LoadingDialogTickets.hideLoadingDialogTickets(context);
    });
  }


  double get _fraction => (_currWidth - widget.minWidth) / _delta;
  double get _currAngle => -math.pi * _fraction;
  double get _offsetX => _maxOffsetX * _fraction;

  TextStyle _textStyle(Color color, TextStyle? style) {
    return style == null ? TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: color,)
        : style.copyWith(color: color);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
