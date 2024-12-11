import 'package:flutter/material.dart';
import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';

class MyAnimatedToolBar extends StatefulWidget {
  final ScrollController toolBarController;
  final List<Widget> buttons;

  const MyAnimatedToolBar({
    Key? key,
    required this.toolBarController,
    required this.buttons,
  }) : super(key: key);

  @override
  _MyAnimatedToolBarState createState() => _MyAnimatedToolBarState();
}

class _MyAnimatedToolBarState extends State<MyAnimatedToolBar> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return GestureDetector(
      onTap: toggleExpansion,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        width: _isExpanded ? 650 : 45,
        height: 57,
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.secondary,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(children: [
            const Padding(padding: EdgeInsets.all(10), child: Icon(Icons.search),),
            if(_isExpanded) ...[
              Expanded(
                child: FadingEdgeScrollView.fromSingleChildScrollView(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    controller: widget.toolBarController,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(10, 10, 15, 10),
                      child: Row(
                        children: widget.buttons,
                      ),
                    ),
                  ),
                ),
              ),
            ]
          ],
          ),
        ),
      ),
    );
  }
}