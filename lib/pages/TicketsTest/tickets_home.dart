import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tickets/controllers/ConfigControllers/empresaController.dart';
import 'package:tickets/controllers/ConfigControllers/usuarioController.dart';
import 'package:tickets/models/ConfigModels/usuario.dart';
import 'package:tickets/pages/Compras/pages/materiales/alta_materiales_screen.dart';
import 'package:tickets/pages/Home/dashboard_screen.dart';
import 'package:tickets/pages/Settings/Area/area_screen.dart';
import 'package:tickets/pages/Settings/Companies/companies_screen.dart';
import 'package:tickets/pages/Settings/Users/users_screen.dart';
import 'package:tickets/config/theme/app_theme.dart';
import 'package:tickets/pages/Tickets/tickets_levantados.dart';
import 'package:tickets/pages/Tickets/tickets_recibidos.dart';
import 'package:tickets/pages/login/app_login_view.dart';
import 'package:tickets/shared/actions/handleException.dart';
import 'package:tickets/shared/utils/color_palette.dart';
import 'package:tickets/shared/utils/icon_library.dart';
import 'package:tickets/shared/utils/texts.dart';
import 'package:tickets/main.dart';
import 'package:tickets/shared/utils/user_preferences.dart';
import 'package:tickets/shared/widgets/Loading/loadingDialog.dart';
import 'package:tickets/shared/widgets/Snackbars/customSnackBar.dart';
import 'package:tickets/shared/widgets/appBar/appBar_decoration.dart';
import 'package:tickets/shared/widgets/appBar/my_appBar.dart';
import 'package:tickets/shared/widgets/bar/Tickets/sidebarTickets.dart';
import 'package:tickets/shared/widgets/bar/sidebar.dart';
import 'package:tickets/shared/widgets/bar/sidebar_group_item.dart';
import 'package:tickets/shared/widgets/bar/sidebar_item.dart';
import 'package:tickets/shared/widgets/buttons/dropdown_button_user.dart';
import 'package:tickets/shared/widgets/dialogs/custom_awesome_dialog.dart';

import '../../controllers/ConfigControllers/usuarioPermisoController.dart';
import '../../models/ConfigModels/empresa.dart';
import '../../models/ConfigModels/usuarioPermiso.dart';
import '../../shared/widgets/textfields/my_textfield_icon.dart';
import '../Compras/pages/materiales/materiales_main_screen.dart';
import '../Settings/permissions/permissions_screen.dart';
import 'Tickets_recibidos_Admin.dart';
import 'tickets_home_screen.dart';

class TicketHomeScreenTest extends StatefulWidget {
  static String id = 'TicketsHome2';

  const TicketHomeScreenTest({super.key});

  @override
  State<TicketHomeScreenTest> createState() => _TicketHomeScreenTest();
}

class _TicketHomeScreenTest extends State<TicketHomeScreenTest> {
  late List<SidebarGroupItem> _items;
  final List<ListTile> _listTiles = [];
  late String _headline;
  late ThemeData theme;
  late BuildContext context2;
  TextEditingController _searchController = TextEditingController();

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
      SidebarItem(
        text: 'Levantados',
        icon: IconLibrary.iconStar,
        isSelected: false,
        onPressed: () {
          setState(() => _headline = 'Dashboard');
          navigatorKey.currentState!
              .pushReplacementNamed('TicketsLevantadosScreen');
        },
        onHold: () {
          CustomSnackBar.showInfoSnackBar(context, "Dashboard");
        },
      ),



    ]));
    return items;
  }

  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool open = true;
  bool isDarkModeEnabled = false;

  final AssetImage _avatarImgDark = const AssetImage('assets/boleto.png');
  final AssetImage _avatarTitleImgDark =
      const AssetImage('assets/full_title_dark.png');

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
    context2 = context;
    theme = Theme.of(context);
    var size = MediaQuery.of(context).size;
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      if (constraints.maxWidth > 600) {
        return _desktopBody(size, context);
      } else {
        return _mobileBody(size, context);
      }
    });
  }

  Widget _mobileBody(Size size, BuildContext context) {
    return Scaffold(
      appBar:
          MyAppBarMobile(title: _headline, context: context, backButton: false),
      body: Column(
        children: [_body(size, context)],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName:
                  Text(usuarioModels != null ? usuarioModels!.userName : ""),
              // Replace with your user's name
              accountEmail: const Text(""),
              // Replace with your user's email
              //currentAccountPicture: myDropdownButtonUser(theme, context),
              otherAccountsPictures: [
                Image(
                  image: _avatarTitleImgDark,
                )
              ],
            ),
            ListTile(
              leading: const Icon(IconLibrary.iconHome),
              title: const Text('Menú Principal'),
              onTap: () {
                setState(() => _headline = 'Menú principal');
                //_selectedIndex = 0;
                Navigator.of(context).pop();
              },
            ),
            Column(
              children: _listTiles,
            ),
            const Divider(), // Add dividers for visual separation
            ListTile(
              // Add this ListTile for the theme mode switcher
              leading: Icon(isDarkModeEnabled
                  ? IconLibrary.iconLightTheme
                  : IconLibrary.iconDarkTheme),
              title:
                  Text(isDarkModeEnabled ? Texts.lightTheme : Texts.darkTheme),
              onTap: () {
                setState(() {
                  isDarkModeEnabled = !isDarkModeEnabled;
                  ThemeMode themeMode =
                      isDarkModeEnabled ? ThemeMode.dark : ThemeMode.light;
                  MyApp.updateTheme(themeMode);
                });
              },
            ), // Add dividers for visual separation
            const AboutListTile(
              // Add an about section
              icon: Icon(IconLibrary.iconInfo),
              applicationName: "App Name",
              // Replace with your app's name
              applicationVersion: "1.0.0",
              // Replace with your app's version
              applicationIcon: Icon(Icons.adb),
              aboutBoxChildren: <Widget>[
                Text("This is a drawer"),
              ],
              child: Text("About"),
            ),
          ],
        ),
      ),
    );
  }

  Widget body() {
    return SizedBox(
      width: 1000,
      child: Scaffold(
        backgroundColor: ColorPalette.ticketsTextSelectedColor,
        appBar: MyCustomAppBarDesktop(
          title: "Levantados",
          context: context,
          textColor: Colors.white,
          backButton: true,
          defaultButtons: false,
          color: ColorPalette.ticketsColor,
          backButtonWidget: TextButton.icon(
            icon: const Icon(
              IconLibrary.iconBack,
              color: Colors.white,
            ),
            label: const Text(
              "Salir de tickets",
              style: TextStyle(color: Colors.white),
            ),
            style: TextButton.styleFrom(
              primary: Colors.white,
              backgroundColor: Colors.transparent, // Color de fondo
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        body: const SizedBox(
          width: 100,
        ),
      ),
    );
  }

  Widget _desktopBody(Size size, BuildContext context) {
    return Scaffold(
      backgroundColor: ColorPalette.ticketsTextSelectedColor,
      body: SideBarTickets(
        isCollapsed: true,
        items: _items,
        avatarBackgroundColor: ColorPalette.ticketsColor,
        avatarImg: _avatarImgDark,
        title: 'Tickets',
        onTitleTap: () {},
        body: _body(size, context),
        backgroundColor: ColorPalette.ticketsColor,
        customItemOffsetX: 20,
        selectedIconColor: ColorPalette.ticketsTextSelectedColor,
        unselectedIconColor: Colors.white,
        selectedTextColor: ColorPalette.ticketsTextSelectedColor,
        unselectedTextColor: Colors.white,
        textStyle: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
        titleStyle: const TextStyle(
            fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        toggleTitleStyle: const TextStyle(
            fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }

  Widget _body(Size size, BuildContext context) {
    return Expanded(
        child: Navigator(
      key: navigatorKey,
      initialRoute: 'TicketsHomeScreen',
      onGenerateRoute: (RouteSettings settings) {
        WidgetBuilder builder;
        switch (settings.name) {
          case 'TicketsLevantadosScreen':
            builder = (BuildContext context) => TicketsLevantados(
                  context: context2,
                );
            break;
          case 'TicketsRecibidosScreen':
            builder = (BuildContext context) => TicketsRecibidos(
                  context: context2,
                );
            break;
          case 'TicketsHomeScreen':
            builder = (BuildContext context) => TicketsHomeDashboardScreenTest(
                  context: context2,
                );
            break;
          case 'TicketsRecibidosAdmin':
            builder = (BuildContext context) => TicketsRecibidosAdminTest(
              context: context2,
            );
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
        LoadingDialog.showLoadingDialog(context, Texts.loadingData);
        UsuarioPermisoController usuarioPermisoController = UsuarioPermisoController();
        listPermisos = await usuarioPermisoController.getUsuariosPermiso(usuarioModels!.idUsuario!);
        SidebarGroupItem sidebarGroupRecibidosAdmin= SidebarGroupItem(text: "Administrador tickets", items: []);
        for (int i = 0; i < listPermisos.length; i++) {
        if(listPermisos[i].permisoId=="ccda55e9-d75f-4c1c-91a3-ddface216bd3"){
          sidebarGroupRecibidosAdmin.items.add(SidebarItem(
            text: 'Recibidos Admin',
            icon: IconLibrary.iconCheck,
            isSelected: false,
            onPressed: () {
              setState(() => _headline = 'Dashboard');
              navigatorKey.currentState!
                  .pushReplacementNamed('TicketsRecibidosAdmin');
            },
            onHold: () {
              CustomSnackBar.showInfoSnackBar(context, "Dashboard");
            },
          ));
        }
      }
      if(sidebarGroupRecibidosAdmin.items.isNotEmpty){
        _items.add(sidebarGroupRecibidosAdmin);
      }
      setState(() {});
      Navigator.of(context, rootNavigator: true).pop();
      }else{
        CustomAwesomeDialog(title: "Error al obtener permisos", desc: "No se pudo obtener el usuario", btnOkOnPress: (){}, btnCancelOnPress: (){})
            .showError(context);
      }
    }catch(e){
      Navigator.of(context, rootNavigator: true).pop();
      ConnectionExceptionHandler connectionExceptionHandler = ConnectionExceptionHandler();
      String error = await connectionExceptionHandler.handleConnectionExceptionString(e);
      CustomAwesomeDialog(title: "Error al obtener permisos", desc: error, btnOkOnPress: (){}, btnCancelOnPress: (){})
          .showError(context);
      print('Error al obtener los permisos: $e');
    }

  }
}
