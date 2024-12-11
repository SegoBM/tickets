import 'package:flutter/cupertino.dart';
import '../../../../models/ComprasModels/ServiciosProductosModels/ClaveSAT/claveSAT.dart';
import '../../../../shared/utils/constants.dart';
import 'package:http/http.dart' as http;
const urlapi = url;

class ClaveSATController with ChangeNotifier{
  ClaveSATController(){}

  //GET ClaveSAT
  Future<List<ClaveSATModels>> GetClavesSat() async{
    List<ClaveSATModels> listClaveSAT = [];
    final url1 = Uri.http(urlapi, 'api/ClaveSAT');
    final response = await http.get(url1, headers: {
      "Access-Control-Allow-Origin" : "*",
      "Access-Control-Allow-Credintials" : "true",
      "Context-type" : 'application/json',
      "Accept" : 'application/json'
    });
    if(response.statusCode == 200){
      listClaveSAT = claveSATModelsFromJson(response.body);
    } else {
      print('* Error en la solicitud *: ${response.statusCode}');
      print('Cuerpo en la respuesta: ${response.body}');
    }
    print('${listClaveSAT}');
    return listClaveSAT;
  }


}

