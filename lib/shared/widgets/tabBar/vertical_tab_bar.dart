import 'package:flutter/material.dart';
import 'package:tickets/shared/widgets/tabBar/tab_item.dart';

enum IndicatorSide { start, end }

class VerticalTabs extends StatefulWidget {
  final int initialIndex;
  final double tabsWidth;
  final double indicatorWidth;
  final IndicatorSide indicatorSide;
  final List<TabItem> tabs;
  final List<Widget> contents;
  final TextDirection direction;
  final Color indicatorColor;
  final bool disabledChangePageFromContentView;
  final Axis contentScrollAxis;
  final Color selectedTabBackgroundColor;
  final Color tabBackgroundColor;
  final TextStyle selectedTabTextStyle;
  final TextStyle unSelectedTabTextStyle;
  // final TextStyle tabTextStyle;
  final Duration changePageDuration;
  final Curve changePageCurve;
  final Color tabsShadowColor;
  final double tabsElevation;
  final Function(int tabIndex)? onSelect;
  final Color? backgroundColor;

  const VerticalTabs(
      {Key? key,
        required this.tabs,
        required this.contents,
        this.tabsWidth = 200,
        this.indicatorWidth = 3,
        this.indicatorSide = IndicatorSide.end,
        this.initialIndex = 0,
        this.direction = TextDirection.ltr,
        this.indicatorColor = Colors.green,
        this.disabledChangePageFromContentView = false,
        this.contentScrollAxis = Axis.vertical,
        this.selectedTabBackgroundColor = const Color(0x1100ff00),
        this.tabBackgroundColor = const Color(0xfff8f8f8),
        this.selectedTabTextStyle = const TextStyle(color: Colors.red),
        this.unSelectedTabTextStyle = const TextStyle(color: Colors.black),

        // this.tabTextStyle = const TextStyle(color: Colors.black38),
        this.changePageCurve = Curves.easeInOut,
        this.changePageDuration = const Duration(milliseconds: 300),
        this.tabsShadowColor = Colors.black54,
        this.tabsElevation = 2.0,
        this.onSelect,
        this.backgroundColor})
      : assert(tabs.length == contents.length),
        super(key: key);

  @override
  _VerticalTabsState createState() => _VerticalTabsState();
}

class _VerticalTabsState extends State<VerticalTabs>
    with TickerProviderStateMixin {
  late int _selectedIndex;
  bool? _changePageByTapView;

  late AnimationController animationController;
  late Animation<double> animation;
  late Animation<RelativeRect> rectAnimation;

  PageController pageController = PageController();

  List<AnimationController> animationControllers = [];

  ScrollPhysics pageScrollPhysics = const AlwaysScrollableScrollPhysics();

  @override
  void initState() {
    _selectedIndex = widget.initialIndex;
    for (int i = 0; i < widget.tabs.length; i++) {
      animationControllers.add(AnimationController(
        duration: const Duration(milliseconds: 400),
        vsync: this,
      ));
    }
    _selectTab(widget.initialIndex);

    if (widget.disabledChangePageFromContentView == true) {
      pageScrollPhysics = const NeverScrollableScrollPhysics();
    }

    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      pageController.jumpToPage(widget.initialIndex);
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: widget.direction,
      child: Container(
        color: widget.backgroundColor ?? Theme.of(context).canvasColor,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Expanded(
              child: Row(
                children: <Widget>[
                  Material(
                    //color: Colors.white,
                    elevation: 0,
                    shadowColor: widget.tabsShadowColor,
                    shape: const BeveledRectangleBorder(),
                    child: SizedBox(
                      width: widget.tabsWidth,
                      child: ListView.builder(
                        itemCount: widget.tabs.length,
                        itemBuilder: (context, index) {
                          String tab = widget.tabs[index].title;

                          double? left, right;
                          if (widget.direction == TextDirection.rtl) {
                            left = ((widget.indicatorSide == IndicatorSide.end)
                                ? 0
                                : null);
                            right =
                            ((widget.indicatorSide == IndicatorSide.start)
                                ? 0
                                : null);
                          } else {
                            right = ((widget.indicatorSide == IndicatorSide.end)
                                ? 0
                                : null);
                            left =
                            ((widget.indicatorSide == IndicatorSide.start)
                                ? 0
                                : null);
                          }

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Stack(
                              children: <Widget>[
                                Positioned(
                                  top: 2,
                                  bottom: 2,
                                  width: widget.indicatorWidth,
                                  left: left,
                                  right: right,
                                  child: ScaleTransition(
                                    scale: Tween(begin: 0.0, end: 1.0).animate(
                                      CurvedAnimation(
                                        parent: animationControllers[index],
                                        curve: Curves.elasticOut,
                                      ),
                                    ),
                                    child: Container(
                                      color: widget.indicatorColor,
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    _changePageByTapView = true;
                                    setState(() {
                                      _selectTab(index);
                                    });

                                    pageController.animateToPage(index,
                                        duration: widget.changePageDuration,
                                        curve: widget.changePageCurve);
                                  },
                                  child: Container(
                                    color: Colors.transparent,
                                    padding: const EdgeInsets.all(10.0),
                                    child: Row(children: [
                                      SizedBox(width: widget.tabsWidth-50,child: Text(tab,
                                          style: _selectedIndex == index
                                              ? widget.selectedTabTextStyle
                                              : widget.unSelectedTabTextStyle),),
                                      Icon(widget.tabs[index].icon, color: _selectedIndex == index
                                          ? widget.selectedTabTextStyle.color
                                          : widget.unSelectedTabTextStyle.color,),
                                    ],),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    child: PageView.builder(
                      scrollDirection: widget.contentScrollAxis,
                      physics: pageScrollPhysics,
                      onPageChanged: (index) {
                        if (_changePageByTapView == false ||
                            _changePageByTapView == null) {
                          _selectTab(index);
                        }
                        if (_selectedIndex == index) {
                          _changePageByTapView = null;
                        }
                        setState(() {});
                      },
                      controller: pageController,

                      // the number of pages
                      itemCount: widget.contents.length,

                      // building pages
                      itemBuilder: (BuildContext context, int index) {
                        return widget.contents[index];
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selectTab(index) {
    _selectedIndex = index;
    for (AnimationController animationController in animationControllers) {
      animationController.reset();
    }
    animationControllers[index].forward();

    if (widget.onSelect != null) {
      widget.onSelect!(_selectedIndex);
    }
  }
}