import 'package:cherry_toast/cherry_toast.dart';
import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart%20';
import 'package:flutter/services.dart';
import 'package:tickets/shared/actions/key_raw_listener.dart';
import 'package:tickets/shared/widgets/card/my_swipe_tile_card.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../../config/theme/app_theme.dart';
import '../../../../../shared/utils/color_palette.dart';
import '../../../../../shared/utils/texts.dart';
import '../../../../../shared/widgets/Snackbars/cherryToast.dart';
import '../../../../../shared/widgets/dialogs/custom_awesome_dialog.dart';
import '../../../../../shared/widgets/error/customNoData.dart';
import '../../../../../shared/widgets/textfields/my_textfield_icon.dart';


enum ColorSizeEnum {color, size}

class ColorAndSize extends StatefulWidget {
  Function(List<NewMaterial>)onSave;
   ColorAndSize({
     super.key,
     required this.onSave
  });

  @override
  State<ColorAndSize> createState() => _ColorAndSizeState();
}

class _ColorAndSizeState extends State<ColorAndSize> {
  late Size size;
  late ThemeData theme;


  @override
  void initState() {
    Future.delayed( const Duration(milliseconds: 300),(){focusColor.requestFocus();} );
    super.initState();
  }

  final _animatedColorListKey = GlobalKey<AnimatedListState>();
  final _animatedSizeListKey = GlobalKey<AnimatedListState>();

  final _fullFormKey = GlobalKey();

  final focusColor = FocusNode();
  final focusSize = FocusNode();

  List<String> colors = [];
  List<String> sizes = [];

  ColorSizeEnum selectedPage = ColorSizeEnum.color;

  List<SizeFeatures> listSizeModel =[];
  List<ColorFeatures> tempColorList =[];


  final _gridSController = ScrollController();
  final _colorScroll = ScrollController();
  final referenciaController = TextEditingController();
  final tallaController = TextEditingController();

  final colorController = TextEditingController();
  final referenciaColorController = TextEditingController();
  final referenciaOrigenController = TextEditingController();
  final focusColorController = FocusNode();

final _pressedKey = GlobalKey();


  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    theme = Theme.of(context);
    return  PressedKeyListener(
      Gkey: _pressedKey,
        keyActions: {
        LogicalKeyboardKey.enter:(){selectedPage== ColorSizeEnum.color?colorValidationAdd():sizeValidation();},
        LogicalKeyboardKey.escape:(){ scapeWarning(); },
        LogicalKeyboardKey.f4:(){ createObj(); },
        },
        child: _body());
  }
  Widget _body(){
    return Column(
      children:[
        _head(),
        _middle(),
        _footer(),
      ],
    );
  }

  Widget _head(){
    return Container(
      height: size.height *.07,
      width: size.width,
      margin: const EdgeInsets.only(bottom: 10, top: 20),
      decoration : BoxDecoration(
          border: Border.all(color: theme.colorScheme.primary),
          color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8)
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          SegmentedButton(
            segments:   [
              ButtonSegment(
                value: ColorSizeEnum.color,
                label:Text("Color", style: TextStyle(color: theme.colorScheme.onPrimary),),
                icon: Icon( Icons.color_lens_outlined, color: theme.colorScheme.onPrimary,),
              ),
              ButtonSegment(
                value: ColorSizeEnum.size,
                label:Text("Talla", style: TextStyle(color: theme.colorScheme.onPrimary),),
                icon: Icon( Icons.straighten_outlined, color: theme.colorScheme.onPrimary,),
              ),
            ],
            selected: { selectedPage },
            onSelectionChanged: (newSelection){
              setState(() {
                selectedPage = newSelection.first;
              });
              Future.delayed(const Duration( milliseconds: 200 ),(){
                focusSize.requestFocus();
              });
            },
            style: ButtonStyle(
              splashFactory: InkSplash.splashFactory,
              side: MaterialStateProperty.resolveWith((states){
                if(states.contains(MaterialState.selected)){return BorderSide(color: theme.colorScheme.primary, width: 2);} return BorderSide(color: theme.colorScheme.onPrimary, width: 1);/// cambio de color al seleccionar
              }),
              enableFeedback: true,
              backgroundColor: MaterialStateProperty.resolveWith((states){
                if(states.contains(MaterialState.selected)){return Colors.blue.withOpacity(0.5);} return Colors.transparent;/// cambio de color al seleccionar
              }),
              foregroundColor: MaterialStateProperty.resolveWith((states){
                if(states.contains(MaterialState.selected)){ return theme.colorScheme.onPrimary;} return theme.colorScheme.onPrimary;/// cambio de color al seleccionar
              }),
              overlayColor: MaterialStateProperty.all(Colors.blue.withOpacity(0.2)), // Efecto al presionar
              shape: MaterialStateProperty.all( RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              ) ,
              visualDensity: VisualDensity.comfortable,
            ),
          ),
          _changeTitle(),
          ElevatedButton(
            style: ButtonStyle(
              overlayColor: MaterialStateProperty.all(Colors.blue.withOpacity(0.5)),
              backgroundColor: MaterialStateProperty.all(theme.colorScheme.background),
              shape: MaterialStateProperty.all(RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: theme.colorScheme.secondary, width: 2)
              )),
            ),
            onPressed: (){
               selectedPage== ColorSizeEnum.color?colorValidationAdd():sizeValidation();
            },
            child: Row(
              children: [
                Tooltip(message:'Presione enter para añadir',
                  child: Text("Agregar", style: TextStyle(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.bold ),
                  ),
                ),
                Icon(Icons.add,
                  color: theme.colorScheme.onPrimary,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _changeTitle(){
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      reverseDuration: const Duration(milliseconds: 200),
      transitionBuilder: (Widget child, Animation<double> animation ){
           return  FadeTransition(
             opacity: animation,
             child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset( 0,0) ,
                    end:const Offset( 0,0 )
                  ).animate(animation),
                      child: child,
              ),
           );},
          child:  _titles(),
    );
  }

  _titles(){
    return selectedPage != ColorSizeEnum.color
        ? SizedBox(
          key: const ValueKey(ColorSizeEnum.size),
          child: Text("Crear talla",
         style: TextStyle(
            fontSize: 20, color: theme.colorScheme.onPrimary,
            fontWeight: FontWeight.bold),),
    )
        : SizedBox(
         key: const ValueKey(ColorSizeEnum.color),
            child: Text("Crear color",
            style: TextStyle(fontSize: 20,
             color: theme.colorScheme.onPrimary,
             fontWeight: FontWeight.bold),),
    );
  }

  Widget _middle(){
    return AnimatedSwitcher(
      key: _fullFormKey,
        duration: const Duration(milliseconds:300),
      reverseDuration: const Duration(milliseconds:300),
      transitionBuilder: (Widget child, Animation<double> animation)=>
          FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: Offset.zero,
                end: const Offset(0,0)
              ).animate(animation),
              child: child,
            ),
          ),
      child: selectedPage == ColorSizeEnum.color?
        colorWidget():sizePage(),
    );
  }

  Widget _footer(){
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children:[
          ElevatedButton(
              style: ButtonStyle(
                overlayColor: MaterialStateProperty.all(ColorPalette.err),
              ),
              onPressed: (){ scapeWarning();},
              child: Text("Cancelar(Esc)", style: TextStyle(color: theme.colorScheme.onPrimary, fontSize: 14),
              )
          ),
          ElevatedButton(
              style: ButtonStyle(
                overlayColor: MaterialStateProperty.all(ColorPalette.ok),
              ),
              onPressed: (){
                createObj();
              },
              child: Text("Guardar( F4 )", style: TextStyle(color: theme.colorScheme.onPrimary, fontSize: 14),)
          ),
        ]
    );
  }


  Widget sizePage(){
    return Column(
      key: const ValueKey(ColorSizeEnum.size),
      children: [
        _twoFormRow(
          MyTextfieldIcon(
              labelText: "Talla",
              textController:tallaController,
            focusNode: focusSize,
          ),
          MyTextfieldIcon(
              labelText: "Referencia",
              textController:referenciaController,
          ),

        ),
        Container(
          height: size.height*.38,
          width: size.width,
          margin: const EdgeInsets.only(bottom: 10, top: 10),
          padding: const EdgeInsets.all(5),
          decoration : BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              border: Border.all(color: theme.colorScheme.primary),
              color: theme.colorScheme.surface
          ),
          child: listSizeModel.isEmpty? NoDataWidget(text: "'Vacio' Por favor inserte una talla ",)
              :Scrollbar(
            thickness: 5,
            thumbVisibility: true,
            radius: const Radius.circular(0),
            controller: _gridSController,
            child: FadingEdgeScrollView.fromAnimatedList(
              gradientFractionOnEnd: .2, child:
            AnimatedList(
              key: _animatedSizeListKey,
              controller:_gridSController ,
              initialItemCount: listSizeModel.length,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index, Animation<double>animation){
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                        begin: const Offset(.25,0),
                        end: const Offset(0,0)
                    ).animate(animation),
                    child: _sizeCard(index),
                  ),
                );
              },
            ),
            ),
          ),
        ),
      ],
    );
  }

  Widget colorWidget(){
   return Column(
     key: const ValueKey(ColorSizeEnum.color),
     children: [
       _treeFormRow(
         MyTextfieldIcon(
           labelText: "Color",
           textController: colorController,
           focusNode: focusColor,
         ),
         MyTextfieldIcon(
             labelText: "Referencia",
             textController: referenciaColorController,

         ),
         MyTextfieldIcon(
             labelText: "Referencia Origen",
             textController: referenciaOrigenController,
         ),
       ),
       Container(
         height: size.height*.38,
         width: size.width,
         margin: const EdgeInsets.only(top: 10, bottom: 10),
         decoration : BoxDecoration(
           border: Border.all(color: theme.colorScheme.primary),
           color: theme.colorScheme.surface,
           borderRadius: BorderRadius.circular(8),
         ),
         child: tempColorList.isEmpty?  NoDataWidget(text: "'Vacio' Por favor inserte un color ",)
               : Scrollbar(
                  controller: _colorScroll,
                  thumbVisibility: true,
                  child:
                  FadingEdgeScrollView.fromAnimatedList(
                    child: AnimatedList(
                       key: _animatedColorListKey,
                       controller: _colorScroll,
                       initialItemCount: tempColorList.length,
                       physics: const BouncingScrollPhysics(),
                       itemBuilder: (context, index, Animation<double>animation)=>
                       FadeTransition(
                         opacity: animation,
                         child: SlideTransition(
                           position: Tween<Offset>(
                               begin: const Offset(.25,0),
                               end: const Offset(0,0)
                           ).animate(animation),
                           child: _colorCard(index),
                         ),
                       ),
             ),
           ),
         ),
       ),
     ],
   );
  }

  Widget _sizeCard(index){
    return MySwipeTileCard(
      radius: 8,horizontalPadding: 1,verticalPadding:2,
      colorBasico: index%2==0? theme.colorScheme.background
          : ( theme.colorScheme == GlobalThemData.lightColorScheme
          ? ColorPalette.backgroundLightColor:ColorPalette.backgroundDarkColor
      ),
      onTapLR: (){},
      onTapRL: () async {
        setState(() {
          _animatedSizeListKey.currentState?.removeItem(index,(context, animation)=>
              FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                      begin: const Offset(-.025,0),
                      end: const Offset(0,0)
                  ).animate(animation),
                  child: _sizeCard(index),
                ),
              )
          );
        });
        await  Future.delayed(const Duration(milliseconds: 50));
        listSizeModel.removeAt(index);
      },
      containerB: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          SizedBox(
              child: Text(
                listSizeModel[index].size,
                style: TextStyle(color: theme.colorScheme.onPrimary),)),
          SizedBox(
              child: Text(
                listSizeModel[index].reference,
                style: TextStyle(color: theme.colorScheme.onPrimary),)),
        ],
      ),
    );
  }
  Widget _colorCard(index){
    return MySwipeTileCard(
      radius: 8,horizontalPadding: 1,verticalPadding:2,
      colorBasico: index%2==0? theme.colorScheme.background
          : ( theme.colorScheme == GlobalThemData.lightColorScheme
          ? ColorPalette.backgroundLightColor:ColorPalette.backgroundDarkColor
      ),
      onTapLR: (){
      },
      onTapRL: () async {
        setState(() {
          _animatedColorListKey.currentState?.removeItem(index, (context, animation) =>
              FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                      begin: const Offset(-.025,0),
                      end: const Offset(0,0)
                  ).animate(animation),
                  child: _colorCard(index),
                ),
              )
          );
        });
        await  Future.delayed(const Duration(milliseconds: 50));
        tempColorList.removeAt(index);
      },
      containerB: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text(tempColorList[index].color),
          Text(tempColorList[index].referencia),
          Text(tempColorList[index].referenciaOrigen),
        ],
      ),
    );
  }

  addColor(){
      setState(() {
        tempColorList.add(ColorFeatures(
            color: colorController.text,
            referencia: referenciaColorController.text,
            referenciaOrigen: referenciaOrigenController.text
        ));
        _animatedColorListKey.currentState?.insertItem(tempColorList.length-1);
      });
  }
  addSize(){
    setState(() {
      listSizeModel.add(
          SizeFeatures(
              size: tallaController.text,
              reference: referenciaController.text
          ));
      _animatedSizeListKey.currentState?.insertItem(listSizeModel.length-1);
    });
  }
  Widget _twoFormRow(Widget widget1, Widget widget2){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(width: size.width/6,child: widget1,),
        SizedBox(width: size.width/6,child: widget2,),
      ],
    );
  }
  Widget _treeFormRow(Widget widget1, Widget widget2, Widget widget3){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(width: size.width/7.5,child: widget1,),
        SizedBox(width: size.width/7.5,child: widget2,),
        SizedBox(width: size.width/7.5,child: widget3,),
      ],
    );
  }

  void colorValidationAdd(){
    if(tempColorList.where((color) => color.color == colorController.text).isNotEmpty ){
      return MyCherryToast.showWarningSnackBar(context, theme, "Este color ya existe");
    }else if(colorController.text.isNotEmpty ){
    addColor();
    setState(() {
      colorController.clear();
      referenciaColorController.clear();
      referenciaOrigenController.clear();
    });
    Future.delayed(const Duration(milliseconds: 100),
            (){
          focusColor.requestFocus();
        });
    }

  }

sizeValidation(){
    if(listSizeModel.where((talla) => talla.size == tallaController.text).isNotEmpty ){
    return MyCherryToast.showWarningSnackBar(context, theme, "Esta talla ya existe");
} else if(tallaController.text.isNotEmpty){
      addSize();
      setState(() {
        tallaController.clear();
        referenciaController.clear();
      });
      Future.delayed(const Duration(milliseconds: 100),(){
        focusSize.requestFocus();
      });
    }
}

  List<String>auxCombinacionesFinal =[] ;
  List<String>auxCombinacionesTemporal=[];

void getStrings(){
    for (var colorE in tempColorList) {
      colors.add(colorE.color.toString());
    }
    for (var sizeE in listSizeModel) {
      sizes.add(sizeE.size.toString());
    }
}
List<NewMaterial> newMaterial =[];
void createNewMaterial(){
  for( var color in tempColorList ){
    for(var size in listSizeModel ){
     newMaterial.add(
       NewMaterial(
           color: color.color,
           referenciaColor: color.referencia,
           referenciaOrigenColor: color.referenciaOrigen,
           talla: size.size,
           referenceSize: size.reference
       ),
     );
    }
  }
}

void scapeWarning(){
  if( listSizeModel.isNotEmpty||tempColorList.isNotEmpty){
    CustomAwesomeDialog(
      title: Texts.lostData,
      desc: Texts.lostData,
      btnCancelOnPress: () {},
      btnOkOnPress: () {
        Navigator.of(context).pop();
      },).showQuestion(context);
  } else {
    Navigator.pop(context);
  }

}

void createObj(){
  createNewMaterial();
  if( tempColorList.isNotEmpty&&listSizeModel.isNotEmpty){
    widget.onSave(newMaterial);
    Future.delayed(const Duration(milliseconds: 200));
    Navigator.of(context).pop(context);
  } else {
    MyCherryToast.showWarningSnackBar(context, theme, "Color o talla vacios por favor agregue los alementos requeridos");
  }
}

}
class SizeFeatures {
  final String size;
  final String reference;
  SizeFeatures({
    required this.size,
    required this.reference
  });
}
class ColorFeatures{
  final String color;
  final String referencia;
  final String referenciaOrigen;
  ColorFeatures({
    required this.color,
    required this.referencia,
    required this.referenciaOrigen
});
}
class NewMaterial{
  final String color;
  final String referenciaColor;
  final String referenciaOrigenColor;
  final String talla;
  final String referenceSize;
  NewMaterial({
    required this.color,
    required this.referenciaColor,
    required this.referenciaOrigenColor,
    required this.talla,
    required this.referenceSize
  });

}