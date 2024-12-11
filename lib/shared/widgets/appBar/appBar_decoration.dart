import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tickets/shared/utils/icon_library.dart';
import 'package:tickets/shared/utils/user_preferences.dart';
import 'package:tickets/shared/widgets/buttons/dropdown_button_user.dart';
import 'package:url_launcher/url_launcher.dart';
class MyAppBarDesktop extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? suffixWidget;
  final BuildContext context;
  final bool backButton;
  BorderRadiusGeometry borderRadius;
  bool defaultButtons;
  Widget? backButtonWidget;
  double? padding;
  double? height;
  MyAppBarDesktop({
    required this.title,
    this.suffixWidget,
    this.borderRadius = const BorderRadius.vertical(bottom: Radius.circular(15)),
    this.defaultButtons = true,
    required this.context,
    required this.backButton,
    this.backButtonWidget,
    this.padding,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(45), // Adjust the height as needed
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: padding?? MediaQuery.of(context).size.width/7,), // Adjust the padding as needed
        child: AppBar(
          primary: false,
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
          automaticallyImplyLeading: false,
          backgroundColor: Theme.of(context).primaryColor,
          title: Text(title),
          actions: [
            suffixWidget?? const SizedBox(),
            if(defaultButtons)...[
              Tooltip(
                waitDuration: const Duration(milliseconds: 500),
                message: "Acceso directo a tickets",
                child:Container(
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(context).colorScheme.tertiary, // Set border color
                        width: 3.0, // Set border width
                      ),
                    ),
                    child: InkWell(
                      onTap: () async {
                        const url = 'https://tickets.shimaco.online:91/';
                        Uri uri = Uri.parse(url);
                        if (!await launchUrl(uri, mode: LaunchMode.externalApplication,))
                        {throw Exception('Could not launch $url');}
                      },
                      child: CircleAvatar(
                        backgroundColor:  Theme.of(context).colorScheme.secondary,
                        radius: 15, // Adjust the size as needed
                        child: Icon(IconLibrary.iconTicket, color: Theme.of(context).backgroundColor,),// Replace with your image path
                      ),)),
              ),
              FutureBuilder<String>(
                future: getUserName(),
                builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                  if (snapshot.hasError) {
                    return Container(
                      margin: const EdgeInsets.only(right: 10),
                      child: myDropdownButtonUser(Theme.of(context), context),
                    );
                  } else {
                    return Container(
                      margin: const EdgeInsets.only(right: 10),
                      child: Tooltip(
                        waitDuration: const Duration(milliseconds: 500),
                        message: "Usuario: ${snapshot.data}",
                        child: myDropdownButtonUser(Theme.of(context), context),
                      ),
                    ); // Muestra el nombre de usuario una vez obtenido
                  }
                },
              ),
            ]
          ],
          centerTitle: true,
          leading: backButton? (backButtonWidget?? IconButton(
            icon: const Icon(IconLibrary.iconBack),
            onPressed: () {
              Navigator.of(context).pop();
            },
          )) : const SizedBox(),
        ),
      ),
    );
  }
  Future<String> getUserName() async {
    String user = await UserPreferences().getUsuarioNombre();
    return user;
  }
  @override
  Size get preferredSize => Size.fromHeight(height?? (Platform.isAndroid || Platform.isIOS? 16:45)); // Adjust the height as needed
}
class MyAppBarMobile extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? suffixWidget;
  final BuildContext context;
  final bool backButton;

  MyAppBarMobile({
    required this.title,
    this.suffixWidget,
    required this.context,
    required this.backButton,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(15))
      ),
      automaticallyImplyLeading: false,
      backgroundColor: Theme.of(context).primaryColor,
      title: Text(title),
      actions: [
        suffixWidget ?? const SizedBox(),
      ],
      centerTitle: true,
      leading: backButton ? IconButton(
        icon: const Icon(IconLibrary.iconBack),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ) : Builder(
        builder: (context) => IconButton(
          icon: const Icon(IconLibrary.iconMenu),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(45);
}
