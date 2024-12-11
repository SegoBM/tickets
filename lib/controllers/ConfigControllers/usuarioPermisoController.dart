import 'dart:convert';
import 'package:tickets/models/ConfigModels/usuarioPermiso.dart';
import 'package:tickets/shared/utils/constants.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

import '../../models/ConfigModels/userSession.dart';

const urlapi= url;
const waitTime1 = waitTime;

class UsuarioPermisoController with ChangeNotifier {
  UsuarioPermisoController() {}

  //GET
  Future<List<UsuarioPermisoModels>> getUsuariosPermiso(String usuarioID) async {
    String? token = await UserSession().getToken();
    List<UsuarioPermisoModels> listUsuariosPermisos = [];
    print("Obteniendo permisos");
    final url1 = Uri.http(urlapi, '/api/usuarioPermiso/${usuarioID.toUpperCase()}',{
      'id': usuarioID.toUpperCase()
    });
    const int maxAttempts = 3; // Número máximo de intentos
    int attempts = 0;

    while (attempts < maxAttempts) {
      try {
        final response = await http.get(url1, headers: {
          'Content-type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token'
        });
        if (response.statusCode == 200) {
          listUsuariosPermisos = usuarioPermisoModelsFromJson(response.body.toString());
          return listUsuariosPermisos;
        } else {
          print('*Error en la solicitud*: ${response.statusCode}');
          attempts++;
          if (attempts >= maxAttempts) {
            return listUsuariosPermisos;
          }
        }
      } catch (e) {
        print('Error al enviar la solicitud: $e');
        attempts++;
        if (attempts >= maxAttempts) {
          return listUsuariosPermisos;
        }
      }
      await Future.delayed(const Duration(seconds: waitTime1));
    }
    return listUsuariosPermisos;
  }

  //POST
  Future<bool> saveUsuarioPermiso(UsuarioPermisoModels usuarioPermiso, BuildContext context) async {
    String? token = await UserSession().getToken();
    final url1 = Uri.http(urlapi, '/api/usuarioPermiso/Save');
    const int maxAttempts = 3; // Número máximo de intentos
    int attempts = 0;

    while (attempts < maxAttempts) {
      try {
        final resp = await http.post(
          url1,
          body: jsonEncode({
            "usuaroID": '${usuarioPermiso.usuarioId}',
            "permisoID": '${usuarioPermiso.permisoId}'
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

  //DELETE
  Future<bool> deleteUsuarioPermiso(String usuarioID, String permisoID, BuildContext context) async {
    String? token = await UserSession().getToken();
    final url1 = Uri.http(urlapi, '/api/usuarioPermiso/Delete', {
      'usuarioID': usuarioID.toString(), 'permisoID': permisoID.toString()});
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
}
