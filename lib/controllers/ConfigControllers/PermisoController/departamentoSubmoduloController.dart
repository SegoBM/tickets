import 'dart:convert';
import 'package:tickets/shared/utils/constants.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

import '../../../models/ConfigModels/PermisoModels/departamentoSubmodulo.dart';


const urlapi= url;

class DepartamentoSubmoduloController with ChangeNotifier {
  DepartamentoSubmoduloController() {}

  //GET
  Future<List<DepartamentoSubmodulo>> getDepartamentoSubmodulo(String idUsuario) async {
    List<DepartamentoSubmodulo> listDepartamentoSubmodulo = [];
    final url1 = Uri.http(urlapi, '/api/DepartamentoSubModulo', {'id': idUsuario});
    final response = await http.get(url1, headers: {
      "Access-Control-Allow-Origin": "*",
      "Access-Control-Allow-Credentials": "true",
      'Content-type': 'application/json',
      'Accept': 'application/json'
    });

    if (response.statusCode == 200) {
      listDepartamentoSubmodulo = departamentoSubmoduloFromJson(response.body);
    } else {
      print('*Error en la solicitud*: ${response.statusCode}');
    }
    return listDepartamentoSubmodulo;
  }
  Future<DepartamentoSubmodulo?> saveDepartamentoSubmodulo(DepartamentoSubmodulo departamentoSubmodulo) async {
    final url1 = Uri.http(urlapi, '/api/DepartamentoSubModulo/Save');
    final response = await http.post(url1,
      body: jsonEncode({
      "departamentoID": departamentoSubmodulo.departamentoId,
      "subModuloID": departamentoSubmodulo.subModuloId,
    }),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return DepartamentoSubmodulo.fromJson(jsonDecode(response.body));
    } else {
      print('*Error en la solicitud*: ${response.statusCode}');
      return null;
    }
  }
  Future<List<DepartamentoSubmodulo>> saveDepartamentoSubmodulos(String idDepartamento, String idSubmodulo) async{
    List<DepartamentoSubmodulo> listDepartamentoSubmodulo = [];

    final url1 = Uri.http(urlapi, '/api/DepartamentoSubModulo/Update',{"idDepartamento": idDepartamento, "idModulo": idSubmodulo});
    final response = await http.put(url1,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      listDepartamentoSubmodulo = departamentoSubmoduloFromJson(response.body);
    } else {
      print('*Error en la solicitud*: ${response.statusCode}');
    }
    return listDepartamentoSubmodulo;
  }
  Future<bool> deleteDepartamentoSubmodulo(String idDepartamentoSubmodulo) async {
    final url1 = Uri.http(urlapi, '/api/DepartamentoSubModulo/Delete', {'id': idDepartamentoSubmodulo});
    final response = await http.delete(url1, headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    });

    if (response.statusCode == 200) {
      return true;
    } else {
      print('*Error en la solicitud*: ${response.statusCode}');
      return false;
    }
  }
  Future<bool> deleteDepartamentoModulo(String idDepartamento, String idSubmodulo) async{

    final url1 = Uri.http(urlapi, '/api/DepartamentoSubModulo/DeleteModule',{"idDepartamento": idDepartamento, "idModulo": idSubmodulo});
    final response = await http.delete(url1,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print('*Error en la solicitud*: ${response.statusCode}');
    }
    return false;
  }
}