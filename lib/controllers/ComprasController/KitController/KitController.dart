import 'package:flutter/cupertino.dart';
import '../../../models/ComprasModels/KitModels/Kits.dart';
import 'package:http/http.dart' as http;
import 'package:tickets/shared/utils/constants.dart';
const urlapi= url;

class KitController with ChangeNotifier {
  KitController(){}

  //GET kit
  Future<List<KitModels>> GetKit()async {
    List<KitModels> listKit = [];
    final url1 = Uri.http(urlapi, '/api/Kits');
    final response = await http.get(url1, headers: {
      "Access-Control-Allow-Origin" : "*",
      "Access-Control-Allow-Credentials" : "true",
      "Content-type" : 'application/json',
      "Accept" : 'application/json'
    });
    if (response.statusCode == 200) {
      listKit = kitModelsFromJson(response.body);
    } else {
      print('*Error en la solicitud*: ${response.statusCode}');
      print('Cuerpo de la respuesta: ${response.body}');
    }
    print('${listKit}');
    return listKit;
  }

}


