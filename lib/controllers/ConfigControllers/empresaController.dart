import 'dart:convert';
import 'package:tickets/models/ConfigModels/empresa.dart';
import 'package:tickets/shared/utils/constants.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import '../../shared/utils/user_preferences.dart';

const urlapi= url;
const waitTime1 = waitTime;

class EmpresaController with ChangeNotifier {
  EmpresaController() {}

  //GET
  Future<List<EmpresaModels>> getEmpresas(String usuarioID) async {
    List<EmpresaModels> listEmpresas = [];
    final url1 = Uri.http(urlapi, '/api/Empresa/Activas',{"IDUsuario": usuarioID});
    const int maxAttempts = 3;
    int attempts = 0;

    while (attempts < maxAttempts) {
      try {
        final response = await http.get(url1, headers: {
          "Access-Control-Allow-Origin": "*",
          "Access-Control-Allow-Credentials": "true",
          'Content-type': 'application/json',
          'Accept': 'application/json'
        });

        if (response.statusCode == 200) {
          listEmpresas = empresaModelsFromJson(response.body);
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

  //POST
  Future<bool> saveEmpresa(EmpresaModels empresa) async {
    UserPreferences userPreferences = UserPreferences();
    String idUsuario =await userPreferences.getUsuarioID();
    final url1 = Uri.http(urlapi, '/api/Empresa/AddEmpresa', {"idUsuario": idUsuario});
    const int maxAttempts = 3;
    int attempts = 0;

    while (attempts < maxAttempts) {
      try {
        final resp = await http.post(
          url1,
          body: jsonEncode({
            "nombre": '${empresa.nombre}',
            "direccion": '${empresa.direccion}',
            "razonSocial": '${empresa.razonSocial}',
            "estatus": true,
            "RFC": '${empresa.rfc}',
            "CP": '${empresa.cp}',
            "giro": '${empresa.giro}',
            "telefono": '${empresa.telefono}',
            "correo": '${empresa.correo}',
            "regimenFiscal": '${empresa.regimenFiscal}',
            "selloDigital": '${empresa.selloDigital}',
            "direccionFiscal": '${empresa.direccionFiscal}',
            "logo": empresa.logo ?? null
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
  Future<bool> updateEmpresa (String IdEmpresa, EmpresaModels empresa, BuildContext context) async {
  final url1 = Uri.http(urlapi, '/api/Empresa/Update', {'id': IdEmpresa});
  const int maxAttempts = 3;
  int attempts = 0;

  while (attempts < maxAttempts) {
    try {
      final resp = await http.put(
        url1,
        body: jsonEncode({
          "idEmpresa": '${empresa.idEmpresa}',
          "nombre": '${empresa.nombre}',
          "direccion": '${empresa.direccion}',
          "razonSocial": '${empresa.razonSocial}',
          "RFC": '${empresa.rfc}',
          "CP": '${empresa.cp}',
          "giro": '${empresa.giro}',
          "telefono": '${empresa.telefono}',
          "correo": '${empresa.correo}',
          "regimenFiscal": '${empresa.regimenFiscal}',
          "selloDigital": '${empresa.selloDigital}',
          "direccionFiscal": '${empresa.direccionFiscal}',
          "logo": empresa.logo
        }),
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
  Future<bool> deleteEmpresa (String IdEmpresa) async {
    final url1 = Uri.http(urlapi, '/api/Empresa/Delete', {'id': IdEmpresa.toString()});
    const int maxAttempts = 3;
    int attempts = 0;

    while (attempts < maxAttempts) {
      try {
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
  Future<bool> checkEmpresa(String nombreEmpresa, String rfc) async {
    final url1 = Uri.http(urlapi, '/api/Empresa/CheckEmpresa',
        {'nombreEmpresa': nombreEmpresa, 'rfc': rfc});
    const int maxAttempts = 3;
    int attempts = 0;

    while (attempts < maxAttempts) {
      try {
        final resp = await http.get(url1, headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        });
        if (resp.statusCode == 200) {
          return true;
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
}
