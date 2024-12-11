

import 'package:cherry_toast/cherry_toast.dart';
import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tickets/config/theme/app_theme.dart';
import 'package:tickets/shared/actions/key_raw_listener.dart';
import 'package:tickets/shared/widgets/error/customNoData.dart';
import 'package:tickets/shared/widgets/textfields/my_textfield_icon.dart';

import '../../../../../shared/utils/color_palette.dart';
import '../../../../../shared/utils/texts.dart';
import '../../../../../shared/widgets/Snackbars/cherryToast.dart';
import '../../../../../shared/widgets/card/my_swipe_tile_card.dart';
import '../../../../../shared/widgets/dialogs/custom_awesome_dialog.dart';
class ColorFeatureDialog extends StatefulWidget {
  Function(List<ColorFeature>) onSaved;
   ColorFeatureDialog({
     required this.onSaved,
     super.key
   });

  @override
  State<ColorFeatureDialog> createState() => _ColorFeatureDialogState();
}

class _ColorFeatureDialogState extends State<ColorFeatureDialog> {
  late Size size;
  late ThemeData theme;


  final _animatedListKey = GlobalKey<AnimatedListState>();

  List<ColorFeature> colorFeature =[];
  List<TextEditingController> listTextEditing =[];
  List<FocusNode> listFocuses = [];
  List<TextEditingController> controllerDesc = [];
  List<TextEditingController> etiquetaController = [];
  List<MaterialTextSelectionControls> listMaterialControls = [];
  final List<ColorFeature>_tempColorList= [];

  final TextEditingController _colorController = TextEditingController();
  TextEditingController textController2 = TextEditingController();
  TextEditingController textController3 = TextEditingController();

  final focusController = FocusNode();

  final   ScrollController  _colorScroll = ScrollController();

  @override
  void initState() {
    Future.delayed(const Duration(milliseconds:200),(){
    focusController.requestFocus();
    });
    super.initState();
  }
@override
  void dispose() {
    listFocuses.clear();
    listTextEditing.clear();
    controllerDesc.clear();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    theme = Theme.of(context);
    final GlobalKey presssKey = GlobalKey();
    return PressedKeyListener(
        Gkey: presssKey,
        keyActions: {
          LogicalKeyboardKey.escape:(){scapeQuestion();},
          LogicalKeyboardKey.enter:(){filteredSave();},
          LogicalKeyboardKey.f4:(){enterSave();}
        },
        child: _body());
  }

  Widget _body(){
    return Column(
      children:[
        _head(),
        // _middle(),
        _middleSeconView(),
        const Spacer(),
        _footer(),
      ],
    );
  }

  Widget _head(){
    return Container(
      height: size.height * 0.06,
      width: size.width,
      margin: const EdgeInsets.only(bottom: 10, top: 20),
      decoration : BoxDecoration(
        borderRadius: BorderRadius.circular(8),
          border: Border.all(color: theme.colorScheme.primary),
          color: theme.colorScheme.surface
      ),
      child:
       Row(
         children: [
           const Spacer(),
           Text("Seleccionador de color",
             style: TextStyle(
               fontSize: 20,
               color: theme.colorScheme.onPrimary,
               fontWeight: FontWeight.bold
             ),
           ),
           const Spacer(),
         Tooltip(message: "Presiona enter para añadir",
           child: ElevatedButton(
             style: ButtonStyle(
               overlayColor: MaterialStateProperty.all(Colors.blue.withOpacity(0.5)),
               backgroundColor: MaterialStateProperty.all(theme.colorScheme.background),
               shape: MaterialStateProperty.all(RoundedRectangleBorder(
                 borderRadius: BorderRadius.circular(8),
                 side: BorderSide(color: theme.colorScheme.secondary, width: 2)
               )),
             ),
               onPressed: (){
                 filteredSave();
               },
               child: Row(
                 children: [
                   Text("Agregar",style: TextStyle( color: theme.colorScheme.onPrimary,fontWeight: FontWeight.bold ),),
                    Icon(Icons.add, color: theme.colorScheme.onPrimary,)
                 ],
               ),
           ),
         ),
           const Spacer()
         ],
       )
    );
  }

  Widget _footer(){
    return _fotterButtons();
  }

  Widget  _fotterButtons(){
    return Row(
      children:[
        const Spacer(),
       ElevatedButton(
           style: ButtonStyle(
             overlayColor: MaterialStateProperty.all(ColorPalette.err),
           ),
           onPressed: (){
             scapeQuestion();
           },
           child: Text("Cancelar( Esc )", style: TextStyle(color: theme.colorScheme.onPrimary),)
       ),
        const Spacer(),
        ElevatedButton(
            style: ButtonStyle(
              overlayColor: MaterialStateProperty.all(ColorPalette.ok),
            ),
           onPressed:(){  enterSave(); },
           child: Text("Guardar( F4 )", style: TextStyle(color: theme.colorScheme.onPrimary),)
       ),
        const Spacer(),
      ]
    );
  }





  selectionFunction( FocusNode focusNode,TextEditingController textEditingController){
    if(focusNode.hasFocus){
      textEditingController.selection = TextSelection(
          baseOffset: 0,
          extentOffset: textEditingController.text.length
      );
    }
  }


  Widget _middleSeconView(){
    return Column(
      children: [
        _treeFormRow(
          MyTextfieldIcon(labelText: "Color", textController: _colorController,focusNode: focusController,),
          MyTextfieldIcon(labelText: "Referencia", textController: textController2),
          MyTextfieldIcon(labelText: "Referencia Origen", textController: textController3),
        ),
        Container(
          height:  size.height<700? size.height*.4:size.height*.40 ,
          width: size.width,
          margin: const EdgeInsets.only(top: 10),
          decoration : BoxDecoration(
            border: Border.all(color: theme.colorScheme.primary),
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
          ),
          child: _tempColorList.isEmpty?  NoDataWidget(text: "'Vacio' Por favor inserte un color " ,)
              : Scrollbar(
                controller: _colorScroll,
                thumbVisibility: true,
                child:
                FadingEdgeScrollView.fromAnimatedList(
                  child: AnimatedList(
                    key: _animatedListKey,
                    controller: _colorScroll,
                    initialItemCount: _tempColorList.length,
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index, Animation<double>animation)=>
                        FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                                begin: const Offset(.25,0),
                                end: const Offset(0,0)
                            ).animate(animation),
                            child: _secondCard(index),
                          ),
                        ),
                  ),
                ),
              ),
            ),
          ],
        );
      }

Widget _treeFormRow(Widget widget1, Widget widget2, Widget widget3,){
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      SizedBox(width: size.width/9,child: widget1,),
      SizedBox(width: size.width/9,child: widget2,),
      SizedBox(width: size.width/9,child: widget3,),
    ],
  );
}

  Widget _secondCard(index){
  return  MySwipeTileCard(
    radius: 8,horizontalPadding: 1,verticalPadding:2,
    colorBasico: index%2==0? theme.colorScheme.background
        : ( theme.colorScheme == GlobalThemData.lightColorScheme
        ? ColorPalette.backgroundLightColor:ColorPalette.backgroundDarkColor
    ),
    onTapLR: (){
    },
    onTapRL: () async {
      setState(() {
        _animatedListKey.currentState?.removeItem(index, (context, animation) =>
           FadeTransition(
              opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(-.025,0),
                end: const Offset(0,0)
              ).animate(animation),
              child: _secondCard(index),
            ),
          )
        );
      });
      await  Future.delayed(const Duration(milliseconds: 50));
      _tempColorList.removeAt(index);
    },
    containerB: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Text(_tempColorList[index].color),
        Text(_tempColorList[index].descripcion),
        Text(_tempColorList[index].etiqueta),
      ],
    ),

  );
  }
void enterSave(){
  if( _tempColorList == null || _tempColorList.isEmpty){
    MyCherryToast.showWarningSnackBar(context, theme,'Al menos un campo debe de ser agregado', "");
  } else{
    widget.onSaved(_tempColorList);
    print(widget.onSaved(_tempColorList));
    print(_tempColorList.length);
    print("se esta guardando");
    Future.delayed(const Duration(milliseconds: 1000));
    Navigator.pop(context);
  }
}
_saveLabel(){
    setState(() {
      _tempColorList.add(ColorFeature(
          color: _colorController.text,
          descripcion: textController2.text,
          etiqueta: textController3.text
      ));
    _animatedListKey.currentState?.insertItem(_tempColorList.length-1);
    });
    print(_tempColorList.length);
}
void filteredSave(){
    if( _tempColorList.where((color) => color.color == _colorController.text).isNotEmpty ){
      MyCherryToast.showWarningSnackBar(context, theme, "Este color ya existe", "Por favor ingrese uno diferente");
      Future.delayed(const Duration(milliseconds: 300),(){
        setState((){ focusController.requestFocus(); });
      });
    }else if(_colorController.text.isNotEmpty||colorFeature.isNotEmpty){
      _saveLabel();
      clearTexts();
    }else{
      MyCherryToast.showWarningSnackBar(context, theme,'Color debe de ser agragado', "");
      Future.delayed(const Duration(milliseconds: 300),(){
      setState((){ focusController.requestFocus(); }); });
    }
}

scapeQuestion(){
    if(_tempColorList.isNotEmpty){
      CustomAwesomeDialog(
        title: Texts.lostData,
        desc: Texts.lostData,
        btnCancelOnPress: () {},
        btnOkOnPress: () {
          Navigator.of(context).pop();
        },).showQuestion(context);
    } else{
      Navigator.pop(context);
    }
}

clearTexts() async {
  setState(() {
    _colorController.clear();
    textController2.clear();
    textController3.clear();
  });
    await Future.delayed(const Duration(milliseconds: 100),(){
    focusController.requestFocus();
    });
  }
}

class ColorFeature {
  String color;
  String descripcion;
  String etiqueta;
  ColorFeature({
    required this.color,
    required this.descripcion,
    required this.etiqueta
  });
}

