import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tickets/models/ConfigModels/usuario.dart';
import 'package:tickets/shared/utils/color_palette.dart';
import 'package:tickets/shared/utils/icon_library.dart';
import 'package:tickets/shared/utils/user_preferences.dart';
import 'package:tickets/shared/widgets/buttons/dropdown_button_user.dart';
import '../../../pages/Tickets/CustomeAwesomeDialogTickets.dart';
import '../../utils/texts.dart';
import '../dialogs/custom_awesome_dialog.dart';
class MyCustomAppBarDesktop extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? suffixWidget;
  final BuildContext context;
  final bool backButton;
  BorderRadiusGeometry borderRadius;
  bool defaultButtons;
  bool defaultButtonT;
  Widget? backButtonWidget;
  double? padding;
  double? height;
  Color? color;
  Color? textColor;
  String? rute;
  Color? extracolor;
  Color? extracolor2;
  bool? ticketsFlag;
  MyCustomAppBarDesktop({
    required this.title,
    this.suffixWidget,
    this.borderRadius = const BorderRadius.vertical(bottom: Radius.circular(15)),
    this.defaultButtonT = false,
    this.defaultButtons = true,
    required this.context,
    required this.backButton,
    this.backButtonWidget,
    this.padding,
    this.height,
    this.color,
    this.textColor,
    this.rute,
    this.extracolor,
    this.extracolor2,
    this.ticketsFlag=true,
  });
  late ThemeData themeData;
  @override
  Widget build(BuildContext context) {
    themeData = Theme.of(context);
    return PreferredSize(
      preferredSize: const Size.fromHeight(45), // Adjust the height as needed
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: padding?? MediaQuery.of(context).size.width/7.5,), // Adjust the padding as needed
        child: Container(height: height,
          decoration: BoxDecoration(borderRadius: borderRadius, color: color?? themeData.primaryColor,),
          child: Padding(padding: const EdgeInsets.symmetric(horizontal: 10),child:
            Stack(children: [
                Align(alignment: Alignment.centerLeft,
                  child: backButton?
                  (backButtonWidget ??
                      TextButton.icon(icon: Icon(IconLibrary.iconX,),
                        label: Text("Cerrar"),
                        style: TextButton.styleFrom(iconColor: ColorPalette.accentColor, // Change icon color
                          primary: themeData.colorScheme.onPrimary,
                          backgroundColor: Colors.transparent, // Color de fondo
                        ),
                        onPressed: () {
                          CustomAwesomeDialog(title: Texts.alertExit,
                            desc: Texts.lostData, btnOkOnPress: (){Navigator.of(context).pop();},
                            btnCancelOnPress: (){}).showQuestion(context);
                        },
                      ))
                      : const SizedBox(),
                ),
                Align(alignment: Alignment.center,
                  child: Text(title, style:  TextStyle(fontSize: 20,color: textColor),),
                ),
                Align(alignment: Alignment.centerRight,
                  child: Row(mainAxisSize: MainAxisSize.min,
                    children: [
                      suffixWidget ?? const SizedBox(),
                      if(ticketsFlag==true)...{
                        if (defaultButtons) ...[
                          Tooltip(waitDuration: const Duration(milliseconds: 500), message: "Acceso directo a tickets",
                            child: Container(
                              margin: const EdgeInsets.only(right: 10),
                              decoration: BoxDecoration(shape: BoxShape.circle,
                                border: Border.all(color: extracolor?? themeData.colorScheme.tertiary,width: 3.0,),
                              ),
                              child: InkWell(
                                onTap: () async {
                                  print(rute);
                                  Navigator.of(this.context).pushNamed(rute??'TicketsHome');
                                },
                                child: CircleAvatar(backgroundColor:extracolor2??themeData.colorScheme.secondary,
                                  radius: 15, // Adjust the size as needed
                                  child: Icon(IconLibrary.iconTicket, color:extracolor?? themeData.backgroundColor,),// Replace with your image path
                                ),
                              ),
                            ),
                          ),
                          FutureBuilder<UsuarioModels>(
                            future: getUserName(),
                            builder: (context, snapshot) {
                              if (snapshot.hasError) {
                                return Container(child: myDropdownButtonUser(themeData, context),);
                              } else {
                                if(snapshot.hasData){
                                  return Tooltip(waitDuration: const Duration(milliseconds: 500),
                                    message: "Usuario: ${snapshot.data!.nombre}\nEmpresa: ${snapshot.data!.empresaNombre}",
                                    child: myDropdownButtonUser(themeData, context),
                                  ); // Muestra el nombre de usuario una vez obtenido
                                }else{
                                  return myDropdownButtonUser(themeData, context);
                                }
                              }
                            },
                          ),
                        ]
                        else if (defaultButtonT) ...[
                          Tooltip(waitDuration: const Duration(milliseconds: 500),
                            message: "Generar reporte de tickets",
                            child: Container(margin: const EdgeInsets.only(right: 10),
                              decoration: BoxDecoration(shape: BoxShape.circle,
                                border: Border.all(color: ColorPalette.ticketsSelectedColor, width: 3.0,),
                              ),
                              child: InkWell(
                                onTap: () async {Navigator.of(this.context).pushNamed('TicketsHome');},
                                child: CircleAvatar(
                                  backgroundColor:ColorPalette.ticketsSelectedColor, radius: 15, // Adjust the size as needed
                                  child: Icon(IconLibrary.documentScanner, color: Colors.white,),// Replace with your image path
                                ),
                              ),
                            ),
                          ),
                          FutureBuilder<UsuarioModels>(
                            future: getUserName(),
                            builder: (context, snapshot) {
                              if (snapshot.hasError) {
                                return Container(
                                  child: myDropdownButtonUser(themeData, context),
                                );
                              } else {
                                if(snapshot.hasData){
                                  return Tooltip(waitDuration: const Duration(milliseconds: 500),
                                    message: "Usuario: ${snapshot.data!.nombre}\nEmpresa: ${snapshot.data!.empresaNombre}",
                                    child: myDropdownButtonUser(themeData, context),
                                  ); // Muestra el nombre de usuario una vez obtenido
                                }else{
                                  return myDropdownButtonUser(themeData, context);
                                }
                              }
                            },
                          ),
                        ]
                      }else...[
                        FutureBuilder<UsuarioModels>(
                          future: getUserName(),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return Container(
                                child: myDropdownButtonUser(themeData, context),
                              );
                            } else {
                              if(snapshot.hasData){
                                return Tooltip(waitDuration: const Duration(milliseconds: 500),
                                  message: "Usuario: ${snapshot.data!.nombre}\nEmpresa: ${snapshot.data!.empresaNombre}",
                                  child: myDropdownButtonUser(themeData, context,ColorPalette.ticketsColor),
                                ); // Muestra el nombre de usuario una vez obtenido
                              }else{
                                return myDropdownButtonUser(themeData, context,ColorPalette.ticketsColor);
                              }
                            }
                          },
                        ),
                      ]

                    ],
                  ),
                ),
              ],
            ),)
        ),
      ),
    );
  }
  Future<UsuarioModels> getUserName() async {
    UsuarioModels user = await UserPreferences().getUsuario();
    return user;
  }
  @override
  Size get preferredSize => Size.fromHeight(height?? (Platform.isAndroid || Platform.isIOS? 16:45)); // Adjust the height as needed
}
class MyCustomAppBarMobile extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? suffixWidget;
  final BuildContext context;
  final bool backButton;
  final Color? backgroundColor;
  final bool? ticketsFlag;
  final bool? confirm;
  final Color? color;
  final double? size;
  final bool? confirmButton;
  final bool? tickets;

  MyCustomAppBarMobile({
    required this.title,
    this.suffixWidget,
    required this.context,
    required this.backButton,
    this.backgroundColor,
    this.ticketsFlag = false,
    this.confirm = false,
    this.color,
    this.size,
    this.confirmButton = true,
    this.tickets = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      shape: RoundedRectangleBorder(
          borderRadius: ticketsFlag== true ? const BorderRadius.vertical(bottom: Radius.circular(0))
          : const BorderRadius.vertical(bottom: Radius.circular(15))
      ),
      automaticallyImplyLeading: false,
      backgroundColor:backgroundColor?? Theme.of(context).primaryColor,
      title: Text(title, style: TextStyle(color: color ?? Theme.of(context).colorScheme.onSecondary,
          fontSize: size?? 18,),
      ),
      actions: [suffixWidget ?? const SizedBox()],
      centerTitle: true,
      leading: backButton ? IconButton(
        icon: Icon(IconLibrary.iconBack,color: color?? Theme.of(context).colorScheme.onSecondary,),
        onPressed: () {
          if(Platform.isAndroid || Platform.isIOS){
            HapticFeedback.vibrate();
          }
          handleBackButton();
        },
      ) : Builder(
        builder: (context) => IconButton(icon: const Icon(IconLibrary.iconMenu),
          onPressed: () {Scaffold.of(context).openDrawer();},
        ),
      ),
    );
  }

  void handleBackButton() {
    if (confirmButton == true) {
      if (confirm == true) {
        if (tickets == true) {
          CustomAwesomeDialogTickets(
            title: Texts.alertExit,
            width: MediaQuery.of(context).size.width * 0.9,
            desc: Texts.lostData,
            btnOkOnPress: () {
              Navigator.of(context).pushNamed('UsersScreen');
            },
            btnCancelOnPress: () {},
          ).showQuestion(context);
        } else {
          CustomAwesomeDialog(
            title: Texts.alertExit,
            width: MediaQuery.of(context).size.width * 0.9,
            desc: Texts.lostData,
            btnOkOnPress: () {
              Navigator.of(context).pushNamed('UsersScreen'); // Navegar a la nueva pestaña
            },
            btnCancelOnPress: () {},
          ).showQuestion(context);
        }
      } else {
        Navigator.of(context).pop();
      }
    } else {
      Navigator.of(context).pop();
    }
  }
  @override
  Size get preferredSize => const Size.fromHeight(45);
}
