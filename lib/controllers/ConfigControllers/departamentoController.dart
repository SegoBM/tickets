import 'dart:convert';
import 'package:tickets/models/ConfigModels/departamento.dart';
import 'package:tickets/shared/utils/constants.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

const urlapi= url;
const waitTime1 = waitTime;

class DepartamentoController with ChangeNotifier {
  DepartamentoController() {}

  //SAVE
  Future<bool> saveDepartamentoPuestos (DepartamentoModels departamento) async {
    final url1 = Uri.http(urlapi, '/api/Departamento/SavePuestos');

    const int maxAttempts = 3;
    int attempts = 0;

    while (attempts < maxAttempts) {
      try {
        final resp = await http.post(url1,
          body: jsonEncode({
            "departamentos": {
              "nombre": '${departamento.nombre}',
              "areaID": '${departamento.areaId}',
              "estatus": true
            },
            "puestos": departamento.puestos!.map((puesto) => puesto.toJson2()).toList()
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
  Future<bool> updateDepartamento (String idDepartamento, DepartamentoModels departamento) async{
    final url1 = Uri.http(urlapi, '/api/Departamento/Update', {'id': idDepartamento});
    const int maxAttempts = 3;
    int attempts = 0;

    while (attempts < maxAttempts) {
      try {
        final resp = await http.post(url1,
          body: jsonEncode({
            "departamentos": {
              "nombre": '${departamento.nombre}',
              "areaID": '${departamento.areaId}',
              "estatus": true
            },
            "puestos": departamento.puestos!.map((puesto) => puesto.toJson2()).toList()
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

    //DELETE
  Future<bool> deleteDepartamento (String IdDepartamento)async {
    final url1 = Uri.http(urlapi, '/api/Departamento/Delete', {'id' : IdDepartamento.toString()});
    const int maxAttempts = 3;
    int attempts = 0;

    while (attempts < maxAttempts) {
      try {
        final resp = await http.delete(url1,
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
  Future<bool> checkDepartamento (String nombreDepartamento, String empresaID)async {
    final url1 = Uri.http(urlapi, '/api/Departamento/CheckDepartamento', {'nombreDepartamento' : nombreDepartamento, 'empresaID' : empresaID});
    const int maxAttempts = 3;
    int attempts = 0;

    while (attempts < maxAttempts) {
      try {
        final resp = await http.get(url1,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        );
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
