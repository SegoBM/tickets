import 'dart:convert';
import 'package:tickets/models/ConfigModels/usuarioPermiso.dart';
import 'package:tickets/shared/utils/constants.dart';
import 'package:tickets/models/ConfigModels/usuario.dart';
import 'package:flutter/widgets.dart';
import 'package:tickets/shared/utils/user_preferences.dart';
import 'package:http/http.dart' as http;

import '../../models/ConfigModels/userSession.dart';

const urlapi= url;
const waitTime1 = waitTime;

class UsuarioController with ChangeNotifier {
  UsuarioController() {}

  Future<List<UsuarioModels>> getUsuariosActivos(String empresaID) async {
    String? token = await UserSession().getToken();
    List<UsuarioModels> listUsuarios = [];
    final url1 = Uri.http(urlapi, '/api/Usuario/Activos',{'empresasID': empresaID});
    const int maxAttempts = 3; // Número máximo de intentos
    int attempts = 0;

    while (attempts < maxAttempts) {
      print('Intento $attempts');
      try {
        final response = await http.get(url1, headers: {
          "Access-Control-Allow-Origin": "*",
          "Access-Control-Allow-Credentials": "true",
          'Content-type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token'

        });
        print(token);

        if (response.statusCode == 200) {
          listUsuarios = usuarioModelsFromJson2(response.body);
          return listUsuarios;
        } else {
          print('*Error en la solicitud*: ${response.statusCode}');
          attempts++;
          if (attempts >= maxAttempts) {
            return listUsuarios;
          }
        }
      } catch (e) {
        print('Error al enviar la solicitud: $e');
        attempts++;
        if (attempts >= maxAttempts) {
          return listUsuarios;
        }
      }
      await Future.delayed(const Duration(seconds: waitTime1));
    }
    return listUsuarios;
  }

  Future<bool> saveUsuarioConPermiso(UsuarioModels usuario, List<UsuarioPermisoModels> usuarioPermisos, List<String> empresas) async {
    String? token = await UserSession().getToken();
    UserPreferences userPreferences = UserPreferences();
    String idUsuario =await userPreferences.getUsuarioID();
    final url1 = Uri.http(urlapi, '/api/Usuario/SaveConPermisos', {"UsuarioID": idUsuario});
    const int maxAttempts = 3; // Número máximo de intentos
    int attempts = 0;

    while (attempts < maxAttempts) {
      try {
        final resp = await http.post(url1,
          body: jsonEncode({
            "usuario": {
              "nombre": '${usuario.nombre}',
              "apellidoPaterno": '${usuario.apellidoPaterno}',
              "apellidoMaterno": '${usuario.apellidoMaterno}',
              "userName": '${usuario.userName}',
              "contrasenia": '${usuario.contrasenia}',
              "tipoUsuario": '${usuario.tipoUsuario}',
              "estatus": true,
              "puestoId": '${usuario.puestoId}',
              "imagen": usuario.imagen
            },
            "usuarioPermisos": usuarioPermisos.map((usuarioPermiso) => usuarioPermiso.toJson2()).toList(),
            "empresas": empresas
          }),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token'

          },
        );
        if (resp.statusCode == 200 || resp.statusCode == 201) {
          return true;
        } else {
          print(resp.body);
          attempts++;
          if (attempts >= maxAttempts) {
            return false;
          }
        }
      } catch (e) {
        print('Error al enviar la solicitud: $e');
        attempts++;
        if (attempts >= maxAttempts) {
          return false;
        }
      }
      await Future.delayed(const Duration(seconds: waitTime1));
    }
    return false;
  }
  //UPDATE
  Future<bool> updateUsuario(UsuarioModels usuario,List<UsuarioPermisoModels> usuarioPermisos, List<String> empresas) async {
    String? token = await UserSession().getToken();
    UserPreferences userPreferences = UserPreferences();
    String idUsuario = await userPreferences.getUsuarioID();
    final url1 = Uri.http(urlapi, '/api/Usuario/Update', {"UsuarioID": idUsuario});
    const int maxAttempts = 3; // Número máximo de intentos
    int attempts = 0;

    while (attempts < maxAttempts) {
      try {
        final resp = await http.put(
          url1,
          body: jsonEncode({
            "usuario": {
              "idUsuario": '${usuario.idUsuario}',
              "nombre": '${usuario.nombre}',
              "apellidoPaterno": '${usuario.apellidoPaterno}',
              "apellidoMaterno": '${usuario.apellidoMaterno}',
              "userName": '${usuario.userName}',
              "contrasenia": '${usuario.contrasenia}',
              "tipoUsuario": '${usuario.tipoUsuario}',
              "puestoId": '${usuario.puestoId}',
              "imagen": "${usuario.imagen}"
            },
            "usuarioPermisos": usuarioPermisos.map((usuarioPermiso) => usuarioPermiso.toJson2()).toList(),
            "empresas": empresas
          }),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token'

          },
        );
        if (resp.statusCode == 200) {
          return true;
        } else if (resp.statusCode == 404) {
          print(resp.body);
          attempts++;
          if (attempts >= maxAttempts) {
            return false;
          }
        } else {
          print(resp.body);
          attempts++;
          if (attempts >= maxAttempts) {
            return false;
          }
        }
      } catch (e) {
        print('Error al enviar la solicitud: $e');
        attempts++;
        if (attempts >= maxAttempts) {
          return false;
        }
      }
      await Future.delayed(const Duration(seconds: waitTime1));
    }
    return false;
  }
  Future<bool> checkUser(String userName, String password) async {
    String? token = await UserSession().getToken();
    final url1 = Uri.http(urlapi, '/api/Usuario/CheckUser', {'userName': userName, 'password': password});
    const int maxAttempts = 3; // Número máximo de intentos
    int attempts = 0;

    while (attempts < maxAttempts) {
      try {
        final resp = await http.get(url1,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token'

          },
        );
        if (resp.statusCode == 200) {
          return true;
        } else if (resp.statusCode == 404) {
          return false;
        } else {
          attempts++;
          if (attempts >= maxAttempts) {
            return false;
          }
        }
      } catch (e) {
        print('Error al enviar la solicitud: $e');
        attempts++;
        if (attempts >= maxAttempts) {
          return false;
        }
      }
      await Future.delayed(const Duration(seconds: waitTime1));
    }
    return false;
  }
  //DELETE
  Future<bool> deleteUsuario(String IdUsuario) async {
    String? token = await UserSession().getToken();
    UserPreferences userPreferences = UserPreferences();
    String idUsuario =await userPreferences.getUsuarioID();
    final url1 = Uri.http(urlapi, '/api/Usuario/Delete', {'id': IdUsuario,"UsuarioID": idUsuario});
    const int maxAttempts = 3; // Número máximo de intentos
    int attempts = 0;

    while (attempts < maxAttempts) {
      try {
        final resp = await http.delete(
          url1,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token'

          },
        );
        if (resp.statusCode == 200) {
          return true;
        } else if (resp.statusCode == 404) {
          return false;
        } else {
          attempts++;
          if (attempts >= maxAttempts) {
            return false;
          }
        }
      } catch (e) {
        print('Error al enviar la solicitud: $e');
        attempts++;
        if (attempts >= maxAttempts) {
          return false;
        }
      }
      await Future.delayed(const Duration(seconds: waitTime1));
    }
    return false;
  }
  Future<bool> reactiveUsuario(String id) async {
    String? token = await UserSession().getToken();
    UserPreferences userPreferences = UserPreferences();
    String idUsuario =await userPreferences.getUsuarioID();
    final url1 = Uri.http(urlapi, '/api/Usuario/Reactive', {'IdUsuario': id, "UsuarioID": idUsuario});
    const int maxAttempts = 3; // Número máximo de intentos
    int attempts = 0;

    while (attempts < maxAttempts) {
      try {
        final resp = await http.put(
          url1,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token'

          },
        );
        if (resp.statusCode == 200) {
          return true;
        } else if (resp.statusCode == 404) {
          return false;
        } else {
          attempts++;
          if (attempts >= maxAttempts) {
            return false;
          }
        }
      } catch (e) {
        print('Error al enviar la solicitud: $e');
        attempts++;
        if (attempts >= maxAttempts) {
          return false;
        }
      }
      await Future.delayed(const Duration(seconds: waitTime1));
    }
    return false;
  }
  Future<List<String>> getEmpresasIDs(String id) async {
    String? token = await UserSession().getToken();
    List<String> listEmpresas= [];
    final url1 = Uri.http(urlapi, '/api/Usuario/UsuarioEmpresa', {"id": id});
    const int maxAttempts = 3; // Número máximo de intentos
    int attempts = 0;

    while (attempts < maxAttempts) {
      try {
        final response = await http.get(url1, headers: {
          "Access-Control-Allow-Origin": "*",
          "Access-Control-Allow-Credentials": "true",
          'Content-type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token'

        });
        print(token);
        if (response.statusCode == 200) {
          print(token);
          listEmpresas = List<String>.from(jsonDecode(response.body));
          return listEmpresas;
        } else {
          print('*Error en la solicitud*: ${response.statusCode}');
          attempts++;
          if (attempts >= maxAttempts) {
            return listEmpresas;
          }
        }
      } catch (e) {
        print('Error al enviar la solicitud: $e');
        attempts++;
        if (attempts >= maxAttempts) {
          return listEmpresas;
        }
      }
      await Future.delayed(const Duration(seconds: waitTime1));
    }
    return listEmpresas;
  }
}
