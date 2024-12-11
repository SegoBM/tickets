import 'dart:convert';
import 'package:tickets/models/ConfigModels/departamento.dart';

List <AreaModels> areaModelsFromJson(String str) =>
    List <AreaModels>.from(json.decode(str).map((x) => AreaModels.fromJson(x)));

List <AreaModels> areaDepartamentoModelsFromJson(String str) =>
    List <AreaModels>.from(json.decode(str).map((x) => AreaModels.fromJsonWithSubmodules(x)));

List <AreaModels> areaConUsuariosModelsFromJson(String str) =>
    List <AreaModels>.from(json.decode(str).map((x) => AreaModels.fromJsonWithUsers(x)));

String areaModelsToJson(List<AreaModels> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class AreaModels {
  String? idArea;
  String nombre;
  bool? estatus;
  List<DepartamentoModels>? departamentos;
  List<DepartamentoModels>? departamentosSubmodulo;

  AreaModels({
    this.idArea,
    required this.nombre,
    this.estatus,
    this.departamentos,
    this.departamentosSubmodulo
  });

  factory AreaModels.fromJson(Map<String, dynamic> json) => AreaModels(
    idArea: json["idArea"],
    nombre: json["nombre"],
    estatus: json["estatus"],
    departamentos: List<DepartamentoModels>.from(json["departamentos"].map((x) => DepartamentoModels.fromJson(x))),
  );
  factory AreaModels.fromJsonWithSubmodules(Map<String, dynamic> json) => AreaModels(
    idArea: json["idArea"],
    nombre: json["nombre"],
    estatus: json["estatus"],
    departamentosSubmodulo: List<DepartamentoModels>.from(json["departamentos"].map((x) => DepartamentoModels.fromJsonWithSubmodules(x))),
  );
  factory AreaModels.fromJsonWithUsers(Map<String, dynamic> json) => AreaModels(
    idArea: json["idArea"],
    nombre: json["nombre"],
    departamentos:  List<DepartamentoModels>.from(json["departamentos"].map((x) => DepartamentoModels.fromJsonWithUsers(x))),
  );

  Map<String, dynamic> toJson() => {
    "idArea": idArea,
    "nombre": nombre,
    "estatus": estatus,
    "departamentos": List<dynamic>.from(departamentos!.map((x) => x.toJson())),
  };
}
