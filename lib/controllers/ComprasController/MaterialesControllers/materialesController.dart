import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:tickets/models/ComprasModels/MaterialesModels/materiales.dart';
import 'package:tickets/shared/utils/constants.dart';
import 'package:http/http.dart' as http;
const urlapi= url;

class MaterialesController with ChangeNotifier{
  MaterialesController(){}
  final String baseUrl = "http://192.168.1.251:85";

  //GET Materiales Estatus
  Future<List<MaterialesModels>> getMateriales(List<int> estatus) async {
    List<MaterialesModels> listMateriales=[];

    //Construir la URL completa con los parámetros de consulta
    Uri url= Uri.parse('$baseUrl/api/Materiales/MaterialesWithEstatus')
    .replace(queryParameters: {'estatus': estatus.map((e) => e.toString()).toList()});
    try{
      final response = await http.get(url, headers: {
        "Access-Control-Allow-Origin": "*",
        "Content-type": "application/json",
      });
      if(response.statusCode == 200){
        listMateriales = materialesModelsFromJson(response.body);
      } else {
        print('*Error en la solicitud* : ${response.statusCode}');
      }
    } catch (error){
      print('*Error en la solicitud*: $error');
      throw Exception('Error al obtener los materiales');
    }
    return listMateriales;
  }
/// GET

  Future<List<MaterialesModels>> getMaterials1() async {
    print('Getting materials');
    List<MaterialesModels> listMaterialsInfo = [];
    final url1 = Uri.http(urlapi, '/api/Materiales');
    const int maxAttempts = 3;
    int attempts =0;
    while ( attempts < maxAttempts){
      try {
        final response = await http.get(url1, headers: {
          'Content-type': 'application/json',
          'Accept': 'application/json'
        });
        if (response.statusCode == 200) {
          print(materialesModelsFromJson2(response.body));
          listMaterialsInfo = materialesModelsFromJson2(response.body);
          print(listMaterialsInfo.first.familiaNombre);
        } else {
          attempts ++;
          print('Error fetching materials: ${response.statusCode}');
          if( attempts >= maxAttempts ){
            print( 'Max attempts reached' );
            return listMaterialsInfo;
          }
        }
      } catch (e) {
        print('Exception caught: $e');
        attempts++;
      }
    }
    return listMaterialsInfo;
  }


  /// POST
Future<bool> saveMaterial( MaterialesModels matInfo ) async {
    final url1 = Uri.http( urlapi, '/api/Materiales/AddMaterial' );
    const int maxAttempts = 3;
    int attempts = 0;
    while( attempts < maxAttempts ){
      try{
        final response = await http.post(url1,
          body: jsonEncode({
            "categoria": matInfo.categoria,
            "codigoProducto": matInfo.codigoProducto,
            "unidadMedidaCompra": matInfo.unidadMedidaCompra,
            "unidadMedidaVenta": matInfo.unidadMedidaVenta,
            "composicion": matInfo.composicion,
            "espesorMM": matInfo.espesorMM,
            "ancho": matInfo.ancho,
            "largo": matInfo.largo,
            "metrosXRollo": matInfo.metrosXRollo,
            "costo": matInfo.costo,
            "precioVenta": matInfo.precioVenta,
            "igi": matInfo.igi,
            "referenciaCalidad": matInfo.referenciaCalidad,
            "referenciaColor": matInfo.referenciaColor,
            "gsm": matInfo.gsm,
            "pesoXBulto": matInfo.pesoXBulto,
            "descripcion": matInfo.descripcion,
            "foto": matInfo.foto,
            "subFamiliaID": matInfo.subFamiliaID,
            "fraccionArancelaria": matInfo.fraccionArancelaria,
            "estatus": matInfo.estatus,
            "subFamiliaNombre": matInfo.subFamiliaNombre,
            "familiaNombre": matInfo.subFamiliaNombre,

          }),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        );

        if(response.statusCode == 200 || response.statusCode ==201 ){
          return true;
        } else {
          print('Failed to save material: ${response.body}');
          return false;
        }
      } catch ( e ) {
        print( 'Exception caught $e' );
        return false;
      }
    }
    return false;
}

Future<bool> updateMaterial( MaterialesModels material, String idMaterial ) async {
    final url1 = Uri.http( urlapi, 'api/Materiales/UpdateMaterial', { 'id': idMaterial });
    try{
     final response = await http.put(
         url1,
         body: jsonEncode({
            "idMaterial": material.idMaterial,
             "categoria": material.categoria,
             "codigoProducto": material.codigoProducto,
             "unidadMedidaCompra": material.unidadMedidaCompra,
             "unidadMedidaVenta": material.unidadMedidaVenta,
             "composicion": material.composicion,
             "espesorMM": material.espesorMM,
             "ancho": material.ancho,
             "largo": material.largo,
             "metrosXRollo": material.metrosXRollo,
             "costo": material.costo,
             "precioVenta": material.precioVenta,
             "igi": material.igi,
             "referenciaCalidad": material.referenciaCalidad,
             "referenciaColor": material.referenciaColor,
             "gsm": material.gsm,
             "pesoXBulto": material.pesoXBulto,
             "descripcion": material.descripcion,
             "foto": material.foto,
             "subFamiliaID": material.subFamiliaID,
             "fraccionArancelaria": material.fraccionArancelaria,
             "estatus": material.estatus,
             "subFamiliaNombre": material.subFamiliaNombre,
             "familiaNombre": material.familiaNombre,
         }),headers:{
             'Content-Type': 'application/json',
             'Accept': 'application/json',
          });
     if (response.statusCode == 200  ){
       print( 'Material updated' );
       print(response.body);
       return true;
     } else {
       print('Failde to update material: ${response.body}');
       return false;
     }
    } catch ( e ) {
      print( 'Exception caught: $e' );
      return false;
    }
}
Future<bool> deleteMterial( String idMaterial  ) async {
    try{
      print("trying to delete material");
      final url1  = Uri.http( urlapi, '/api/Materiales/DeleteMaterial', { 'id': idMaterial });
      final response = await http.delete(
          url1, headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      }
      );
      if( response.statusCode == 200 ){
        print( response.statusCode );
        return true;
      } else {
        print('Failed to delete material: ${response.statusCode}');
        return false;
      }
    } catch (e){
      print(e);
      return false;
    }
}
}
