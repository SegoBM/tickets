import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../models/ComprasModels/MaterialesModels/materiales_w_suppliers.dart';

import 'package:http/http.dart' as http;

import '../../../shared/utils/constants.dart';

const urlapi = url;


class MaterialSupplierController with ChangeNotifier {
  MaterialSupplierController() {}

  ///[ get ]///
  Future<void> postMaterialWSuppliers(MaterialesWSuppliers materialSuppliers)async{
    final url = Uri.http(urlapi, '/api/Materiales/MaterialConProveedores');
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json'
    };
    final body = json.encode(materialSuppliers.toJson());
    try {
      final response = await http.post(
        url,
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        print("Material posted successfully");
      } else {
        print("Failed to post material");
        print("Status Code: ${response.statusCode}");
        print("Response Body: ${response.body}");
      }
    } catch (e) {
      print('Error posting material: $e');
    }
  }
}