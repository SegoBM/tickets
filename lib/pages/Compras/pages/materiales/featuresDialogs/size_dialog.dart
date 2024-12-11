import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:flutter/cupertino.dart';
import'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tickets/shared/actions/key_raw_listener.dart';
import 'package:tickets/shared/utils/color_palette.dart';
import 'package:tickets/shared/utils/icon_library.dart';
import 'package:tickets/shared/widgets/card/my_swipe_tile_card.dart';
import 'package:tickets/shared/widgets/error/customNoData.dart';
import 'package:tickets/shared/widgets/textfields/my_textfield_icon.dart';

import '../../../../../config/theme/app_theme.dart';
import '../../../../../shared/utils/texts.dart';
import '../../../../../shared/widgets/Snackbars/cherryToast.dart';
import '../../../../../shared/widgets/dialogs/custom_awesome_dialog.dart';

class SizeFeatureDialog extends StatefulWidget {
  Function(List<SizeFeature> size) onSaved;
    SizeFeatureDialog({
  super.key, required,
  required this.onSaved
   });

  @override
  State<SizeFeatureDialog> createState() => _SizeFeatureDialogState();
}

class _SizeFeatureDialogState extends State<SizeFeatureDialog> {
  late Size size;
  late ThemeData theme;
  late Orientation orientation;
  @override
  void initState() {
    Future.delayed(const Duration(milliseconds: 200 ),(){
      _focusNode.requestFocus();
    });
    super.initState();
  }

  final FocusNode _focusNode = FocusNode();

  List<SizeFeature> listSizeModel =[];

  final _animatedListKey = GlobalKey<AnimatedListState>();
  final _sizeScroll = ScrollController();

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    theme = Theme.of(context);
    orientation = MediaQuery.of(context).orientation;
    final GlobalKey pressedKey = GlobalKey();
    return  PressedKeyListener(
      Gkey: pressedKey ,
      keyActions: {
        LogicalKeyboardKey.escape:(){scapeQuestion();},
        LogicalKeyboardKey.enter:(){addCard();},
        LogicalKeyboardKey.f4:(){f4Save();},
      },
        child: _body());
  }

  Widget _body(){
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children:[
        _head(),
        _middle(),
        _footer(),

      ],
    );
  }

  Widget _head(){
    return Container(
        height: size.height*0.06,
        width: size.width,
        margin: const EdgeInsets.only(bottom: 5, top: 20),
        decoration : BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: theme.colorScheme.primary),
            color: theme.colorScheme.surface
        ),
        child:
        Row(
          children: [
            const Spacer(),
            Text("Crear talla",
              style: TextStyle(
                  fontSize: 20,
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.bold
              ),
            ),
            const Spacer(),
            Tooltip(message:'Presione enter para añadir',
              child: ElevatedButton(
                style: ButtonStyle(
                  overlayColor: MaterialStateProperty.all(Colors.blue.withOpacity(0.5)),
                  backgroundColor: MaterialStateProperty.all(theme.colorScheme.background),
                  shape: MaterialStateProperty.all(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: theme.colorScheme.secondary, width: 2)
                  )),
                ),
                onPressed: (){addCard();},
                child: Row(
                  children: [
                    Tooltip( message:'Presione enter para añadir',
                        child: Text("Agregar",
                          style: TextStyle(
                              color: theme.colorScheme.onPrimary,
                              fontWeight: FontWeight.bold ))),
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

final ScrollController _gridSController =  ScrollController();
  final TextEditingController _tallaController = TextEditingController();
  final TextEditingController textController3 = TextEditingController();

  Widget _middle(){
    return Column(
      children: [
        _treeFormRow(
          MyTextfieldIcon(labelText: "Talla", textController: _tallaController, focusNode: _focusNode,),
          MyTextfieldIcon(labelText: "Referencia", textController: textController3),
        ),
        Container(
          height: size.height<700? size.height*.4:size.height*.40  ,
          width: size.width,
          margin: const EdgeInsets.only(bottom: 10, top: 5),
          padding: const EdgeInsets.all(5),
          decoration : BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(8)),
              border: Border.all(color: theme.colorScheme.primary),
              color: theme.colorScheme.surface
          ),
          child: listSizeModel.isEmpty? NoDataWidget(text: '"Vacio" Por favor inserte una talla ',)
              :Scrollbar(
                thickness: 5,
                thumbVisibility: true,
                radius: const Radius.circular(0),
                controller: _gridSController,
                child: FadingEdgeScrollView.fromAnimatedList(
                  gradientFractionOnEnd: .2, child:
                AnimatedList(
                  key: _animatedListKey,
                  controller:_sizeScroll ,
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
  Widget _footer(){
    return _fotterButtons();
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
            _animatedListKey.currentState?.removeItem(index, (context, animation) =>
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
                listSizeModel[index].nomenclatura,
                style: TextStyle(color: theme.colorScheme.onPrimary),)),
      ],
    ),
    );
}


  Widget  _fotterButtons(){
    return SizedBox(
      height: size.height*.05,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
          children:[
            ElevatedButton(
              style: ButtonStyle(
                overlayColor: MaterialStateProperty.all(ColorPalette.err),
              ),
                onPressed: (){
                  scapeQuestion();
                },
                child: Text("Cancelar( Esc )", style: TextStyle(color: theme.colorScheme.onPrimary),
                )
            ),
            ElevatedButton(
                style: ButtonStyle(
                  overlayColor: MaterialStateProperty.all(ColorPalette.ok),
                ),
                onPressed: (){f4Save();},
                child: Text("Guardar( F4 )", style: TextStyle(color: theme.colorScheme.onPrimary),)
            ),
          ]
      ),
    );
  }

  Widget _treeFormRow(Widget widget1, Widget widget2){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(width: size.width/6,child: widget1,),
        SizedBox(width: size.width/6,child: widget2,),
      ],
    );
  }

  void addCard(){
    if( listSizeModel.where((talla) => talla.size == _tallaController.text).isNotEmpty){
      MyCherryToast.showWarningSnackBar(context, theme, "Talla ya existe");
      Future.delayed(const Duration(milliseconds: 100),(){
        setState((){ _focusNode.requestFocus(); });
      });
    }else if(_tallaController.text.isEmpty){
      MyCherryToast.showWarningSnackBar(context, theme, "Talla no puede estar vacio");
      Future.delayed(const Duration(milliseconds: 100),(){ _focusNode.requestFocus(); });
    } else{
      _crateObjet();
    }
  }

  scapeQuestion(){
    if(listSizeModel.isNotEmpty ){
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

  void f4Save(){
    if( listSizeModel.first.size.isNotEmpty ){
      widget.onSaved(listSizeModel);
      Navigator.of(context).pop();
    }else {
      MyCherryToast.showWarningSnackBar(
          context,theme,'Al menos un campo debe de ser agregado');
    }
  }

  _crateObjet(){
      setState(() {
        listSizeModel.add(SizeFeature(
            size: _tallaController.text,
            nomenclatura: textController3.text));
        _tallaController.clear();
        textController3.clear();
      });
    _animatedListKey.currentState!.insertItem(listSizeModel.length-1);
    Future.delayed(const Duration(  milliseconds: 100 ),(){
    _focusNode.requestFocus();
    });
  }

}
class SizeFeature{
  String size;
  String nomenclatura;
  SizeFeature({
    required this.size,
    required this.nomenclatura
  });
}
