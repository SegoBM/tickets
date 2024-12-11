import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:tickets/models/ComprasModels/MaterialesModels/familia_model.dart';
import '../../../shared/utils/constants.dart';

const urlapi = url;
const waitTime1 = waitTime;

class FamiliaController with ChangeNotifier {
  FamiliaController() {}
   /// [ get ] ///
  Future<List< FamiliaModel >> getFamiliaComplete() async  {
    final url1 = Uri.http(urlapi, '/api/Familia');
    const int maxAttempts = 3;
    int attempts = 0;
    while (attempts < maxAttempts) {
      try {
        final response = await http.get(url1, headers: {
          'Content-type': 'application/json',
          'Accept': 'application/json'
        });
        if (response.statusCode == 200) {
          return familiaModelFromJson4(response.body);
        } else {
          print('Error fetching materials: ${response.statusCode}');
          attempts++;
          if (attempts >= maxAttempts) {
            return [];
          }
        }
      } catch (e) {
        print(e);
        attempts++;
        if (attempts >= maxAttempts) {
          return [];
        }
      }
      await Future.delayed(const Duration(seconds: waitTime1));
    }
    return [];
  }
  Future<List< FamiliaModel >> getFamilia() async  {
    final url1 = Uri.http( urlapi, '/api/Familia/SubFamilia/Activas');
    const int maxAttempts = 3;
    int attempts = 0;

    while (attempts < maxAttempts) {
      try {
        final response = await http.get(url1, headers: {
          'Content-type': 'application/json',
          'Accept': 'application/json'
        });
        if (response.statusCode == 200) {
          print("OK");
          return familiaModelFromJson4(response.body);
        } else {
          print('Error fetching materials: ${response.statusCode}');
          attempts++;
          if (attempts >= maxAttempts) {
            return [];
          }
        }
      } catch (e) {
        print(e);
        attempts++;
        if (attempts >= maxAttempts) {
          return [];
        }
      }
      await Future.delayed(const Duration(seconds: waitTime1));
    }
    return [];
  }

  Future<FamiliaModel?> saveFamilia (FamiliaModel famInfo, String id) async {
    final url1 = Uri.http( urlapi, '/api/Familia/SaveWithSubFamilia', {'usuarioID' : id});
    const int maxAttempts = 3;
    int attempts = 0;
    while (attempts < maxAttempts) {
      try {
        final response = await http.post(
          url1,
          body: jsonEncode({
            "familia": {
              "nombre": famInfo.nombre,
              "descripcion": famInfo.descripcion
            },
            "subFamilias": famInfo.subFamilia!.map((subFamilia) => subFamilia.toJson2()).toList()
          }),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        );
        if (response.statusCode == 200 || response.statusCode == 201) {
          FamiliaModel familiaModel = familiaModelSingleFromJson4(response.body);
          print(familiaModel.nombre);
          return familiaModel;
        } else {
          print('Error fetching materials: ${response.statusCode}');
          attempts++;
          if (attempts >= maxAttempts) {
            return null;
          }
        }
      } catch (e) {
        print(e);
        attempts++;
        if (attempts >= maxAttempts) {
          return null;
        }
      }
      await Future.delayed(const Duration(seconds: waitTime1));
    }
    return null;
  }
  Future<bool> updateFamilia (FamiliaModel famInfo, String id) async {
    final url1 = Uri.http( urlapi, '/api/Familia/UpdateFamilia', {'usuarioID' : id});
    const int maxAttempts = 3;
    int attempts = 0;
    while (attempts < maxAttempts) {
      try {
        final response = await http.put(
          url1,
          body: jsonEncode({
            "idFamilia": famInfo.iDFamilia,
            "nombre": famInfo.nombre,
            "descripcion": famInfo.descripcion
          }),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        );
        if (response.statusCode == 200 || response.statusCode == 201) {
          return true;
        } else {
          print('Error fetching materials: ${response.statusCode}');
          attempts++;
          if (attempts >= maxAttempts) {
            return false;
          }
        }
      } catch (e) {
        print(e);
        attempts++;
        if (attempts >= maxAttempts) {
          return false;
        }
      }
      await Future.delayed(const Duration(seconds: waitTime1));
    }
    return false;
  }
  Future<bool> updateStatusFamilia(FamiliaModel familiaModel, String id) async {
    final url1 = Uri.http( urlapi, '/api/Familia/UpdateStatus', {'usuarioID' : id});
    const int maxAttempts = 3;
    int attempts = 0;
    while (attempts < maxAttempts) {
      try {
        final response = await http.put(url1,
          body: jsonEncode({
            "idFamilia": familiaModel.iDFamilia,
            "estatus": familiaModel.estatus
          }),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        );
        if (response.statusCode == 200 || response.statusCode == 201) {
          return true;
        } else {
          print('Error fetching materials: ${response.statusCode}');
          attempts++;
          if (attempts >= maxAttempts) {
            return false;
          }
        }
      } catch (e) {
        print(e);
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