import 'dart:convert';
import '../../../models/ComprasModels/DatosBancariosModels/datosBancarios.dart';
import 'package:tickets/shared/utils/constants.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

const urlapi = url;

class DatosBancariosController with ChangeNotifier {
  List<DatosBancariosModels> _datosBancariosList = [];
  List<DatosBancariosModels> get datosBancariosList => _datosBancariosList;

  // GET
  Future<void> getDatosBancarios() async {
    final url1 = Uri.http(urlapi, '/api/DatosBancarios');
    final response = await http.get(url1, headers: {
      "Access-Control-Allow-Origin": "*",
      "Access-Control-Allow-Credentials": "true",
      'Content-type': 'application/json',
      'Accept': 'application/json'
    });

    if (response.statusCode == 200) {
      _datosBancariosList = datosBancariosModelsFromJson(response.body);
      notifyListeners();
    } else {
      throw Exception('Failed to load datos bancarios');
    }
  }

  // POST
  Future<void> addDatosBancarios(DatosBancariosModels datosBancarios) async {
    final url1 = Uri.http(urlapi, '/api/DatosBancarios');
    final response = await http.post(url1,
        headers: {
          "Access-Control-Allow-Origin": "*",
          "Access-Control-Allow-Credentials": "true",
          'Content-type': 'application/json',
          'Accept': 'application/json'
        },
        body: json.encode(datosBancarios.toJson()));

    if (response.statusCode == 201) {
      _datosBancariosList.add(datosBancarios);
      notifyListeners();
    } else {
      throw Exception('Failed to add datos bancarios');
    }
  }

  // PUT
  Future<void> updateDatosBancarios(DatosBancariosModels datosBancarios) async {
    final url1 = Uri.http(urlapi, '/api/DatosBancarios/${datosBancarios.idDatosBancarios}');
    final response = await http.put(url1,
        headers: {
          "Access-Control-Allow-Origin": "*",
          "Access-Control-Allow-Credentials": "true",
          'Content-type': 'application/json',
          'Accept': 'application/json'
        },
        body: json.encode(datosBancarios.toJson()));

    if (response.statusCode == 200) {
      final index = _datosBancariosList.indexWhere((item) => item.idDatosBancarios == datosBancarios.idDatosBancarios);
      if (index != -1) {
        _datosBancariosList[index] = datosBancarios;
        notifyListeners();
      }
    } else {
      throw Exception('Failed to update datos bancarios');
    }
  }

  // DELETE
  Future<void> deleteDatosBancarios(String idDatosBancarios) async {
    final url1 = Uri.http(urlapi, '/api/DatosBancarios/$idDatosBancarios');
    final response = await http.delete(url1, headers: {
      "Access-Control-Allow-Origin": "*",
      "Access-Control-Allow-Credentials": "true",
      'Content-type': 'application/json',
      'Accept': 'application/json'
    });

    if (response.statusCode == 200) {
      _datosBancariosList.removeWhere((item) => item.idDatosBancarios == idDatosBancarios);
      notifyListeners();
    } else {
      throw Exception('Failed to delete datos bancarios');
    }
  }
}