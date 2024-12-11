/*import 'package:flutter/material.dart';
class EasyAnimatedButton extends StatefulWidget {
  EasyAnimatedButton({Key? key, required this.onButtonPressed, this.defaultColor = Colors.green,
    this.failureColor = Colors.red, this.successColor = Colors.blue,
    this.processSuccessful = false, required this.onFailure, required this.onSuccessful,
    this.animationDuration = const Duration(milliseconds: 300), this.delayDuration = const Duration(milliseconds: 350),
    this.resetAnimation = const Duration(seconds: 1), this.buttonHeight = 50.0,
    this.successIcon = Icons.check, this.failureIcon = Icons.close, this.buttonWidth = 50.0,
    required this.buttonText, this.successIconColor = Colors.white,this.failureIconColor = Colors.white,
  }) : super(key: key);

  Future<bool?> Function() onButtonPressed;
  Future<void> Function() onSuccessful;
  Future<void> Function() onFailure;
  Color successColor;Color failureColor;Color defaultColor;
  bool processSuccessful; String buttonText;
  Duration animationDuration; Duration delayDuration;Duration resetAnimation;
  double buttonHeight;double buttonWidth;
  IconData? successIcon;IconData? failureIcon;
  Color successIconColor; Color failureIconColor;
  @override
  _EasyAnimatedButtonState createState() => _EasyAnimatedButtonState();
}
class _EasyAnimatedButtonState extends State<EasyAnimatedButton> with TickerProviderStateMixin {

  late AnimationController animationController;
  late AnimationController colorAnimationController;
  late Animation<double> animation;
  late Animation<double> widthAnimation;
  late Animation<double> textAnimation;
  late Animation<Color?> successColorAnimation;
  late Animation<Color?> failureColorAnimation;
  bool? processSuccessful; // Nueva variable para rastrear si el proceso fue exitoso
  Color? buttonColor;
  bool isButtonEnabled = true;

  @override
  void initState() {
    super.initState();
    colorAnimationController = AnimationController(duration: widget.animationDuration, vsync: this);
    animationController = AnimationController(duration: widget.animationDuration,vsync: this);
    animation = Tween<double>(begin: 0,end: 60).animate(animationController)..addListener((){
      setState(() {});
    });
    widthAnimation = Tween<double>(begin: 0, end: 5).animate(animationController)..addListener(() {
      setState(() {});
    });
    textAnimation = Tween<double>(begin: 0, end: 14).animate(animationController)..addListener(() {
      setState(() {});
    });
    successColorAnimation = ColorTween(begin: widget.defaultColor, end: widget.successColor)
        .animate(colorAnimationController)
      ..addListener(() {setState(() {});});

    failureColorAnimation = ColorTween(begin: widget.defaultColor, end: widget.failureColor)
        .animate(colorAnimationController)
      ..addListener(() {setState(() {});});
    animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: widget.animationDuration,
      child: Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(100),
            color: processSuccessful == null ? successColorAnimation.value : (processSuccessful! ? successColorAnimation.value : failureColorAnimation.value), // Usa la variable buttonColor para el color del botón
          ),
          height: 50, width: widthAnimation.value*20+50,
          key: UniqueKey(),
          child: InkWell(
            borderRadius: BorderRadius.circular(100),
            onTap: isButtonEnabled? () async {
              if (animationController.status == AnimationStatus.completed) {
                setState(() {
                  isButtonEnabled = false;
                  animationController.reverse();
                });
                bool? value = await widget.onButtonPressed();
                returnAnimation(value);
              }
            } : null,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child:Center(child:  textAnimation.value < 8 ? const CircularProgressIndicator(color: Colors.white,)
                  : processSuccessful == null ?  Text('Iniciar Sesión',
                  style: TextStyle(fontSize: textAnimation.value, color: Colors.white)) : (processSuccessful!?
                    Icon(widget.successIcon, color: widget.successIconColor,) :
                    Icon(widget.failureIcon, color: widget.failureIconColor,))
              ),
            ),
          )
      ),
    );
  }
  Future<void> returnAnimation(bool? value) async {
    if(value != null){
      setState(() {
        colorAnimationController.forward();
        processSuccessful = value;
        animationController.forward();
      });
      Future.delayed(widget.resetAnimation, () async {
        colorAnimationController.reverse();

        if(value) {
          await widget.onSuccessful();
        }else{
          await widget.onFailure();
        }
        Future.delayed(widget.delayDuration, () {
          setState(() {
            processSuccessful = null;
            isButtonEnabled = true;
          });
        });
      });
    }else{
      animationController.forward();
      Future.delayed(widget.delayDuration, () {
        setState(() {
          processSuccessful = null;
          isButtonEnabled = true;
        });
      });
    }
  }
}*/