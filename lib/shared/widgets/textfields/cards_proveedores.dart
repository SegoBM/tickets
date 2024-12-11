import 'package:flutter/material.dart';
import 'package:tickets/shared/utils/color_palette.dart';
import 'package:tickets/shared/utils/icon_library.dart';
import 'package:swipeable_tile/swipeable_tile.dart';

class MySwipeTileCard2 extends StatelessWidget {
  final Color? colorBasico;
  final Color? colorLR;
  final Color? colorRL;
  final Color? colorFondo;
  Color? iconColor;
  final Widget containerB;

  final double? radius;
  final double? horizontalPadding;
  final double? verticalPadding;

  final double? opacity;
  final double? blur;
  final double? offset;

  MySwipeTileCard2({
    super.key,
    this.colorBasico,
    this.colorLR,
    this.colorRL,
    this.colorFondo,
    required this.containerB,
    this.radius = 10,
    this.horizontalPadding = 10,
    this.verticalPadding = 3,
    this.blur = 1,
    this.opacity = 0.35,
    this.offset = 1,
    this.iconColor
  });

  @override
  Widget build(BuildContext context) {
    return SwipeableTile.swipeToTriggerCard(
      color: colorBasico != null ? colorBasico! : Theme.of(context).primaryColor,
      borderRadius: radius != null ? radius! : 0,
      shadow: BoxShadow(
        color: Colors.black.withOpacity(opacity != null ? opacity! : 0.35),
        blurRadius: blur != null ? blur! : 0,
        offset: Offset(offset != null ? offset! : 0, offset != null ? offset! : 0),
      ),
      horizontalPadding: horizontalPadding != null ? horizontalPadding! : 0,
      verticalPadding: verticalPadding != null ? verticalPadding! : 0,
      direction: SwipeDirection.horizontal,
      onSwiped: (direction) {
        // No actions needed here
        // You can optionally add logic if required
      },
      swipeThreshold: 0.12,
      backgroundBuilder: (context, direction, progress) {
        return AnimatedBuilder(
          animation: progress,
          builder: (context, child) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              color: progress.value > 0.2
                  ? direction == SwipeDirection.endToStart
                  ? (colorRL != null ? colorRL! : ColorPalette.redColor)
                  : (colorLR != null ? colorLR! : ColorPalette.yellowColor)
                  : colorFondo ?? Theme.of(context).backgroundColor,
            );
          },
        );
      },
      key: UniqueKey(),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: containerB,
      ),
    );
  }
}
