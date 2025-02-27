import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tickets/models/ConfigModels/usuario.dart';
import 'package:tickets/pages/Tickets/loadingDialogTickets.dart';
import 'package:tickets/pages/Tickets/ticket_registration_screen.dart';
import 'package:tickets/pages/Tickets/tickets_levantados.dart';
import 'package:tickets/pages/Tickets/tickets_recibidos.dart';
import 'package:tickets/shared/actions/handleException.dart';
import 'package:tickets/shared/utils/color_palette.dart';
import 'package:tickets/shared/utils/icon_library.dart';
import 'package:tickets/shared/utils/texts.dart';
import 'package:tickets/shared/utils/user_preferences.dart';
import 'package:tickets/shared/widgets/Snackbars/customSnackBar.dart';
import 'package:tickets/shared/widgets/appBar/Tickets/appBarDecorationTickets.dart';
import 'package:tickets/shared/widgets/appBar/my_appBar.dart';
import 'package:tickets/shared/widgets/bar/Tickets/sidebarTickets.dart';
import 'package:tickets/shared/widgets/bar/sidebar_group_item.dart';
import 'package:tickets/shared/widgets/bar/sidebar_item.dart';
import 'package:tickets/shared/widgets/dialogs/custom_awesome_dialog.dart';
import '../../controllers/ConfigControllers/areaController.dart';
import '../../controllers/ConfigControllers/usuarioPermisoController.dart';
import '../../models/ConfigModels/area.dart';
import '../../models/ConfigModels/empresa.dart';
import '../../models/ConfigModels/usuarioPermiso.dart';
import '../../shared/actions/my_show_dialog.dart';
import 'CustomeAwesomeDialogTickets.dart';
import 'Tickets_recibidos_Admin.dart';
import 'tickets_home_screen.dart';

class TicketHomeScreen extends StatefulWidget {
  static String id = 'TicketsHome';
  const TicketHomeScreen({super.key});
  @override
  State<TicketHomeScreen> createState() => _TicketHomeScreen();
}


class _TicketHomeScreen extends State<TicketHomeScreen> {
  late List<SidebarGroupItem> _items;
  bool admin = false;
  late String _headline;
  late ThemeData theme; late BuildContext context2; late Size size;
  List<SidebarGroupItem> get _generateItems {
    List<SidebarGroupItem> items = [];
    items.add(SidebarGroupItem(text: "Tickets", items: [
      SidebarItem(
        text: 'Dashboard',
        icon: IconLibrary.iconDashboard,
        isSelected: true,
        onPressed: () {
          setState(() => _headline = 'Dashboard');
          navigatorKey.currentState!.pushReplacementNamed('TicketsHomeScreen');
        },
        onHold: () {
          CustomSnackBar.showInfoSnackBar(context, "Dashboard");
        },
      ),
      SidebarItem(
        text: 'Recibidos',
        icon: IconLibrary.iconTicket,
        isSelected: false,
        onPressed: () {
          setState(() => _headline = 'Dashboard');
          navigatorKey.currentState!
              .pushReplacementNamed('TicketsRecibidosScreen');
        },
        onHold: () {
          CustomSnackBar.showInfoSnackBar(context, "Dashboard");
        },
      ),
      // SidebarItem(
      //   text: 'Tickets',
      //   icon: IconLibrary.iconStar,
      //   isSelected: false,
      //   onPressed: () {
      //     setState(() => _headline = 'Dashboard');
      //     navigatorKey.currentState!
      //         .pushReplacementNamed('TicketsLevantadosScreen');
      //   },
      //   onHold: () {
      //     CustomSnackBar.showInfoSnackBar(context, "Dashboard");
      //   },
      // ),
    ]));
    return items;
  }

  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool open = true, isDarkModeEnabled = false;
  final AssetImage _avatarImgDark = const AssetImage('assets/boleto.png');

  List<UsuarioPermisoModels> listPermisos = [];
  int usuarioIndex = 0, areaIndex = 0, empresaIndex = 0, permisoIndex = 0;

  // Define una clave para tu Navigator
  final navigatorKey = GlobalKey<NavigatorState>();
  UsuarioModels? usuarioModels;
  List<EmpresaModels> empresas = [];

  @override
  void initState() {
    getPermiso();
    super.initState();
    _items = _generateItems;
    WidgetsBinding.instance.addPostFrameCallback((_) {});
    for (int i = 0; i < _items.length; i++) {
      for (int j = 0; j < _items[i].items.length; j++) {
        if (_items[i].items[j].isSelected) {
          _headline = _items[i].items[j].text;
          break;
        }
      }
    }
  }
  @override
  void dispose() {
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    context2 = context; theme = Theme.of(context); size = MediaQuery.of(context).size;
    return LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
      if (constraints.maxWidth > 600) {
        return _desktopBody(size, context);
      } else {
        return _mobileBody(size, context);
      }
    });
  }

  Widget _mobileBody(Size size, BuildContext context) {
    return Scaffold(backgroundColor: ColorPalette.ticketsTextSelectedColor,
      appBar: MyAppBarMobileTickets(title: _headline, context: context, backButton: false),
      body: Column(children: [_body(size, context)],),
      drawer: Drawer(backgroundColor: ColorPalette.ticketsTextSelectedColor,
        child: ListView(padding: EdgeInsets.zero,
          children: <Widget>[
            const SizedBox(height: 30,),
            ListTile(leading: const Icon(IconLibrary.iconHome, color: Colors.black,),
              title: const Text('Cerrar sesión', style: TextStyle(color: Colors.black),),
              onTap: () async {
                CustomAwesomeDialogTickets(title: "¿Quieres cerrar la sesión actual?", desc: '', btnOkOnPress: () async {
                  await UserPreferences().borrarUsuario();
                  Navigator.of(context).pushNamedAndRemoveUntil('loginPage', (Route<dynamic> route) => false);},
                    btnCancelOnPress: () {Navigator.of(context).pop();},
                    width: size.width<500? size.width*.9:null).showQuestion(context);



              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(IconLibrary.iconDashboard, color: Colors.black,),
              title: const Text('Dashboard', style: TextStyle(color: Colors.black),),
              onTap: () {
                setState(() => _headline = 'Tickets');
                //_selectedIndex = 0;
                navigatorKey.currentState!.pushReplacementNamed('TicketsHomeScreen');
                Navigator.of(context).pop();
              },
            ),
            ListTile(leading: const Icon(IconLibrary.iconTicket, color: Colors.black,),
              title: const Text('Recibidos', style: TextStyle(color: Colors.black),),
              onTap: () {
                setState(() => _headline = 'Recibidos');
                //_selectedIndex = 0;
                navigatorKey.currentState!.pushReplacementNamed('TicketsRecibidosScreen');
                Navigator.of(context).pop();
              },
            ),
            // ListTile(leading: const Icon(IconLibrary.iconStar, color: Colors.black,),
            //   title: const Text('Tickets', style: TextStyle(color: Colors.black),),
            //   onTap: () {
            //     setState(() => _headline = 'Levantados');
            //     //_selectedIndex = 0;
            //     navigatorKey.currentState!.pushReplacementNamed('TicketsLevantadosScreen');
            //     Navigator.of(context).pop();
            //   },
            // ),
            // if(admin)...[
            //   const Divider(),
            //   ListTile(leading: const Icon(IconLibrary.iconCheck, color: Colors.black,),
            //     title: const Text('Recibidos Admin', style: TextStyle(color: Colors.black),),
            //     onTap: () {
            //       setState(() => _headline = 'Recibidos Admin');
            //       //_selectedIndex = 0;
            //       navigatorKey.currentState!.pushReplacementNamed('TicketsRecibidosAdmin');
            //       Navigator.of(context).pop();
            //     },
            //   ),
            // ],
          ],
        ),
      ),
    );
  }


  Widget body() {
    return SizedBox(width: 1000,
      child: Scaffold(backgroundColor: ColorPalette.ticketsTextSelectedColor,
        appBar: MyCustomAppBarDesktop(title: "Levantados", context: context,
          textColor: Colors.white, backButton: true,
          defaultButtons: true, color: ColorPalette.ticketsColor,
          backButtonWidget: TextButton.icon(
            icon: const Icon(IconLibrary.iconBack, color: Colors.white,),
            label: const Text("Salir de tickets", style: TextStyle(color: Colors.white),),
            style: TextButton.styleFrom(primary: Colors.white, backgroundColor: Colors.transparent),
            onPressed: () {Navigator.of(context).pop();},
          ),
        ), body: const SizedBox(width: 100,),
      ),
    );
  }

  Widget _desktopBody(Size size, BuildContext context) {
    return Scaffold(backgroundColor: ColorPalette.ticketsTextSelectedColor,
      body: SideBarTickets(isCollapsed: true, items: _items,
        avatarBackgroundColor: ColorPalette.ticketsColor, avatarImg: _avatarImgDark,
        title: 'Tickets', onTitleTap: () {}, body: _body(size, context),
        backgroundColor: ColorPalette.ticketsColor, customItemOffsetX: 20,
        selectedIconColor: ColorPalette.ticketsTextSelectedColor, unselectedIconColor: Colors.white,
        selectedTextColor: ColorPalette.ticketsTextSelectedColor, unselectedTextColor: Colors.white,
        textStyle: const TextStyle(fontWeight: FontWeight.bold,),
        titleStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        toggleTitleStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }
  Widget _body(Size size, BuildContext context) {
    return Expanded(
        child: Navigator(key: navigatorKey, initialRoute: 'TicketsHomeScreen',
      onGenerateRoute: (RouteSettings settings) {
        WidgetBuilder builder;
        switch (settings.name) {
          case 'TicketsLevantadosScreen':
            builder = (BuildContext context) => TicketsLevantados(context: context2,);
            break;
          case 'TicketsRecibidosScreen':
            builder = (BuildContext context) => TicketsRecibidos(context: context2,);
            break;
          case 'TicketsHomeScreen':
            builder = (BuildContext context) => TicketsHomeDashboardScreen(context: context2,);
            break;
          case 'TicketsRecibidosAdmin':
            builder = (BuildContext context) => TicketsRecibidosAdmin(context: context2,);
            break;
          default:
            throw Exception('Invalid route: ${settings.name}');
        }
        return MaterialPageRoute(builder: builder, settings: settings);
      },
    ));
  }

  Future<void> getPermiso()async {
    try{
      UserPreferences userPreferences = UserPreferences();
      usuarioModels = await userPreferences.getUsuario();
      if(usuarioModels!=null){
        LoadingDialogTickets.showLoadingDialogTickets(context, Texts.loadingData);
        UsuarioPermisoController usuarioPermisoController = UsuarioPermisoController();
        listPermisos = await usuarioPermisoController.getUsuariosPermiso(usuarioModels!.idUsuario!);
        SidebarGroupItem sidebarGroupRecibidosAdmin= SidebarGroupItem(text: "Administrador tickets", items: []);
        for (int i = 0; i < listPermisos.length; i++) {
        if(listPermisos[i].permisoId == "ccda55e9-d75f-4c1c-91a3-ddface216bd3"){
          admin = true;
          // sidebarGroupRecibidosAdmin.items.add(SidebarItem(text: 'Recibidos Admin',
          //   icon: IconLibrary.iconCheck, isSelected: false,
          //   onPressed: () {
          //     setState(() => _headline = 'Dashboard');
          //     navigatorKey.currentState!.pushReplacementNamed('TicketsRecibidosAdmin');
          //   }, onHold: () {CustomSnackBar.showInfoSnackBar(context, "Dashboard");},
          // ));
        }
      }
      if(sidebarGroupRecibidosAdmin.items.isNotEmpty){
        _items.add(sidebarGroupRecibidosAdmin);
      }
      setState(() {});
      Navigator.of(context, rootNavigator: true).pop();
      }else{
        CustomAwesomeDialog(title: "Error al obtener permisos", desc: "No se pudo obtener el usuario",
            btnOkOnPress: (){}, btnCancelOnPress: (){}).showError(context);
      }
    }catch(e){
      Navigator.of(context, rootNavigator: true).pop();
      ConnectionExceptionHandler connectionExceptionHandler = ConnectionExceptionHandler();
      String error = await connectionExceptionHandler.handleConnectionExceptionString(e);
      CustomAwesomeDialog(title: "Error al obtener permisos", desc: error, btnOkOnPress: (){},
          btnCancelOnPress: (){}).showError(context);
      print('Error al obtener los permisos: $e');
    }
  }




}

class SidebarButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onPressed;
  final VoidCallback onHold;

  const SidebarButton({
    required this.text,
    required this.icon,
    required this.isSelected,
    required this.onPressed,
    required this.onHold,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      onLongPress: onHold,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        padding: EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.grey[200],
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              offset: Offset(0, 2),
              blurRadius: 4.0,
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? Colors.white : Colors.black),
            SizedBox(width: 8.0),
            Text(
              text,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
