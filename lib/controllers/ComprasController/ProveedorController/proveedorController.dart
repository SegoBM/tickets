import 'dart:convert';
import 'package:tickets/models/ComprasModels/ProveedorModels/proveedor.dart';
import 'package:tickets/shared/utils/constants.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import '../../../models/ComprasModels/DatosBancariosModels/datosBancarios.dart';
const urlapi= url;

class ProveedorController with ChangeNotifier {
  ProveedorController() {}

  //GET
  Future<List<ProveedorModels>> getProveedores() async {
    List<ProveedorModels> listProveedores = [];
    final url1 = Uri.http(urlapi, '/api/Proveedores');
    final response = await http.get(url1, headers: {
      "Access-Control-Allow-Origin": "*",
      "Access-Control-Allow-Credentials": "true",
      'Content-type': 'application/json',
      'Accept': 'application/json'
    });

    if (response.statusCode == 200) {
      listProveedores = proveedorModelsFromJson(response.body);
    } else {
      print('*Error en la solicitud*: ${response.statusCode}');
    }
    return listProveedores;
  }

  Future<List<ProveedorModels>> getProveedoresActivos() async {
    List<ProveedorModels> listProveedores = [];
    final url1 = Uri.http(urlapi, '/api/Proveedores/Activos');
    final response = await http.get(url1, headers: {
      "Access-Control-Allow-Origin": "*",
      "Access-Control-Allow-Credentials": "true",
      'Content-type': 'application/json',
      'Accept': 'application/json'
    });

    if (response.statusCode == 200) {
      listProveedores = proveedorModelsFromJson(response.body);
    } else {
      print('*Error en la solicitud*: ${response.statusCode}');
    }
    return listProveedores;
  }

  //POST
  Future<bool> saveProveedor(ProveedorModels proveedor) async {
    final url1 = Uri.http(urlapi, '/api/Proveedor/AddProveedor');
    final resp = await http.post(
      url1,
      body: jsonEncode({
        "nombre": '${proveedor.nombre}',
        "razonSocial" : '${proveedor.razonSocial}',
        "rfc" : '${proveedor.rfc}',
        "correoElectronico" : '${proveedor.correoElectronico}',
        "telefono" : '${proveedor.telefono}',
        "descripcion" : '${proveedor.descripcion}',
        "colonia" : '${proveedor.colonia}',
        "calle" : '${proveedor.calle}',
        "numExt": '${proveedor.numExt}',
        "numInt" : '${proveedor.numInt}',
        "codigoPostal" : '${proveedor.codigoPostal}',
        "ciudad" : '${proveedor.ciudad}',
        "pais" : '${proveedor.pais}',
        "estatus" : true,
        "estado" : '${proveedor.estado}',
      }),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
    if (resp.statusCode == 200 || resp.statusCode == 201) {
      return true;
    } else {
      print(resp.body);
      return false;
    }
  }

 // POST
  Future<bool> saveProveedorConDatosBancarios(ProveedorModels proveedor, List<DatosBancariosModels> datosBancarios,
      List<String> materialesID, List<String> productosServiciosID) async {
    final url1 = Uri.http(urlapi, '/api/Proveedor/AddProveedorConDatosBancarios');
    final resp = await http.post(
      url1,
      body: jsonEncode({
        "proveedor": {
          "nombre": '${proveedor.nombre}',
          "razonSocial": '${proveedor.razonSocial}',
          "rfc": '${proveedor.rfc}',
          "correoElectronico": '${proveedor.correoElectronico}',
          "telefono": '${proveedor.telefono}',
          "descripcion": '${proveedor.descripcion}',
          "colonia": '${proveedor.colonia}',
          "calle": '${proveedor.calle}',
          "numExt": '${proveedor.numExt}',
          "numInt": '${proveedor.numInt}',
          "codigoPostal": '${proveedor.codigoPostal}',
          "ciudad": '${proveedor.ciudad}',
          "pais": '${proveedor.pais}',
          "estatus": true,
          "estado": '${proveedor.estado}',
        },
        "datosBancarios": datosBancarios.map((datosBancarios) => datosBancarios.toJson()).toList(),
        "materialesID": materialesID,
        "productosServiciosID": productosServiciosID
      }),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
    if (resp.statusCode == 200 || resp.statusCode == 201) {
      return true;
    } else {
      print(resp.body);
      return false;
    }
  }

  //PUT
  Future<bool> updateProveedor(ProveedorModels proveedor, List<DatosBancariosModels> datosBancarios,
      List<String> materialesID, List<String> productosServiciosID) async {
    final url1 = Uri.http(urlapi, '/api/Proveedor/Update', {"idProveedor": proveedor.idProveedor});
    final resp = await http.put(
      url1,
      body: jsonEncode({
       // "idProveedor": '${proveedor.idProveedor}',
        proveedor: {
        "nombre": '${proveedor.nombre}',
        "razonSocial": '${proveedor.razonSocial}',
        "rfc": '${proveedor.rfc}',
        "correoElectronico": '${proveedor.correoElectronico}',
        "telefono": '${proveedor.telefono}',
        "descripcion": '${proveedor.descripcion}',
        "colonia": '${proveedor.colonia}',
        "calle": '${proveedor.calle}',
        "numExt": '${proveedor.numExt}',
        "numInt": '${proveedor.numInt}',
        "codigoPostal": '${proveedor.codigoPostal}',
        "ciudad": '${proveedor.ciudad}',
        "pais": '${proveedor.pais}',
        "estatus": true,
        "estado": '${proveedor.estado}',
      },
        "datosBancarios": datosBancarios.map((datosBancarios) => datosBancarios.toJson()).toList(),
        "materialesID": materialesID,
        "productosServiciosID": productosServiciosID
      }),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
    if (resp.statusCode == 200 || resp.statusCode == 201) {
      return true;
    } else {
      print(resp.body);
      return false;
    }
  }

  //DELETE
  Future<bool> deleteProveedor(String idProveedor) async {
    final url1 = Uri.http(urlapi, '/api/Proveedor/Delete', {"idProveedor": idProveedor});
    final resp = await http.delete(
      url1,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
    if (resp.statusCode == 200) {
      return true;
    } else if (resp.statusCode == 404) {
      return false;
    } else {
      print(resp.body);
      return false;
    }
  }

  Future<bool> reactiveProveedor(String idProveedor) async {
    final url1 = Uri.http(urlapi, '/api/Proveedor/Reactive', {"idProveedor": idProveedor});
    final resp = await http.put(
      url1,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
    if (resp.statusCode == 200) {
      return true;
    } else if (resp.statusCode == 404) {
      return false;
    } else {
      print(resp.body);
      return false;
    }
  }
}
