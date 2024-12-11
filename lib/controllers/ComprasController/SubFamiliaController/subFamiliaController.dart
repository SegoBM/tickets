import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:tickets/models/ComprasModels/MaterialesModels/sub_familia_model.dart';
import 'package:http/http.dart' as http;
import '../../../shared/utils/constants.dart';

const urlapi= url;

class SubFamiliaController with ChangeNotifier{
  List<SubFamiliaModel> subfamilia=[];
  SubFamiliaController(){}

  //GET
  Future<List<SubFamiliaModel>> getSubFamilias() async {
    List<SubFamiliaModel> listFamilias = [];
    final url1 = Uri.http(urlapi, '/api/SubFamilia/Activos');
    final response = await http.get(url1, headers: {
      "Access-Control-Allow-Origin": "*",
      "Access-Control-Allow-Credentials": "true",
      'Content-type': 'application/json',
      'Accept': 'application/json'
    });

    if (response.statusCode == 200) {
      listFamilias = subfamiliaModelsFromJson(response.body);
    } else {
      print('*Error en la solicitud*: ${response.statusCode}');
    }
    return listFamilias;
  }
  Future<SubFamiliaModel?> saveSubFamilia(SubFamiliaModel subFamilia, String id) async {
    final url1 = Uri.http(urlapi, '/api/SubFamilia/SaveSubFamilia', {'usuarioID' : id});
    try{
      final response = await http.post(url1, headers: {
        'Content-type': 'application/json',
        'Accept': 'application/json'
      },
          body: jsonEncode({
            "nombre": subFamilia.nombre,
            "descripcion": subFamilia.descripcion,
            "familiaId": subFamilia.familiaId
          })
      );
      if(response.statusCode == 200){
        return subfamiliaModelFromJson(response.body);
      } else {
        print(response.statusCode);
        return null;
      }
    }catch(e){
      print(e);
      return null;
    }
  }
  Future<bool> updateSubFamilia(SubFamiliaModel subFamilia, String id) async {
    final url1 = Uri.http(urlapi, '/api/SubFamilia/UpdateSubFamilia', {'usuarioID' : id});
    try{
      final response = await http.put(url1, headers: {
        'Content-type': 'application/json',
        'Accept': 'application/json'
      },
          body: jsonEncode({
            "idSubFamilia": subFamilia.iDSubFamilia,
            "nombre": subFamilia.nombre,
            "descripcion": subFamilia.descripcion
          })
      );
      if(response.statusCode == 200){
        return true;
      } else {
        print(response.statusCode);
        return false;
      }
    }catch(e){
      print(e);
      return false;
    }
  }
  Future<bool> changeStatusSubFamilia(SubFamiliaModel subFamiliaModel, String id) async {
    final url1 = Uri.http(urlapi, '/api/SubFamilia/UpdateEstatus', {"id": subFamiliaModel.iDSubFamilia.toString(),
      "status": subFamiliaModel.estatus.toString(), 'usuarioID' : id});
    try{
      final response = await http.put(url1, headers: {
        'Content-type': 'application/json',
        'Accept': 'application/json'
      });
      if(response.statusCode == 200){
        return true;
      } else {
        print(response.statusCode);
        print(response.body);
        return false;
      }
    }catch(e){
      print(e);
      return false;
    }
  }
}
