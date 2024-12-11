import 'package:flutter/material.dart';
import 'package:tickets/shared/utils/color_palette.dart';
import 'package:tickets/shared/utils/icon_library.dart';
import 'package:swipeable_tile/swipeable_tile.dart';

class MySwipeTileCard extends StatelessWidget {
  final Color? colorBasico;
  final Color? colorLR;
  final Color? colorRL;
  final Color? colorFondo;
  Color? iconColor;
  final Function onTapLR;
  final Function onTapRL;
  final Widget containerB;
  final Widget? containerLR;
  final Widget? containerRL;
  final double? radius;
  final double? horizontalPadding;
  final double? verticalPadding;
  final double? opacity;
  final double? blur;
  final double? offset;
  final double? swipeThreshold;
  final IconData? iconLR;
  final IconData? iconRL;
  MySwipeTileCard({
    super.key,
    this.colorBasico,
    this.colorLR,
    this.colorRL,
    this.colorFondo,
    required this.containerB,
    required this.onTapLR,
    required this.onTapRL,
    this.containerRL,
    this.containerLR,
    this.radius = 10,
    this.horizontalPadding = 10,
    this.verticalPadding = 3,
    this.blur = 1,
    this.opacity = 0.35,
    this.offset = 1,
    this.iconColor,
    this.swipeThreshold = 0.12,
    this.iconLR,
    this.iconRL,
  });
  @override
  Widget build(BuildContext context){
    return SwipeableTile.swipeToTriggerCard(
      color: colorBasico != null? colorBasico! : Theme.of(context).primaryColor,
      borderRadius: radius!= null? radius! : 0,
      shadow: BoxShadow(
        color: Colors.black.withOpacity(opacity != null? opacity! : 0.35),
        blurRadius: blur != null? blur! : 0,
        offset: Offset(offset != null? offset! : 0, offset != null? offset! : 0),
      ),
      horizontalPadding: horizontalPadding!= null? horizontalPadding! : 0,
      verticalPadding: verticalPadding!= null? verticalPadding! : 0,
      direction: SwipeDirection.horizontal,
      onSwiped: (direction) {
        if (direction == SwipeDirection.endToStart) {
          onTapRL();
        } else if (direction == SwipeDirection.startToEnd) {
          onTapLR();
        }
        // Here call setState to update state
      },
      swipeThreshold: swipeThreshold != null? swipeThreshold! : 0.12,
      backgroundBuilder: (context, direction, progress) {
        return AnimatedBuilder(
          animation: progress,
          builder: (context, child) {
            return AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                color: progress.value > 0.2
                    ? direction == SwipeDirection.endToStart? (colorRL != null? colorRL! : ColorPalette.redColor) :
                (colorLR != null? colorLR! : ColorPalette.yellowColor)
                    : colorFondo ?? Theme.of(context).backgroundColor,
                child: Padding(padding:const EdgeInsets.symmetric(horizontal: 5),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,children: [
                    containerLR?? Row(children: [
                      Icon( iconLR ?? IconLibrary.iconEdit, color: iconColor,)
                    ],), containerRL?? Row(children: [
                      Icon(iconRL ?? IconLibrary.iconDelete, color: iconColor,)
                    ],),
                  ],
                  ),
                )
            );
          },
        );
      },
      key: UniqueKey(),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: containerB,// Here Tile which will be shown at the top
      ),
    );
  }
}