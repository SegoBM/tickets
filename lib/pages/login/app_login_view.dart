import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:tickets/controllers/LoginController/loginController.dart';
import 'package:tickets/models/ConfigModels/empresa.dart';
import 'package:tickets/models/ConfigModels/usuario.dart';
import 'package:tickets/shared/actions/handleException.dart';
import 'package:tickets/shared/utils/color_palette.dart';
import 'package:tickets/shared/utils/texts.dart';
import 'package:tickets/shared/widgets/Loading/loadingDialog.dart';
import 'package:tickets/shared/widgets/dialogs/custom_awesome_dialog.dart';
import 'package:easy_animated_button/easy_animated_button.dart';
import 'package:tickets/shared/widgets/textfields/my_text_field.dart';
import 'package:rive/rive.dart' as rv;
import '../../main.dart';
import '../../models/ConfigModels/userSession.dart';
import '../../shared/utils/user_preferences.dart';
import 'app_icons.dart';

class LoginPage extends StatefulWidget {
  static String id = 'loginPage';
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPage();
}

class _LoginPage extends State<LoginPage> with TickerProviderStateMixin {
  bool _obscureText = true;
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController usuarioController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late AnimationController _animationController1;
  late Animation<double> _animation1;
  late AnimationController _animationController2;
  late Animation<double> _animation2;
  bool isPressed = false;
  final _formKey = GlobalKey<FormState>();
  UsuarioModels? usuarioModels;
  late ThemeData themeData;
  late Size size;
  bool _isObscure = true;

  bool isDarkModeEnabled = false;
  UserPreferences userPreferences = UserPreferences();
  late EasyAnimatedButton myButtonPage;
  @override
  void initState() {
    super.initState();
    getThemeMode();

    _animationController1 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 60),
    )..addListener(() {
        setState(() {});
      });
    _animation1 = Tween<double>(begin: 0, end: 1.57)
        .chain(CurveTween(curve: Curves.easeIn))
        .animate(_animationController1);
    _animationController2 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    )..addListener(() {
        setState(() {});
      });
    _animation2 = Tween<double>(begin: 0, end: 4)
        .chain(CurveTween(curve: Curves.fastEaseInToSlowEaseOut))
        .animate(_animationController2);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      getUser();
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    themeData = Theme.of(context);
    size = MediaQuery.of(context).size;
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      if (constraints.maxWidth > 600) {
        return _desktopBody(size, context);
      } else {
        return _mobileBody(size, context);
      }
    });
  }



  Widget _desktopBody(Size size, BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: ColorPalette.backColor,
      body: SizedBox(
        height: height,
        width: width,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
                child: Container(
                  height: height,
                  color: ColorPalette.ticketsColor,
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 120,
                      ),

                      Text(
                        'Tickets',
                        style: Theme.of(context).textTheme.headline6?.copyWith(
                          color: ColorPalette.whiteColor,
                          fontSize: 40,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(
                        width: 800,
                        height: 400,
                        child: rv.RiveAnimation.asset(
                          'assets/Robo.riv',
                        ),
                      ),



                    ],
                  ),


                )),
            Expanded(
                child: Container(
                    height: height,
                    margin: EdgeInsets.symmetric(horizontal: height * 0.12),
                    color: ColorPalette.backColor,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: height * 0.145,
                        ),
                        RichText(
                            text: TextSpan(children: [
                              TextSpan(
                                text: 'Bienvenido a Tickets',
                                style: Theme.of(context).textTheme.headline6?.copyWith(
                                  color: ColorPalette.blueDarkColor,
                                  fontSize: 25,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                              TextSpan(
                                text: '\n\nInicia sesión para continuar',
                                style: Theme.of(context).textTheme.headline6?.copyWith(
                                  color: ColorPalette.blueDarkColor,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ])),
                        SizedBox(
                          height: height * 0.09,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('Usuario',
                            style: Theme.of(context).textTheme.headline6?.copyWith(
                              color: ColorPalette.blueDarkColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 6.0,
                        ),
                        Container(
                          height: 50.0,
                          width: width,
                          decoration: BoxDecoration(
                            color: ColorPalette.whiteColor,
                            borderRadius: BorderRadius.circular(16.0),
                            border: Border.all(
                              color: ColorPalette.blueDarkColor,
                              width: 0.5,
                            ),
                          ),
                          child: TextFormField(
                              key: const Key('usuario'),
                              controller: usuarioController,
                              style:
                              Theme.of(context).textTheme.headline6?.copyWith(
                                color: ColorPalette.blueDarkColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                              ),
                              decoration: InputDecoration(
                                border: InputBorder.none,

                                prefixIcon: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: SvgPicture.asset(
                                    AppIcons.userIcon,
                                    width: 24,
                                    height: 24,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.only(top: 15),
                                hintText: 'Usuario',
                                hintStyle:
                                Theme.of(context).textTheme.headline6?.copyWith(
                                  color: ColorPalette.blueDarkColor.withOpacity(0.5),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                ),
                              )
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('Contraseña',
                            style: Theme.of(context).textTheme.headline6?.copyWith(
                              color: ColorPalette.blueDarkColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 6.0,
                        ),
                        Container(
                          height: 50.0,
                          width: width,
                          decoration: BoxDecoration(
                            color: ColorPalette.whiteColor,
                            borderRadius: BorderRadius.circular(16.0),
                            border: Border.all(
                              color: ColorPalette.blueDarkColor,
                              width: 0.5,
                            ),
                          ),
                          child: TextFormField(
                              key: const Key('password'),
                              controller: passwordController,
                              style: Theme.of(context).textTheme.headline6?.copyWith(
                                color: ColorPalette.blueDarkColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                              ),
                              obscureText: _isObscure,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _isObscure = !_isObscure;
                                    });
                                  },
                                  icon: SvgPicture.asset(
                                    AppIcons.eyeicon,
                                    width: 24,
                                    height: 24,
                                  ),
                                ),
                                prefixIcon: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: SvgPicture.asset(
                                    AppIcons.password,
                                    width: 24,
                                    height: 24,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.only(top: 15),
                                hintText: 'Contraseña',
                                hintStyle:
                                Theme.of(context).textTheme.headline6?.copyWith(
                                  color: ColorPalette.blueDarkColor.withOpacity(0.5),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                ),
                              )),
                        ),
                        SizedBox(
                          height: height * 0.05,
                        ),
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () async {
                              addUser();
                              print(usuarioController.text);
                              print(passwordController.text);
                              bool? process = await login2(width);


                              if (process == true) {
                                LoadingDialog.showLoadingDialog(context, Texts.loadingData);
                                await onSuccess();
                              }
                              borderRadius:
                              BorderRadius.circular(16.0);
                            },
                            child: Ink(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 70.0, vertical: 18.0),
                              decoration: BoxDecoration(
                                color: ColorPalette.ticketsColor,
                                borderRadius: BorderRadius.circular(16.0),
                              ),
                              child: Text('Iniciar Sesión',
                                style: Theme.of(context).textTheme.headline6?.copyWith(
                                  color: ColorPalette.whiteColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ))),
          ],
        ),
      ),
    );
  }

  Widget _mobileBody(Size size, BuildContext context) {
    double height = size.height;
    double width = size.width;
    return Scaffold(
      backgroundColor: ColorPalette.backColor,
      body: SingleChildScrollView(
        child: Container(
          height: height, width: width,
          margin: const EdgeInsets.symmetric(horizontal: 15),
          color: ColorPalette.backColor,

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                height: height * 0.145,
              ),
              Center(
                child: Text(
                  'Bienvenido a Tickets',
                  style: Theme.of(context).textTheme.headline6?.copyWith(
                    color: ColorPalette.blueDarkColor,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),

                ),
              ),
              Center(
                child: SizedBox(
                  width: 300,
                  height: 250,
                  child: rv.RiveAnimation.asset(
                    'assets/Robo.riv',
                  ),
                ),
              ),
              SizedBox(
                height: height * 0.03,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Usuario',
                  style: Theme.of(context).textTheme.headline6?.copyWith(
                    color: ColorPalette.blueDarkColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              Container(
                height: 50.0,
                width: width,
                decoration: BoxDecoration(
                  color: ColorPalette.whiteColor,
                  borderRadius: BorderRadius.circular(16.0),
                  border: Border.all(
                    color: ColorPalette.blueDarkColor,
                    width: 0.5,
                  ),
                ),
                child: TextFormField(
                  key: const Key('usuario'),
                  controller: usuarioController,
                  style: Theme.of(context).textTheme.headline6?.copyWith(
                    color: ColorPalette.blueDarkColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    prefixIcon: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Icon(
                        Icons.person,
                        color: ColorPalette.blueDarkColor,
                      ),
                    ),
                    contentPadding: const EdgeInsets.only(top: 15),
                    hintText: 'Usuario',
                    hintStyle: Theme.of(context).textTheme.headline6?.copyWith(
                      color: ColorPalette.blueDarkColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 20.0,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Contraseña',
                  style: Theme.of(context).textTheme.headline6?.copyWith(
                    color: ColorPalette.blueDarkColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              Container(
                height: 50.0,
                width: width,
                decoration: BoxDecoration(
                  color: ColorPalette.whiteColor,
                  borderRadius: BorderRadius.circular(16.0),
                  border: Border.all(
                    color: ColorPalette.blueDarkColor,
                    width: 0.5,
                  ),
                ),
                child: TextFormField(
                  key: const Key('password'),
                  controller: passwordController,
                  style: Theme.of(context).textTheme.headline6?.copyWith(
                    color: ColorPalette.blueDarkColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                  obscureText: _isObscure,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isObscure ? Icons.visibility : Icons.visibility_off,
                        color: ColorPalette.blueDarkColor,
                      ),
                      onPressed: () {
                        setState(() {
                          _isObscure = !_isObscure;
                        });
                      },
                    ),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Icon(
                        Icons.lock,
                        color: ColorPalette.blueDarkColor,
                      ),
                    ),
                    contentPadding: const EdgeInsets.only(top: 19),
                    hintText: 'Contraseña',
                    hintStyle: Theme.of(context).textTheme.headline6?.copyWith(
                      color: ColorPalette.blueDarkColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: height * 0.05,
              ),
              Center(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () async {
                      addUser();
                      print(usuarioController.text);
                      print(passwordController.text);
                      bool? process = await login2(width);
                      if (process == true) {
                        onSuccess();
                      }
                    },
                    borderRadius: BorderRadius.circular(16.0),
                    child: Ink(
                      padding: const EdgeInsets.symmetric(
                        vertical: 14.0,
                        horizontal: 28.0,
                      ),
                      decoration: BoxDecoration(
                        color: ColorPalette.blueDarkColor,
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: Text(
                        'Iniciar Sesión',
                        style: Theme.of(context).textTheme.headline6?.copyWith(
                          color: ColorPalette.whiteColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget addUser() {
    return MyTextField(
      key: const Key('usuario'),
      decoration: const InputDecoration(
        errorStyle: TextStyle(height: 0),
      ),
      controller: usuarioController,
      backgroundColor: Colors.white.withOpacity(0.30),
      inputColor: const Color(0xff0B222B),
      colorBorder: const Color(0xff060D17).withOpacity(0.8),
      text: 'Usuario',
      validator: (usuario) {
        if (usuario == null || usuario.isEmpty) {
          return 'Ingrese el nombre de usuario';
        }
        return null; // Validación pasa
      },
    );
  }

  Widget addPassword(
    BuildContext context,
  ) {
    return MyTextField(
        key: const Key('password'),
        decoration: const InputDecoration(
          errorStyle: TextStyle(height: 0),
        ),
        controller: passwordController,
        backgroundColor: Colors.white.withOpacity(0.3),
        inputColor: const Color(0xff0B222B),
        colorBorder: const Color(0xff060D17).withOpacity(0.8),
        text: 'Contraseña',
        obscureText: _obscureText,
        suffixIcon: AnimatedBuilder(
          animation: _animation1,
          builder: (context, child) => Transform(
            transform: Matrix4.identity()..rotateX(_animation1.value),
            child: SizedBox(
                height: 0,
                width: 50,
                child: Center(
                    child: GestureDetector(
                  child: Icon(
                    isPressed ? Icons.visibility : Icons.visibility_off,
                    color: Colors.black,
                  ),
                  onTap: () {
                    _animationController1.forward();
                    Future.delayed(const Duration(milliseconds: 100), () {
                      _animationController1.reverse();
                      isPressed = !isPressed;
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    });
                  },
                ))),
          ),
        ),
        validator: (value) {
          if (value == "") {
            return 'Ingrese la contraseña';
          }
          return null;
        });
  }

  Future<void> login([double width = 0]) async {
    if (_formKey.currentState!.validate()) {
      try {
        LoadingDialog.showLoadingDialog(context, Texts.loadingData);
        LoginController loginController = LoginController();
        UsuarioModels? usuarioModels = await loginController.loginUser(
            usuarioController.text, passwordController.text, context);
        LoadingDialog.hideLoadingDialog(context);

        if (usuarioModels != null) {
          if (usuarioModels.estatus ?? false) {
            String empresaId = "";
            String empresaNombre = "";
            if (usuarioModels.empresas.length > 1) {
              empresaId = await getEmpresaId(usuarioModels.empresas);
              empresaNombre = usuarioModels.empresas
                  .firstWhere((element) => element.idEmpresa == empresaId)
                  .nombre;
            } else {
              empresaId = await usuarioModels.empresas.first.idEmpresa!;
              empresaNombre = await usuarioModels.empresas.first.nombre;
            }
            usuarioModels.empresaID = empresaId;
            usuarioModels.empresaNombre = empresaNombre;
            await userPreferences.guardarUsuario(usuarioModels);
            Navigator.of(context).pushReplacementNamed('TicketsHome');
          } else {
            CustomAwesomeDialog(
                    title: "Error al iniciar sesión",
                    desc: "Usuario inactivo",
                    btnOkOnPress: () {},
                    btnCancelOnPress: () {},
                    width: size.width < 500 ? size.width * .9 : null)
                .showError(context);
          }
        } else {
          CustomAwesomeDialog(
                  title: "Error al iniciar sesión",
                  desc: "Usuario y/o contraseña incorecta",
                  btnOkOnPress: () {},
                  btnCancelOnPress: () {},
                  width: size.width < 500 ? size.width * .9 : null)
              .showError(context);
        }
      } catch (e) {
        LoadingDialog.hideLoadingDialog(context);
        String error = await ConnectionExceptionHandler()
            .handleConnectionExceptionString(e);
        CustomAwesomeDialog(
                title: "Error al iniciar sesión",
                desc: error,
                btnOkOnPress: () {},
                btnCancelOnPress: () {},
                width: size.width < 500 ? size.width * .9 : null)
            .showError(context);
      }
    }
  }

  Future<bool?> login2([double width = 0]) async {
    if(usuarioController.text.isEmpty  && passwordController.text.isEmpty){
      CustomAwesomeDialog(
        title: "Error al iniciar sesión",
        desc: "Los campos usuario y contraseña no pueden estar vacíos",
        btnOkOnPress: () {},
        btnCancelOnPress: () {},
        width: size.width < 500 ? size.width * .9 : null,
      ).showError(context);
      return false;
    }else if (usuarioController.text.isEmpty ) {
      CustomAwesomeDialog(
        title: "Error al iniciar sesión",
        desc: "El campo usuario no pueden estar vacíos",
        btnOkOnPress: () {},
        btnCancelOnPress: () {},
        width: size.width < 500 ? size.width * .9 : null,
      ).showError(context);
      return false;
    }else if(passwordController.text.isEmpty){
      CustomAwesomeDialog(
        title: "Error al iniciar sesión",
        desc: "El campo contraseña no pueden estar vacíos",
        btnOkOnPress: () {},
        btnCancelOnPress: () {},
        width: size.width < 500 ? size.width * .9 : null,
      ).showError(context);
      return false;
    }
    LoadingDialog.showLoadingDialog(context, Texts.loadingData);
    try {
      //LoadingDialog.showLoadingDialog(context, Texts.loadingData);
      LoginController loginController = LoginController();
      usuarioModels = await loginController.loginUser(
          usuarioController.text, passwordController.text, context);
      //LoadingDialog.hideLoadingDialog(context);
      LoadingDialog.hideLoadingDialog(context);

      if (usuarioModels != null) {
        if (usuarioModels?.estatus ?? false) {
          return true;
        } else {
          CustomAwesomeDialog(
              title: "Error al iniciar sesión",
              desc: "Usuario inactivo",
              btnOkOnPress: () {},
              btnCancelOnPress: () {},
              width: size.width < 500 ? size.width * .9 : null)
              .showError(context);
          return false;
        }
      } else {
        CustomAwesomeDialog(
          title: "Error al iniciar sesión",
          desc: "Usuario y/o contraseña incorecta",
          btnOkOnPress: () {},
          btnCancelOnPress: () {},
          width: size.width < 500 ? size.width * .9 : null,
        ).showError(context);
        return false;
      }
    } catch (e) {
      String error =
      await ConnectionExceptionHandler().handleConnectionExceptionString(e);
      CustomAwesomeDialog(
        title: "Error al iniciar sesión",
        desc: error,
        btnOkOnPress: () {},
        btnCancelOnPress: () {},
        width: size.width < 500 ? size.width * .9 : null,
      ).showError(context);

      return false;

    }

    return false;
  }

  Future<void> onSuccess() async {
    if (usuarioModels != null) {
      String? empresaId = "";
      String? empresaNombre = "";

        empresaId = await usuarioModels?.empresas.first.idEmpresa!;
        empresaNombre = await usuarioModels?.empresas.first.nombre;

      usuarioModels?.empresaID = empresaId;
      usuarioModels?.empresaNombre = empresaNombre;
      await userPreferences.guardarUsuario(usuarioModels!);
    LoadingDialog.hideLoadingDialog(context);
      Navigator.of(context).pushReplacementNamed('TicketsHome');
    } else {
      LoadingDialog.hideLoadingDialog(context);

      // Handle the case where usuarioModels is null
      CustomAwesomeDialog(
        title: "Error",
        desc: "No se pudo obtener la información del usuario.",
        btnOkOnPress: () {},
        btnCancelOnPress: () {},
        width: size.width < 500 ? size.width * .9 : null,
      ).showError(context);

    }
  }

  void getThemeMode() async {
    bool? isDarkModeEnabled = await userPreferences.getTheme();
    this.isDarkModeEnabled = isDarkModeEnabled ?? false;
    ThemeMode themeMode =
        isDarkModeEnabled ?? false ? ThemeMode.dark : ThemeMode.light;
    MyApp.updateTheme(themeMode);
  }

  void getUser() async {
    try {
      UsuarioModels usuario = await userPreferences.getUsuario();
      if (usuario.idUsuario != "") {
        LoadingDialog.showLoadingDialog(context, Texts.loadingData);
        LoginController loginController = LoginController();
        UsuarioModels? usuarioModels =
            await loginController.checkUserStatus(usuario.idUsuario!);

        LoadingDialog.hideLoadingDialog(context);
        if (usuarioModels != null) {
          if (usuarioModels.userName == usuario.userName &&
              usuarioModels.contrasenia == usuario.contrasenia) {
            UserSession userSession = UserSession();
            DateTime? dateToken =
                DateTime.tryParse(await userSession.getDateTime());
            if (dateToken != null &&
                dateToken.isAfter(DateTime.now().subtract(Duration(days: 1)))) {
              print("Token aun valido");
            } else {
              print("Token expirado generando uno nuevo");

              loginController = LoginController();
              loginController.generateToken();
              print(await userSession.getToken().toString());
              print(await dateToken.toString());
            }
            Navigator.of(context).pushReplacementNamed('TicketsHome');
          } else {
            userPreferences.borrarUsuario();
          }
        } else {
          userPreferences.borrarUsuario();
        }
      }
    } catch (e) {
      LoadingDialog.hideLoadingDialog(context);
      String error =
          await ConnectionExceptionHandler().handleConnectionExceptionString(e);
      CustomAwesomeDialog(
              title: "Error al iniciar sesión",
              desc: error,
              width: size.width < 500 ? size.width * .9 : null,
              btnOkOnPress: () {},
              btnCancelOnPress: () {})
          .showError(context);
    }
  }

  Future<String> getEmpresaId(List<EmpresaModels> empresas) async {
    String empresaId = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Selecciona una empresa',
            style: TextStyle(color: themeData.colorScheme.onPrimary),
          ),
          content: SizedBox(
              width: 500,
              height: 350,
              child: Scrollbar(
                  thumbVisibility: true,
                  controller: _scrollController,
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: empresas.length,
                      itemBuilder: (BuildContext context, int index) {
                        return ListTile(
                          title: Text(empresas[index]
                              .nombre), // Asume que cada empresa tiene un atributo 'nombre'
                          onTap: () {
                            Navigator.of(context).pop(empresas[index]
                                .idEmpresa); // Asume que cada empresa tiene un atributo 'id'
                          },
                        );
                      },
                    ),
                  ))),
        );
      },
    );
    return empresaId;
  }
}
