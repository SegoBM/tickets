import 'dart:convert';

import 'package:tickets/shared/utils/constants.dart';
import 'package:tickets/models/ConfigModels/usuario.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

import '../../models/ConfigModels/userSession.dart';

const urlapi= url;
const waitTime1 = waitTime;

class LoginController with ChangeNotifier {
  LoginController() {}

  Future<UsuarioModels?> loginUser(String username, String password, BuildContext context) async {
    UsuarioModels? usuario = null;
    final url1 = Uri.http(urlapi, '/api/Login/Login',{
          'userName': '$username',
          'password': '$password',
          'codigo'  : 'LJSHFIJHAIAUGSVUAVDUFAVSVAGV332&ASBAJSBI',
        });
    print('URL: $url1');
    const int maxAttempts = 3; // Número máximo de intentos
    int attempts = 0;
    while (attempts < maxAttempts) {
      try {
        print('Intento $attempts');
        final response = await http.post(url1, headers: {
          'Content-type': 'application/json',
          'Accept': 'application/json'
        });
        print(response.statusCode);
        if (response.statusCode == 200) {
          UserSession userSession = UserSession();
          DateTime? dateToken = DateTime.tryParse(await userSession.getDateTime());
          if(dateToken!= null && dateToken.isAfter(DateTime.now().subtract(Duration(days:1)))) {
            print("Token aun valido");
          }else{
            print("Generando nuevo token");
            await generateToken();
          }
          usuario = usuarioFromJsonS(response.body);
          return usuario;
        } else {
          print('*Error en la solicitud*: ${response.statusCode}');
          attempts++;
          if (attempts >= maxAttempts) {
            return null;
          }
        }
      } catch (e) {
        print('Error al enviar la solicitud: $e');
        attempts++;
        if (attempts >= maxAttempts) {
          return null;
        }
      }
      await Future.delayed(const Duration(seconds: waitTime));
    }
    return null;
  }
  Future<UsuarioModels?> checkUserStatus(String IdUsuario) async {
    UsuarioModels? usuario;
    final url1 = Uri.http(urlapi, '/api/Login/CheckUserStatus',{'IdUsuario': IdUsuario,});
    const int maxAttempts = 3; // Número máximo de intentos
    int attempts = 0;

    while (attempts < maxAttempts) {
      try {
        print('Intento $attempts');
        final response = await http.get(url1, headers: {
          'Content-type': 'application/json',
          'Accept': 'application/json'
        });

        if (response.statusCode == 200) {
          usuario = usuarioFromJsonS2(response.body);
          return usuario;
        } else {
          print('*Error en la solicitud*: ${response.body}');
          attempts++;
          if (attempts >= maxAttempts) {
            return null;
          }
        }
      } catch (e) {
        print('Error al enviar la solicitud: $e');
        attempts++;
        if (attempts >= maxAttempts) {
          return null;
        }
      }
      await Future.delayed(const Duration(seconds: waitTime));
    }
    return null;
  }

  Future <String> generateToken () async{
    final url1 = Uri.http(urlapi, '/api/Token/GenerateToken',{
          'password': 'LJSHFIJHAIAUGSVUAVDUFAVSVAGV332&ASBAJSBI',
        });
    const int maxAttempts = 3; // Número máximo de intentos
    int attempts = 0;
    while (attempts < maxAttempts) {
      try {
        print('Intento $attempts');
        final response = await http.post(url1, headers: {
          'Content-type': 'application/json',
          'Accept': 'application/json'
        });

        if (response.statusCode == 200) {
          final responseData = json.decode(response.body);
          String token = responseData['token'];

          await UserSession().setToken(token);
          await UserSession().setDateTime(DateTime.now().toString());

          return token;
        } else {
          print('*Error en la solicitud*: ${response.statusCode}');
          attempts++;
          if (attempts >= maxAttempts) {
            return '';
          }
        }
      } catch (e) {
        print('Error al enviar la solicitud: $e');
        attempts++;
        if (attempts >= maxAttempts) {
          return '';
        }
      }
      await Future.delayed(const Duration(seconds: waitTime));
    }
    return '';
  }
}