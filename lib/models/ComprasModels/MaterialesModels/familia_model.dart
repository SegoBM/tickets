import 'dart:convert';

import 'package:tickets/models/ComprasModels/MaterialesModels/sub_familia_model.dart';

List<FamiliaModel> familiaModelFromJson(String str) =>
    List<FamiliaModel>.from(json.decode(str).map((x) => FamiliaModel.fromJson(x)));
String familiaModelToJson(List<FamiliaModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));
List <FamiliaModel> familiaModelFromJson2(String str) =>
    List <FamiliaModel>.from(json.decode(str).map((x) => FamiliaModel.fromJson(x)));

List <FamiliaModel> familiaModelFromJson4(String str) =>
    List <FamiliaModel>.from(json.decode(str).map((x) => FamiliaModel.fromJson4(x)));
FamiliaModel familiaModelSingleFromJson4(String str) => FamiliaModel.fromJson5(json.decode(str));

class FamiliaModel {
  String iDFamilia;
  String nombre;
  String descripcion;
  List<SubFamiliaModel>? subFamilia;
  int? estatus;

  factory FamiliaModel.fromJson(Map< String, dynamic > json) => FamiliaModel(
    iDFamilia: json["iDFamilia"],
    nombre: json["nombre"],
    descripcion:json ["descripcion"]
  );
  factory FamiliaModel.fromJson2(Map< String, dynamic > json) => FamiliaModel(
      iDFamilia: json["iDFamilia"],
      nombre: json["nombre"],
      descripcion:json ["descripcion"],
      subFamilia: List<SubFamiliaModel>.from(json["subFamilia"].map((x) => SubFamiliaModel.fromJson(x)))
  );
  factory FamiliaModel.fromJson3(Map< String, dynamic > json) => FamiliaModel(
      iDFamilia: json["iDFamilia"],
      nombre: json["nombre"],
      descripcion:json ["descripcion"],
      estatus: json["estatus"]
  );
  factory FamiliaModel.fromJson5(Map< String, dynamic > json) => FamiliaModel(
    iDFamilia: json["familia"]["idFamilia"],
    nombre: json["familia"]["nombre"],
    descripcion: json["familia"]["descripcion"],
    estatus: json["familia"]["estatus"],
    subFamilia: List<SubFamiliaModel>.from(json["subFamilias"]?.map((x) => SubFamiliaModel.fromJson3(x))),
  );
  factory FamiliaModel.fromJson4(Map< String, dynamic > json) => FamiliaModel(
      iDFamilia: json["idFamilia"],
      nombre: json["nombre"],
      descripcion:json ["descripcion"],
      estatus: json["estatus"],
      subFamilia: List<SubFamiliaModel>.from(json["subFamilias"].map((x) => SubFamiliaModel.fromJson2(x)))
  );
  Map<String, dynamic > toJson() => {
    "iDFamilia" : iDFamilia,
    "nombre" : nombre,
    "descripcion" : descripcion
  };
  FamiliaModel({
    required this.iDFamilia,
    required this.nombre,
    this.descripcion = '',
    this.subFamilia = const [],
    this.estatus = 0
  });
}