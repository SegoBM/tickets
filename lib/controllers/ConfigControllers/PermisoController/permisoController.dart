import 'dart:convert';
import 'package:tickets/shared/utils/constants.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import '../../../models/ConfigModels/PermisoModels/Modulo.dart';
import '../../../models/ConfigModels/PermisoModels/permiso.dart';
import '../../../models/ConfigModels/PermisoModels/submoduloPermisos.dart';


const urlapi= url;

class PermisoController with ChangeNotifier {
  PermisoController() {}

  //GET
  Future<List<PermisoModels>> getPermisos() async {
    List<PermisoModels> listPermisos= [];
    final url1 = Uri.http(urlapi, '/api/Permiso');
    final response = await http.get(url1, headers: {
      "Access-Control-Allow-Origin": "*",
      "Access-Control-Allow-Credentials": "true",
      'Content-type': 'application/json',
      'Accept': 'application/json'
    });

    if (response.statusCode == 200) {
      listPermisos = permisoModelsFromJson(response.body);
    } else {
      print('*Error en la solicitud*: ${response.statusCode}');
    }
    return listPermisos;
  }
  Future<List<SubmoduloPermisos>> getPermisoSubmodulos() async {
    List<SubmoduloPermisos> listPermisos= [];
    final url1 = Uri.http(urlapi, '/api/Permiso/Submodulo');
    final response = await http.get(url1, headers: {
      "Access-Control-Allow-Origin": "*",
      "Access-Control-Allow-Credentials": "true",
      'Content-type': 'application/json',
      'Accept': 'application/json'
    });


    if (response.statusCode == 200) {
      listPermisos = submoduloPermisosFromJson(response.body);
    } else {
      print('*Error en la solicitud*: ${response.statusCode}');
    }
    return listPermisos;
  }
  Future<List<Modulo>> getPermisoModulos() async {
    List<Modulo> listPermisos= [];
    final url1 = Uri.http(urlapi, '/api/Modulo/ModuloSubmodulo');
    final response = await http.get(url1, headers: {
      "Access-Control-Allow-Origin": "*",
      "Access-Control-Allow-Credentials": "true",
      'Content-type': 'application/json',
      'Accept': 'application/json'
    });

    if (response.statusCode == 200) {
      listPermisos = moduloFromJson(response.body);
    } else {
      print('*Error en la solicitud*: ${response.statusCode}');
    }
    return listPermisos;
  }
  Future<bool> updatePermiso(String id, String permiso, String idUsuario) async {
    final url1 = Uri.http(urlapi, '/api/Permiso/Update', {'id': id, 'usuarioID' : idUsuario});
    return http.put(url1, headers: {
      "Access-Control-Allow-Origin": "*",
      "Access-Control-Allow-Credentials": "true",
      'Content-type': 'application/json',
      'Accept': 'application/json'
    }, body: jsonEncode({
      "tipoUsuario": permiso
    })).then((response) {
      if (response.statusCode == 200) {
        return true;
      } else {
        print('*Error en la solicitud*: ${response.statusCode}');
        return false;
      }
    });
  }
}
