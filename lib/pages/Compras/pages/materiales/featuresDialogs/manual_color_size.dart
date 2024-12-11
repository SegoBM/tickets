import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tickets/shared/actions/key_raw_listener.dart';
import 'package:tickets/shared/widgets/Snackbars/cherryToast.dart';
import 'package:tickets/shared/widgets/error/customNoData.dart';

import '../../../../../config/theme/app_theme.dart';
import '../../../../../shared/Automations/st_mathod.dart';
import '../../../../../shared/utils/color_palette.dart';
import '../../../../../shared/utils/texts.dart';
import '../../../../../shared/widgets/card/my_swipe_tile_card.dart';
import '../../../../../shared/widgets/dialogs/custom_awesome_dialog.dart';
import '../../../../../shared/widgets/dropDowns/flat_drop.dart';
import '../../../../../shared/widgets/textfields/my_textfield_icon.dart';

class ManualColorSize extends StatefulWidget {
  Function(List<Combination>) onSaved;
   ManualColorSize({ required this.onSaved, super.key});

  @override
  State<ManualColorSize> createState() => _ManualColorSizeState();
}

class _ManualColorSizeState extends State<ManualColorSize> {

  late Size size; late ThemeData theme;
  final _pressedKeyListener = GlobalKey();

  final colorController = TextEditingController();
  final referenciaColorController = TextEditingController();
  final referenciaOrigenController = TextEditingController();
  final _tallaEController = TextEditingController();
  final gridScroll = ScrollController();
  List<Combination>objList=[];
  final inputController = TextEditingController();
  final dialogController = TextEditingController();


  List<TextEditingController> addControllerList = [TextEditingController()];
  final scrollControllerTalla = ScrollController();
//
// List<ColorCombination> colorList = [];
// List<SizeCombination> tallaList = [];
List<String>  tallaNomenclatura  = ["Unidad", "Cm", "Mts", "Pulgadas", "Pies", "Yardas"];
String selectedNomenclatura = "Unidad";

List<String> tallaList = [];
String input = '';
final automaticIFocus = FocusNode();
final colorFocustext = FocusNode();
final tallaFocustext = FocusNode();
final focusEditColor = FocusNode();

final _formKey = GlobalKey<FormState>();
int index =0;

@override
  void initState() {
  Future.delayed(const Duration( milliseconds: 400 ),(){
    colorFocustext.requestFocus();
  });
    super.initState();
  }

@override
  void dispose() {
    colorFocustext.dispose();
    objList.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    theme = Theme.of(context);
    return PressedKeyListener(
      Gkey: _pressedKeyListener,
        keyActions: {
        LogicalKeyboardKey.escape:(){
          Navigator.of(context).pop();
        },LogicalKeyboardKey.enter:() async  {
            await dialogNSave();
        },},
        child: _body());
  }

  Widget _body (){
    return Column(
      children: [
        _top(),
        _middle(),
        const Spacer(),
        _footer(),
      ],
    );
  }

 Widget _top(){
    return Container(
      height: size.height *.07,width: size.width,
        margin: const EdgeInsets.only(bottom: 10, top: 20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8)
      ),
      child:  Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          Text("Color y Talla ( Corridas )",
          style: TextStyle(fontSize: 20,
          color: theme.colorScheme.onPrimary,
      fontWeight: FontWeight.bold),),
        const Spacer(),
          addButton(),
          const Spacer(),
        ]
      ),
    );
  }



  Widget _middle(){
    return Column(
      children: [
        _treeFormRow(
          MyTextfieldIcon(
            labelText: "Color",
            textController: colorController,
            focusNode: colorFocustext,
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
        const SizedBox(height: 10,),
        generateList(),

        ]);
        //vistaTextFields(),
  }

  Widget generateList(){
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      transitionBuilder: (Widget child, Animation<double> animation){
        return FadeTransition(
          opacity: animation,
          child:child,
        );
      },
      child: objList.isEmpty?
      Container(
        key: const ValueKey("empty"),
        height: size.height*.37,
       decoration: BoxDecoration(
         color: theme.colorScheme.surface,
          borderRadius:
          const BorderRadius.only(
            bottomLeft: Radius.circular(8),
            bottomRight: Radius.circular(8),
          )
       ),
       child: NoDataWidget(
         text: "'Vacío' Ingrece un color y talla para agregar a la lista",),
     ):
       Container(
          key: const ValueKey("list"),
      height: size.height*.37,
      width: size.width,
      margin: const EdgeInsets.only(top: 10, bottom: 10),
      decoration : BoxDecoration(
       border: Border.all(color: theme.colorScheme.primary),
       color: theme.colorScheme.surface,
       borderRadius: BorderRadius.circular(8),),
     child: Scrollbar(
       controller: scrollControllerTalla,
       child: FadingEdgeScrollView.fromScrollView(
           child: ListView.builder(
               controller:scrollControllerTalla,
               itemCount: objList.length,
               itemBuilder: ( context, index ){
                 return _card(index, objList[index]);
               }
           )
       ),
     ),
     ));
  }

   Widget _card(index, Combination obj,){
    return GestureDetector(
      onTapDown: (TapDownDetails details){
        print("tapped");
        _showDeleteDialog(details.globalPosition, index);
      },
      child: MySwipeTileCard(
          radius: 8,horizontalPadding: 1,verticalPadding:5,
          colorBasico: index%2==0? theme.colorScheme.background
              : ( theme.colorScheme == GlobalThemData.lightColorScheme
              ? ColorPalette.backgroundLightColor:ColorPalette.backgroundDarkColor),
          onTapLR: ( TapDownDetails details ){
            _showDeleteDialog(details.globalPosition, index);
          },
          onTapRL: ()  {
            setState(() {
            objList.removeAt(index);
            });
          },
        containerB: Padding(

          padding: const EdgeInsets.symmetric( horizontal: 20 ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              const SizedBox( width: 10,),
              SizedBox( width: size.width/10, child: Text(obj.color, style: TextStyle(color: theme.colorScheme.onPrimary, fontSize: 14),)),
              SizedBox( width: size.width/15, child: Text(obj.talla, style: TextStyle(color: theme.colorScheme.onPrimary, fontSize: 14),overflow: TextOverflow.ellipsis,)),
              const SizedBox( width: 10,),
            ],
          ),
        ),
      ),
    );
  }

 _showDeleteDialog(Offset position, index) async  {
  return await showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
          position.dx,
          position.dy,
          position.dx,
          position.dy
      ),
      items: [
        PopupMenuItem(
          child: ListTile(
            title:  Text("Eliminar",style: TextStyle(color: theme.colorScheme.onPrimary, fontSize: 14),),
            onTap: (){
              objList.removeAt(index);
              setState(() {});
              Navigator.of(context).pop();
            },
          ),
        ),
        PopupMenuItem(
          child: ListTile(
            title: Text("Editar",style: TextStyle(color: theme.colorScheme.onPrimary, fontSize: 14),),
            onTap: (){
              Navigator.of(context).pop();
             showDialog(context: context,
                 barrierDismissible: false,
                builder: (context,){
                return editColorDialog(index);
                }
            );
            },
          ),
        ),
      ]
  );
}
Widget editColorDialog(index){
  fillEditControllers(index);
  Future.delayed(const Duration(milliseconds: 400),(){
  focusEditColor.requestFocus();
  });
  return Dialog(insetAnimationCurve: Curves.bounceIn,
    key: const ValueKey("edit"),
    insetAnimationDuration: const Duration(milliseconds: 1000),
    child: Container(
      padding: const EdgeInsets.all(20),
      width: size.width*.21,height: size.height*.44,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Container(
            height: 30,
            decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            ),
            width: size.width/5,
            margin: const EdgeInsets.only(bottom: 10),
            child:
            Row( mainAxisAlignment: MainAxisAlignment.center,
              children: [
              Text("Edición", style: TextStyle(color: theme.colorScheme.onPrimary, fontSize: 16),),
            ],),
          ),
          SizedBox(width: size.width/5,
            child: MyTextfieldIcon(
              labelText: 'Color', textController: _editColorController,
              focusNode: focusEditColor,
            ),),
            SizedBox(width: size.width/4.9,
            child: MyTextfieldIcon(
              labelText: 'Referencia', textController: _editReferenciaController,
            ),),
            SizedBox(width: size.width/4.9,
            child: MyTextfieldIcon(
              labelText: 'Referencia Color', textController: _editReferenciaColorController,
            ),),
          SizedBox(width: size.width/4.9,
            child: MyTextfieldIcon(
              labelText: 'Talla', textController: _editTallaController,
              autoSelectText: true,
                focusNode: tallaFocustext,

              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9a-zA-Z,-]')), // Permite letras, números, comas y guiones
              ],
              validator: (value){
                if (value == null || value.isEmpty) {
                  return 'El campo no puede estar vacío';
                }
                // Expresión regular para validar el formato correcto
                final pattern = RegExp(r'^[0-9a-zA-Z]+([,-][0-9a-zA-Z]+)*$');
                if (!pattern.hasMatch(value)) {
                  return 'Formato inválido. Ejemplo válido: 1,3,A-C,5-8';
                }
                return null;
              },
            ),),
          const SizedBox(height: 10,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                style: ButtonStyle(
                  overlayColor: MaterialStateProperty.all(ColorPalette.err),),
                onPressed: () {
                  Navigator.pop(context);
                  cleanControllers();
                },
                child: Text("Cancelar", style: TextStyle( color: theme.colorScheme.onPrimary,fontSize: 14),),),
              Tooltip(
                message: 'Este campo acepta intervalos entre tallas, y números.\nEjemplo: (5-26) | (M-XXL) | (1,3,5).\nResultando  en una corrida de estos valores.',
                child: Container(

                  decoration: BoxDecoration(
                    border: Border.all(color: theme.colorScheme.onPrimary),
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  height: 30, width: 30,
                  alignment: Alignment.centerRight,
                  child: Center(child: Icon( Icons.question_mark_outlined, color: theme.colorScheme.onPrimary,size: 15, )),),
              ),
              ElevatedButton(
                  style: ButtonStyle(
                    overlayColor: MaterialStateProperty.all(ColorPalette.ok),
                  ),
                  onPressed: () async {
                    objList[index].color = _editColorController.text;
                    objList[index].referenciaColor = _editReferenciaController.text;
                    objList[index].referenciaColorOrigen = _editReferenciaColorController.text;
                    objList[index].talla = parseInputToList(_editTallaController.text).join(',').toString();
                    setState(() {});
                    Navigator.pop(context);
                    cleanControllers();
                  },
                  child: Text("Guardar",
                    style: TextStyle(
                        color: theme.colorScheme.onPrimary, fontSize: 14),)
              ),

            ],
          ),
        ],
      ),
    ),
    );
}
late final _editColorController = TextEditingController();
final _editReferenciaController = TextEditingController();
final _editReferenciaColorController = TextEditingController();
final  _editTallaController = TextEditingController();

void fillEditControllers(index){
  _editColorController.text = objList[index].color;
  _editReferenciaController.text = objList[index].referenciaColor;
  _editReferenciaColorController.text = objList[index].referenciaColorOrigen;
  _editTallaController.text = objList[index].talla;
}
void cleanControllers(){
  _editColorController.clear();
  _editReferenciaController.clear();
  _editReferenciaColorController.clear();
  _editTallaController.clear();
}

  Widget _footer(){
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children:[
          ElevatedButton(
              style: ButtonStyle(
                overlayColor: MaterialStateProperty.all(ColorPalette.err),
              ),
              onPressed: (){  CustomAwesomeDialog(
                title: Texts.lostData,
                desc: Texts.lostData,
                btnCancelOnPress: () {},
                btnOkOnPress: () {
                  Navigator.of(context).pop();
                },).showQuestion(context);},
              child: Text("Cancelar(Esc)", style: TextStyle(color: theme.colorScheme.onPrimary, fontSize: 14),
              )
          ),
          ElevatedButton(
              style: ButtonStyle(
                overlayColor: MaterialStateProperty.all(ColorPalette.ok),
              ),
              onPressed: (){
                saveObj();
                print( "on Saved ${objList.toString()}" );
                widget.onSaved(objList);
                Future.delayed(const Duration(milliseconds: 400), (){
                Navigator.of(context).pop();
                });
              },
              child: Text("Guardar( F4 )", style: TextStyle(color: theme.colorScheme.onPrimary, fontSize: 14),)
          ),
        ]
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


Widget gridView(index, TextEditingController controller){
          return SizedBox(
            width: size.width*.10,
            child: MyTextfieldIcon(
              backgroundColor: theme.colorScheme.primary,
              labelText: 'Talla ${index+1}',
              textController: controller,
            ),
          );
}


List<TextEditingController> field = [];
  addingTextEditingController(){
    field.add(TextEditingController());
    addControllerList = field;
    addControllerList.map((e) => e.text).toList();
    print(addControllerList.toString());
    setState(() {});
  }

  Widget addButton(){
    return  Tooltip(
      message: "Presione para agregar un nuevo campo",
      child: ElevatedButton(
        style: ButtonStyle(
          overlayColor: MaterialStateProperty.all(Colors.blue.withOpacity(0.5)),
          backgroundColor: MaterialStateProperty.all(theme.colorScheme.background),
          shape: MaterialStateProperty.all(RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: theme.colorScheme.secondary, width: 2)
          )),
        ),
        onPressed: ()async {
          if(objList.where((obj)=>obj.color==colorController.text).isNotEmpty){
            MyCherryToast.showWarningSnackBar(context, theme,
                "El color ya existe en la lista.\nPor favor ingrese otro color para continuar.");
            Future.delayed(const Duration( milliseconds: 400 ),(){
              colorFocustext.requestFocus();
            });
          }else {
            if( colorController.text.isEmpty ){
              MyCherryToast.showWarningSnackBar(context, theme, "Porfavor de llenar campo 'Color'");
              Future.delayed(const Duration( milliseconds: 400),(){
                colorFocustext.requestFocus();
              });
            }else{
            await dialogNSave();
            saveObj();

            }
          }
        },
        child: Row(
          children: [
            Text("Agregar", style: TextStyle(
                color: theme.colorScheme.onPrimary,
                fontWeight: FontWeight.bold
            ),
            ),
            Icon(Icons.add, color: theme.colorScheme.onPrimary,
            )
          ],
        ),
      ),
    );
  }


  void saveObj(){
   if(colorController.text.isNotEmpty){
     objList.add(Combination(
       color: colorController.text,
       referenciaColor: referenciaColorController.text,
       referenciaColorOrigen: referenciaOrigenController.text,
       talla: input,
     ));
     print(objList.toString());
     // inputAutomationResult().clear();
   }
    setState(() {});
    colorController.clear();
  }

  Widget vistaTextFields(){
    return Scrollbar(
      controller: gridScroll,
      thumbVisibility: true,
      child:
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            for (int i = 0; i < addControllerList.length; i++)
              gridView(i, addControllerList[i]),
          ],
        ),
    );
  }

Future dialogNSave() async {
    Future.delayed( const Duration(milliseconds: 300),(){
      automaticIFocus.requestFocus();
    } );
       final inputResultDialog = await showDialog(
        context: context,
        builder: (context)=> Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0),),
          child:Container(
              width: 400, height:170 , padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      SizedBox( width: size.width*.18,
                        child: MyTextfieldIcon(labelText: 'Teclea un rango de tallas', textController: dialogController,
                          keyboardType: TextInputType.text,
                          focusNode: automaticIFocus,
                          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9a-zA-Z,-]')), // Permite letras, números, comas y guiones
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'El campo no puede estar vacío';
                            }
                            // Expresión regular para validar el formato correcto
                            final pattern = RegExp(r'^[0-9a-zA-Z]+([,-][0-9a-zA-Z]+)*$');
                            if (!pattern.hasMatch(value)) {
                              return 'Formato inválido. Ejemplo válido: 1,3,A-C,5-8';
                            }
                            return null; // El formato es válido
                          },
                        ),
                      ),
                      Tooltip(
                        message: 'Este campo acepta intervalos entre tallas, y números.\nEjemplo: (5-26) | (M-XXL) | (1,3,5).\nResultando  en una corrida de estos valores.',
                        child: Container(

                          decoration: BoxDecoration(
                            border: Border.all(color: theme.colorScheme.onPrimary),
                            color: theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          height: 30, width: 30,
                          alignment: Alignment.centerRight,
                          child: Center(child: Icon( Icons.question_mark_outlined, color: theme.colorScheme.onPrimary,size: 15, )),),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all( theme.colorScheme.primary),
                      overlayColor: MaterialStateProperty.all(ColorPalette.ok),
                    ),
                    onPressed: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        final text = dialogController.text;
                        print(text);
                        final result = parseInputToList(text);
                        // Aquí obtienes la lista resultante
                        // Puedes hacer algo con 'result' según tus necesidades
                        print('this the result $result');
                        Navigator.of(context).pop(result);
                        dialogController.clear();
                      }
                    },
                    child: Text('Guardar',style: TextStyle( color: theme.colorScheme.onPrimary, fontSize: 13 ,fontWeight: FontWeight.bold ),),
                  ),
                ],),)
          ),
        )
    );
    if(inputResultDialog != null){
      print("holi$inputResultDialog");
      input = inputResultDialog.join(',');
    }
}

}

class Combination{
  String color;
  String referenciaColor;
  String referenciaColorOrigen;
  String talla;
  Combination({
    required this.color,
    required this.referenciaColor,
    required this.referenciaColorOrigen,
    required this.talla,
  });

}



