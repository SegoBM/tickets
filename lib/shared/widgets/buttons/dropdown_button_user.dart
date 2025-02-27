import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:tickets/pages/Tickets/CustomeAwesomeDialogTickets.dart';
import 'package:tickets/shared/utils/texts.dart';
import 'package:tickets/shared/utils/user_preferences.dart';
import 'package:tickets/shared/widgets/dialogs/custom_awesome_dialog.dart';

Widget myDropdownButtonUser(ThemeData theme, BuildContext context, [Color? colorAvatar,Color? colorAvatar2]) {
  return DropdownButtonHideUnderline(
    child: DropdownButton2(
      customButton: Container(width: 38,
        decoration: BoxDecoration(shape: BoxShape.circle,
          border: Border.all(
            color: colorAvatar??theme.colorScheme.tertiary, // Set border color
            width: 3.0, // Set border width
          ),
        ),
        child: CircleAvatar(
          backgroundColor:  colorAvatar??theme.colorScheme.secondary,
          radius: 20, // Adjust the size as needed
          backgroundImage: AssetImage('assets/avatarxl.png'), // Replace with your image path
        ),
      ),
      items: [
        ...MenuItems.firstItems.map(
              (item) => DropdownMenuItem<MenuItem>(
            value: item,
            child: MenuItems.buildItem(item),
          ),
        ),
      ],
      onChanged: (value) {
        MenuItems.onChanged(context, value! as MenuItem);
      },
      dropdownStyleData: DropdownStyleData(
        width: 160,
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color:colorAvatar?? theme.primaryColor,
        ),
        offset: const Offset(0, 8),
      ),
      menuItemStyleData: MenuItemStyleData(
        customHeights: [
          ...List<double>.filled(MenuItems.firstItems.length, 48),
        ],
        padding: const EdgeInsets.only(left: 16, right: 16),
      ),
    ),
  );
}

class MenuItem {
  const MenuItem({
    required this.text,
    required this.icon,
  });
  final String text;
  final IconData icon;
}
abstract class MenuItems {
  static const List<MenuItem> firstItems = [logout];
  static const logout = MenuItem(text: 'Cerrar sesión', icon: Icons.logout);
  static Widget buildItem(MenuItem item) {
    return Row(
      children: [
        Icon(item.icon,  size: 22,color: Colors.white),
        const SizedBox(
          width: 10,
        ),
        Expanded(
          child: Text(
            item.text, style: const TextStyle(fontSize: 14,color: Colors.white),
          ),
        ),
      ],
    );
  }

  static void onChanged(BuildContext context, MenuItem item) {
    switch (item) {
      case MenuItems.logout:
        CustomAwesomeDialogTickets(title: Texts.alertSignOff, width: MediaQuery.of(context).size.width>600?null:MediaQuery.of(context).size.width,
          desc: '', btnOkOnPress:() async {
            await UserPreferences().borrarUsuario();
            Navigator.of(context, rootNavigator: true).pushReplacementNamed('loginPage');
          },
          btnCancelOnPress: () {},).showQuestion(context);
        break;
    }
  }
}