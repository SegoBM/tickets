import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tickets/pages/Compras/pages/Kit/kit_screen.dart';
import 'package:tickets/pages/Home/dashboard_screen.dart';
import 'package:tickets/pages/Home/home_menu_screen.dart';
import 'package:tickets/pages/Settings/Area/area_screen.dart';
import 'package:tickets/pages/Settings/Companies/companies_screen.dart';
import 'package:tickets/pages/Settings/GeneralSettings/general_settings_screen.dart';
import 'package:tickets/pages/Settings/Users/users_screen.dart';
import 'package:tickets/config/theme/app_theme.dart';
import 'package:tickets/shared/actions/handleException.dart';
import 'package:tickets/shared/utils/icon_library.dart';
import 'package:tickets/shared/utils/texts.dart';
import 'package:tickets/main.dart';
import 'package:tickets/shared/utils/user_preferences.dart';
import 'package:tickets/shared/widgets/Loading/loadingDialog.dart';
import 'package:tickets/shared/widgets/Snackbars/customSnackBar.dart';
import 'package:tickets/shared/widgets/appBar/appBar_decoration.dart';
import 'package:tickets/shared/widgets/bar/sidebar.dart';
import 'package:tickets/shared/widgets/bar/sidebar_group_item.dart';
import 'package:tickets/shared/widgets/bar/sidebar_item.dart';
import 'package:tickets/shared/widgets/buttons/dropdown_button_user.dart';
import 'package:tickets/shared/widgets/dialogs/custom_awesome_dialog.dart';
import '../../controllers/ConfigControllers/empresaController.dart';
import '../../controllers/ConfigControllers/usuarioPermisoController.dart';
import '../../models/ConfigModels/empresa.dart';
import '../../models/ConfigModels/usuario.dart';
import '../../models/ConfigModels/usuarioPermiso.dart';
import '../Compras/pages/Proveedores/proveedores_screen.dart';
import '../Compras/pages/materiales/materiales_main_screen.dart';
import '../Compras/pages/ServiciosProductos/serviciosProductos_screen.dart';
import '../Settings/permissions/permissions_screen.dart';

class HomeScreen extends StatefulWidget {
  static String id = 'homeScreen';
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState()=> _HomeScreen();
}

class _HomeScreen extends State<HomeScreen>{
  late List<SidebarGroupItem> _items;
  final List<ListTile> _listTiles = [];
  late String _headline;

  List<SidebarGroupItem> get _generateItems  {
    List<SidebarGroupItem> items = [];
    items.add(SidebarGroupItem(isCollapsed: false,
        text: "Home", items: [
      SidebarItem(
        text: 'Menú Principal', icon: IconLibrary.iconHome, isSelected: true,
        onPressed: () {
          setState(() => _headline = 'Menú Principal');
          navigatorKey.currentState!.pushReplacementNamed('homeMenuScreen');
        },
        onHold: () {
          CustomSnackBar.showInfoSnackBar(context, "Menú Principal");
        },
      ),
      SidebarItem(
        text: 'Dashboard', icon: IconLibrary.iconDashboard, isSelected: false,
        onPressed: () {
          setState(() => _headline = 'Dashboard');
          navigatorKey.currentState!.pushReplacementNamed('dashboardScreen');
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
  late ThemeData theme; late BuildContext context2; late Size size;
  bool isDarkModeEnabled = false;

  final AssetImage _avatarImgLight = const AssetImage('assets/full.png');
  final AssetImage _avatarImgDark = const AssetImage('assets/full_dark.png');
  final AssetImage _avatarTitleImgLight = const AssetImage('assets/full_title.png');
  final AssetImage _avatarTitleImgDark = const AssetImage('assets/full_title_dark.png');

  List<UsuarioPermisoModels> listPermisos = [];
  int usuarioIndex = 0, areaIndex = 0, empresaIndex = 0, permisoIndex = 0;
  // Define una clave para tu Navigator
  final navigatorKey = GlobalKey<NavigatorState>();
  UsuarioModels? usuarioModels;
  List<EmpresaModels> empresas = [];
  @override
  void initState() {
    super.initState();
    getThemeMode();
    _items = _generateItems;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getPermiso();
      getEmpresas();
      if(Platform.isAndroid||Platform.isIOS){
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ]);
      }
    });
    for(int i = 0; i < _items.length; i++){
      for(int j = 0; j < _items[i].items.length; j++){
        if(_items[i].items[j].isSelected){
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
  Widget build(BuildContext context){
    context2 = context; theme = Theme.of(context); size = MediaQuery.of(context).size;
    return LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints){
      if(constraints.maxWidth > 600) {
        return _desktopBody(context);
      } else {
        return _mobileBody(context);
      }
    });
  }
  Widget _mobileBody(BuildContext context){
    return Scaffold(
      appBar: MyAppBarMobile(title: _headline,context: context,backButton: false),
      body: Column(children: [_body(context)],),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text(usuarioModels!=null?usuarioModels!.userName : ""), // Replace with your user's name
              accountEmail: const Text(""), // Replace with your user's email
              currentAccountPicture: myDropdownButtonUser(theme, context),
              otherAccountsPictures: [
                Image(image: theme.colorScheme==GlobalThemData.lightColorScheme? _avatarTitleImgLight:_avatarTitleImgDark,)
              ],
            ),
            ListTile(
              leading: const Icon(IconLibrary.iconHome),
              title: const Text('Menú Principal'),
              onTap: () {
                setState(() => _headline = 'Menú principal');
                //_selectedIndex = 0;
                navigatorKey.currentState!.pushReplacementNamed('homeMenuScreen');
                Navigator.of(context).pop();
              },
            ),
            Column(children: _listTiles,),
            const Divider(),
            ListTile(
              leading: const Icon(IconLibrary.iconHome),
              title: const Text('Tickets'),
              onTap: () {
                setState(() => _headline = 'Tickets');
                //_selectedIndex = 0;
                Navigator.of(context).pushNamed('TicketsHome');
              },
            ),
            const Divider(),
            ListTile( // Add this ListTile for the theme mode switcher
              leading: Icon(isDarkModeEnabled ? IconLibrary.iconLightTheme : IconLibrary.iconDarkTheme),
              title: Text(isDarkModeEnabled ? Texts.lightTheme : Texts.darkTheme),
              onTap: () {
                setState(() {
                  isDarkModeEnabled = !isDarkModeEnabled;
                  ThemeMode themeMode = isDarkModeEnabled ? ThemeMode.dark : ThemeMode.light;
                  MyApp.updateTheme(themeMode);
                });
              },
            ),// Add dividers for visual separation
            const AboutListTile( // Add an about section
              icon: Icon(IconLibrary.iconInfo),
              applicationName: "App Name", // Replace with your app's name
              applicationVersion: "1.0.0", // Replace with your app's version
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
  Widget _desktopBody(BuildContext context){
    return Scaffold(
      body: SideBar(
        isCollapsed: true,borderRadius: 0,
        items: _items, avatarBackgroundColor: Colors.transparent,
        avatarImg: theme.colorScheme==GlobalThemData.lightColorScheme? _avatarImgLight:_avatarImgDark,
        title: 'Full ERP', onTitleTap: () {},
        body: _body(context), backgroundColor: theme.primaryColor, customItemOffsetX: 20,
        selectedIconColor: theme.unselectedWidgetColor, unselectedIconColor: theme.colorScheme.onPrimary,
        selectedTextColor: theme.unselectedWidgetColor, unselectedTextColor: theme.colorScheme.onPrimary,
        textStyle: theme.textTheme.bodyText2,
        titleStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.colorScheme.onPrimary),
        toggleTitleStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.colorScheme.onPrimary),
      ),
    );
  }
  Widget _body(BuildContext context) {
    return Expanded(
        child: Navigator(key: navigatorKey,
          initialRoute: 'homeMenuScreen',
          onGenerateRoute: (RouteSettings settings){
            WidgetBuilder builder;
            switch(settings.name){
              case 'homeMenuScreen':
                builder = (BuildContext context) => HomeMenuScreen(context: context2,items: _items,);
                break;
              case 'dashboardScreen':
                builder = (BuildContext context) => DashboardScreen(context: context2,);
                break;
              case 'UsersScreen':
                builder = (BuildContext context) => UsersScreen(listUsuarioPermisos: listPermisos, empresas: empresas,context: context2,);
                break;
              case 'AreasScreen':
                builder = (BuildContext context) => AreasScreen(listUsuarioPermisos: listPermisos, context: context2,);
                break;
              case 'EmpresasScreen':
                builder = (BuildContext context) => EmpresasScreen(listUsuarioPermisos: listPermisos, context: context2,);
                break;
              case 'PermissionsScreen':
                builder = (BuildContext context) => PermissionsScreen(context: context2,);
                break;
              case 'ProveedoresScreen':
                builder = (BuildContext context) => ProveedoresScreen(listUsuarioPermisos: listPermisos,context: context2);
                break;
              case 'lista_materiales_screen':
                builder = (BuildContext context) =>  ListaMaterialesScreen(context: context2);
                break;
              case 'ServiciosProductosScreen':
                builder = (BuildContext context) => ServiciosProductosScreen(listUsuarioPermisos: listPermisos, context: context2,);
                break;
              case 'KitScreen':
                builder = (BuildContext context) => KitScreen(listUsuarioPermisos: listPermisos, context: context2,);
                break;
              case 'SettingsScreen':
                builder = (BuildContext context) => GeneralSettingsScreen(empresas: empresas, context: context2, listPermisos: listPermisos,);
                break;
              default:
                throw Exception('Invalid route: ${settings.name}');
            }
            return MaterialPageRoute(builder: builder, settings: settings);
          },)
    );
  }
  Future<void> getPermiso() async {
    try{
      UserPreferences userPreferences = UserPreferences();
      usuarioModels = await userPreferences.getUsuario();
      if(usuarioModels != null) {
        LoadingDialog.showLoadingDialog(context, Texts.loadingData);
        UsuarioPermisoController usuarioPermisoController = UsuarioPermisoController();
        listPermisos = await usuarioPermisoController.getUsuariosPermiso(usuarioModels!.idUsuario!);
        bool usuarioAgregado = false, areaAgregado = false, empresaAgregado = false, permisoAgregado = false,
            AltaMaTAgregado = false,proveedorAgregado = false, servicioProductoAgregado = false,
            ajustesGeneralesAgregado = false, kitAgregado = false;
        SidebarGroupItem sidebarGroupItemConfiguracion = SidebarGroupItem(text: "Configuración", items: []);
        SidebarGroupItem sidebarGroupItemCompras = SidebarGroupItem(text: "Compras", items: []);
        for(int i = 0; i < listPermisos.length; i++){
          switch(listPermisos[i].permisoId){
            case Texts.permissionsUserAdd || Texts.permissionsUserEdit || Texts.permissionsUserDelete:
              if(!usuarioAgregado){
                //usuarioIndex = index;
                sidebarGroupItemConfiguracion.items.add(SidebarItem(
                  text: 'Usuarios', icon: IconLibrary.iconPerson, isSelected: false,
                  onPressed: () {
                    setState(() => _headline = 'Usuarios');
                    //_selectedIndex = usuarioIndex;
                    navigatorKey.currentState!.pushReplacementNamed('UsersScreen');
                  },
                  onHold: () {
                    CustomSnackBar.showInfoSnackBar(context, "Usuarios");
                  },
                ));
                _listTiles.add(ListTile(
                  leading: const Icon(IconLibrary.iconPerson),
                  title: const Text('Usuarios'),
                  onTap: () {
                    setState(() => _headline = 'Usuarios');
                    //_selectedIndex = usuarioIndex;
                    navigatorKey.currentState!.pushReplacementNamed('UsersScreen');
                    Navigator.of(context).pop();
                  },
                ));
              }
              usuarioAgregado = true;
              break;
            case Texts.permissionsAreaAdd || Texts.permissionsAreaEdit || Texts.permissionsAreaDelete:
              if(!areaAgregado){
                //areaIndex = index;
                sidebarGroupItemConfiguracion.items.add(SidebarItem(
                  text: 'Areas', icon: IconLibrary.iconUser, isSelected: false,
                  onPressed: () {
                    setState(() => _headline = 'Areas');
                    // _selectedIndex = areaIndex;
                    navigatorKey.currentState!.pushReplacementNamed('AreasScreen');
                  },
                  onHold: () {
                    CustomSnackBar.showInfoSnackBar(context, "Areas");
                  },
                ));
                /*_listTiles.add(ListTile(
                  leading: const Icon(IconLibrary.iconUser),
                  title: const Text('Areas'),
                  onTap: () {
                    setState(() => _headline = 'Areas');
                    //_selectedIndex = areaIndex;
                    navigatorKey.currentState!.pushReplacementNamed('AreasScreen');
                    Navigator.of(context).pop();
                  },
                ));*/
              }
              areaAgregado = true;
              break;
            case Texts.permissionsCompanyAdd || Texts.permissionsCompanyEdit || Texts.permissionsCompanyDelete:
              if(!empresaAgregado){
                // empresaIndex = index;
                sidebarGroupItemConfiguracion.items.add(SidebarItem(
                  text: 'Empresas', icon: IconLibrary.iconBusiness, isSelected: false,
                  onPressed: () {
                    setState(() => _headline = 'Empresas');
                    //_selectedIndex = empresaIndex;
                    navigatorKey.currentState!.pushReplacementNamed('EmpresasScreen');
                  },
                  onHold: () {
                    CustomSnackBar.showInfoSnackBar(context, "Empresas");
                  },
                ));
                /*
                _listTiles.add(ListTile(
                  leading: const Icon(IconLibrary.iconBusiness),
                  title: const Text('Empresas'),
                  onTap: () {
                    setState(() => _headline = 'Empresas');
                    //_selectedIndex = empresaIndex;
                    navigatorKey.currentState!.pushReplacementNamed('EmpresasScreen');
                    Navigator.of(context).pop();
                  },
                ));*/
              }
              empresaAgregado = true;
              break;
            case Texts.permissionsSuggested:
              if(!permisoAgregado){
                //permisoIndex = index;
                sidebarGroupItemConfiguracion.items.add(SidebarItem(
                  text: 'Permisos\nsugeridos', icon: IconLibrary.iconPermissions, isSelected: false,
                  onPressed: () {
                    setState(() => _headline = 'Permisos sugeridos');
                    navigatorKey.currentState!.pushReplacementNamed('PermissionsScreen');
                    //_selectedIndex = permisoIndex;
                  },
                  onHold: () {
                    CustomSnackBar.showInfoSnackBar(context, "Permisos sugeridos");
                  },
                ));
                /*_listTiles.add(ListTile(
                  leading: const Icon(IconLibrary.iconPerson),
                  title: const Text('Permisos'),
                  onTap: () {
                    setState(() => _headline = 'Permisos');
                    navigatorKey.currentState!.pushReplacementNamed('PermissionsScreen');
                    //_selectedIndex = permisoIndex;
                    Navigator.of(context).pop();
                  },
                ));*/
              }
              permisoAgregado = true;
              break;
            case Texts.permissionsProveedorAdd || Texts.permissionsProveedorEdit || Texts.permissionsProveedorDelete:
              if(!proveedorAgregado){
                sidebarGroupItemCompras.items.add(SidebarItem(
                  text: 'Proveedores', icon: IconLibrary.iconGroups, isSelected: false,
                  onPressed: () {
                    setState(() => _headline = 'Proveedores');
                    // _selectedIndex = areaIndex;
                    navigatorKey.currentState!.pushReplacementNamed('ProveedoresScreen');
                  },
                  onHold: () {
                    CustomSnackBar.showInfoSnackBar(context, "Proveedores");
                  },
                ));
              }
              proveedorAgregado= true;
              break;
            case Texts.permissionsServiciosProductosAdd || Texts.permissionsServiciosProductosEdit || Texts.permissionsServiciosProductosDelete:
                if(!servicioProductoAgregado){
                  sidebarGroupItemCompras.items.add(SidebarItem(
                    text: 'Servicios y\nProductos', icon: IconLibrary.iconShiping, isSelected: false,
                    onPressed: () {
                      setState(() => _headline = 'ServiciosProductos');
                      // Aquí puedes poner la ruta a la que quieres que se dirija cuando se presione este item
                      navigatorKey.currentState!.pushReplacementNamed('ServiciosProductosScreen');
                    },
                    onHold: () {
                      CustomSnackBar.showInfoSnackBar(context, "ServiciosProductos");
                    },
                  ),);
                }
                servicioProductoAgregado= true;
            break;
            case Texts.permissionsGeneralSettings || Texts.permissionsSettingsInventory || Texts.permissionsSettingsSales ||
              Texts.permissionsSettingsShopping:
              if(!ajustesGeneralesAgregado){
                sidebarGroupItemConfiguracion.items.add(SidebarItem(
                  text: 'Ajustes \ngenerales', icon: IconLibrary.iconSettings, isSelected: false,
                  onPressed: () {
                    setState(() => _headline = 'Ajustes generales');
                    //_selectedIndex = usuarioIndex;
                    navigatorKey.currentState!.pushReplacementNamed('SettingsScreen');
                  },
                  onHold: () {
                    CustomSnackBar.showInfoSnackBar(context, "Ajustes generales");
                  },
                ));
              }
              ajustesGeneralesAgregado = true;
              break;
            case Texts.permissionsMaterialesAdd || Texts.permissionsMaterialesEdit || Texts.permissionsMaterialesDelete:
              if(!AltaMaTAgregado){
                sidebarGroupItemCompras.items.add(SidebarItem(
                  text: 'Materiales', icon: IconLibrary.iconMaterial, isSelected: false,
                  onPressed: () {
                    setState(() => _headline = 'Materiales');
                    // Aquí puedes poner la ruta a la que quieres que se dirija cuando se presione este item
                    navigatorKey.currentState!.pushReplacementNamed('lista_materiales_screen');
                  },
                  onHold: () {
                    CustomSnackBar.showInfoSnackBar(context, "Materiales");
                  },
                ),);
              }
              AltaMaTAgregado= true;
              break;
              case Texts.permissionsKitAdd || Texts.permissionsKitEdit || Texts.permissionsKitDelete:
                if(!kitAgregado){
                  sidebarGroupItemCompras.items.add(SidebarItem(
                    text: 'Kits', icon: IconLibrary.iconBusiness, isSelected: false,
                    onPressed: () {
                      setState(() => _headline = 'Kits');
                      navigatorKey.currentState!.pushReplacementNamed('KitScreen');
                    },
                    onHold: () {CustomSnackBar.showInfoSnackBar(context, "Kits");},),);
                }
                kitAgregado= true;
                break;
          }
        }
        /*sidebarGroupItemCompras.items.add(SidebarItem(
          subItems: [
            SidebarItem(
            text: 'Kits', icon: IconLibrary.iconBusiness, isSelected: false,
            onPressed: () {
              setState(() => _headline = 'Kits');
              navigatorKey.currentState!.pushReplacementNamed('KitScreen');
            },
            onHold: () {CustomSnackBar.showInfoSnackBar(context, "Kits");},),
            SidebarItem(
              text: 'Servicios y\nProductos', icon: IconLibrary.iconShiping, isSelected: false,
              onPressed: () {
                setState(() => _headline = 'ServiciosProductos');
                // Aquí puedes poner la ruta a la que quieres que se dirija cuando se presione este item
                navigatorKey.currentState!.pushReplacementNamed('ServiciosProductosScreen');
              },
              onHold: () {
                CustomSnackBar.showInfoSnackBar(context, "ServiciosProductos");
              },
            )
          ],
          text: 'Bienes y\nservicios', icon: IconLibrary.iconUser, isSelected: false,
          onPressed: () {setState(() {});},
          onHold: () {
            CustomSnackBar.showInfoSnackBar(context, "Areas");
          },
        ));*/

        if(sidebarGroupItemCompras.items.isNotEmpty){
          _items.add(sidebarGroupItemCompras);
        }
        if(sidebarGroupItemConfiguracion.items.isNotEmpty){
          _items.add(sidebarGroupItemConfiguracion);
        }
        setState(() {});
        Navigator.of(context, rootNavigator: true).pop();
      }else{
        CustomAwesomeDialog(title: "Error al obtener permisos", desc: "No se pudo obtener el usuario",
            btnOkOnPress: (){}, btnCancelOnPress: (){}, width: size.width<500? size.width*0.9 : null,).showError(context);
      }
    }catch(e){
      Navigator.of(context, rootNavigator: true).pop();
      ConnectionExceptionHandler connectionExceptionHandler = ConnectionExceptionHandler();
      String error = await connectionExceptionHandler.handleConnectionExceptionString(e);
      CustomAwesomeDialog(title: "Error al obtener permisos", desc: error, btnOkOnPress: (){},
          btnCancelOnPress: (){}, width: size.width<500? size.width*0.9 : null,).showError(context);
      print('Error al obtener los permisos: $e');
    }
  }

  Future<void> getEmpresas() async {
    EmpresaController empresaController = EmpresaController();
    String usuarioID = await  UserPreferences().getUsuarioID();
    empresas = await empresaController.getEmpresas(usuarioID);
  }
  void getThemeMode() async {
    bool? isDarkModeEnabled = await UserPreferences().getTheme();
    this.isDarkModeEnabled = isDarkModeEnabled ?? false;
  }
}



