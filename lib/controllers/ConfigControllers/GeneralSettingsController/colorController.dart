import 'dart:convert';
import 'package:tickets/models/ConfigModels/GeneralSettingsModels/color.dart';
import 'package:tickets/models/ConfigModels/GeneralSettingsModels/unidad.dart';
import 'package:tickets/shared/utils/constants.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

const urlapi= url;
const waitTime1 = waitTime;

class ColorController with ChangeNotifier {
  ColorController() {}

  //GET
  Future<List<ColorModels>> getColor() async {
    final url1 = Uri.http(urlapi, '/api/Color');
    const int maxAttempts = 3;
    int attempts = 0;

    while (attempts < maxAttempts) {
      try {
        final resp = await http.get(url1, headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        });
        if (resp.statusCode == 200) {
          return colorModelsFromJson(resp.body);
        } else {
          print(resp.body);
          attempts++;
          if (attempts >= maxAttempts) {
            return [];
          }
        }
      } catch (e) {
        print('Error al enviar la solicitud: $e');
        attempts++;
        if (attempts >= maxAttempts) {
          return [];
        }
      }
      await Future.delayed(const Duration(seconds: waitTime1));
    }
    return [];
  }
}