import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tickets/shared/actions/key_raw_listener.dart';

import '../../../../../shared/actions/my_show_dialog.dart';
import 'clave_unidad_dialog.dart';

class MiddleDialogContainer extends StatefulWidget {

  const MiddleDialogContainer({super.key});

  @override
  State<MiddleDialogContainer> createState() => _MiddleDialogContainerState();
}

class _MiddleDialogContainerState extends State<MiddleDialogContainer> {
  late ThemeData theme; late Size size;
final  _presKey = GlobalKey();
final  _dialogKey = GlobalKey();
final _keyController = TextEditingController();
  @override
  Widget build(BuildContext context) {
theme = Theme.of(context);
size= MediaQuery.of(context).size;
    return PressedKeyListener(
      Gkey: _presKey,
        keyActions: {
        LogicalKeyboardKey.escape:(){

        }
        },
        child: Column(children: [
          title(),
          const SizedBox(height: 10,),
          middle(),
        ],),
    );
  }

  Widget title(){
    return Container(
      height: size.height*.06,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.all(Radius.circular(8)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          const SizedBox( width: 10, ),
          const Text("Clave Unidad"),
          const Spacer(),
          IconButton(onPressed: (){
            Navigator.of(context).pop(context);
          }, icon: const Icon(Icons.close, color: Colors.red,)),
          const SizedBox(width: 5,)
        ],
      ),
    );
  }

  Widget middle(){
    return Row(
mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _keyRecipe(),
         const SizedBox( width: 100, ),
        _dialogoClaveUnidad()
      ],
    );
  }

  Widget _getIcon(){
    return SizedBox(
      height: 60,width: 52,
      child: IconButton(
        onPressed: (){
        },
        icon:Icon(Icons.vpn_key, color: theme.colorScheme.onPrimary,),
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(theme.colorScheme.secondary),
          padding: MaterialStateProperty.all<EdgeInsets>(const EdgeInsets.all(5)),
          shape: MaterialStateProperty.all <RoundedRectangleBorder> (
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          ),
        ),
      ),
    );
  }

Widget _keyRecipe(){
    return SizedBox(
      width: 260,
      child:  TextFormField(
        controller: _keyController,
        enabled: false,
        decoration: InputDecoration(
          suffixIcon: const Icon(Icons.money), labelStyle: TextStyle(color: theme.colorScheme.onPrimary),
          labelText: 'Clave Unidad',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: theme.colorScheme.onPrimary  )),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: theme.colorScheme.onPrimary)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: theme.colorScheme.onPrimary)),
        ),

        style: TextStyle(color: theme.colorScheme.onPrimary),
      ),
    );
}

  Widget _dialogoClaveUnidad(){
    return SizedBox(
      height: 50,width: 50,
      child: IconButton(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(theme.colorScheme.secondary),
          padding: MaterialStateProperty.all<EdgeInsets>(const EdgeInsets.all(5)),
          shape: MaterialStateProperty.all <RoundedRectangleBorder> (
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        onPressed: () async {
          final result = await myShowDialogScale(
            const ClaveUnidadDialog(),
            context,
            height:size.height*.70,
            width: size.width*.40,
            key: _dialogKey,
          );
          if(result != null){
            print("Result: $result");
            result as String;
            setState(() {
            _keyController.text = result;
            });
          }
          },
        icon: Icon( Icons.add,
          color: theme.colorScheme.onPrimary,
          size: 30,
        ),
      ),
    );
  }
}
