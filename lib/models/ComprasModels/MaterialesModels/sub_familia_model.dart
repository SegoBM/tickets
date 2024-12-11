import 'dart:convert';

List<SubFamiliaModel> subfamiliaModelsFromJson(String str) =>
    List<SubFamiliaModel>.from(json.decode(str).map((x) => SubFamiliaModel.fromJson(x)));

List<SubFamiliaModel> subfamiliaModelsFromJson2(String str) =>
    List<SubFamiliaModel>.from(json.decode(str).map((x) => SubFamiliaModel.fromJson2(x)));

SubFamiliaModel subfamiliaModelFromJson(String str) => SubFamiliaModel.fromJson(json.decode(str));

String subFamiliaModelToJson(List<SubFamiliaModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class SubFamiliaModel {
    String iDSubFamilia;
    String nombre;
    String? descripcion;
    String? familiaId;
    int? estatus;
    factory SubFamiliaModel.fromJson(Map<String, dynamic> json) => SubFamiliaModel(
        iDSubFamilia: json["iDSubFamilia"],
        nombre: json["nombre"],
        descripcion: json["descripcion"],
        familiaId: json["familiaId"],
        estatus: json["estatus"],
    );
    factory SubFamiliaModel.fromJson2(Map<String, dynamic> json) => SubFamiliaModel(
      iDSubFamilia: json["idSubfamilia"],
      nombre: json["nombre"],
      descripcion: json["descripcion"],
      estatus: json["estatus"],
    );
    factory SubFamiliaModel.fromJson3(Map<String, dynamic> json) => SubFamiliaModel(
      iDSubFamilia: json["idSubFamilia"],
      nombre: json["nombre"],
      descripcion: json["descripcion"],
      familiaId: json["familiaId"],
      estatus: json["estatus"],
    );
     SubFamiliaModel({
       required this.iDSubFamilia,
       required this.nombre,
       this.descripcion,
       this.estatus,
       this.familiaId,
    });
     Map<String, dynamic> toJson() => {
        "iDSubFamilia": iDSubFamilia,
        "nombre": nombre,
        "descripcion": descripcion,
        "familiaId": familiaId,
        "estatus": estatus,
     };
    Map<String, dynamic> toJson2() => {
      "nombre": nombre,
      "descripcion": descripcion
    };
}