import 'dart:convert';

import 'package:tickets/models/ConfigModels/usuario.dart';

import 'puesto.dart';
import 'PermisoModels/departamentoSubmodulo.dart';

List <DepartamentoModels> departamentoModelsFromJson(String str) =>
    List <DepartamentoModels>.from(json.decode(str).map((x) => DepartamentoModels.fromJson(x)));

String departamentoModelsToJson(List<DepartamentoModels> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class DepartamentoModels {
  String? idDepartamento;
  String nombre;
  bool? estatus;
  String? areaId;
  List<PuestoModels>? puestos;
  List<DepartamentoSubmodulo> departamentoSubmodulos;
  List<UsuarioModels>? usuarios;
  DepartamentoModels({
    this.idDepartamento,
    required this.nombre,
     this.estatus,
     this.areaId,
    this.puestos,
    this.departamentoSubmodulos = const [],
    this.usuarios
  });

  factory DepartamentoModels.fromJson(Map<String, dynamic> json) => DepartamentoModels(
    idDepartamento: json["idDepartamento"],
    nombre: json["nombre"],
    estatus: json["estatus"],
    areaId: json["areaID"],
    puestos: List<PuestoModels>.from(json["puestos"].map((x) => PuestoModels.fromJson(x))),
    //departamentosSubmodulos: List<DepartamentoSubmodulo>.from(json["departamentosSubmodulos"].map((x) => DepartamentoSubmodulo.fromJson(x))),
  );
  factory DepartamentoModels.fromJsonWithSubmodules(Map<String, dynamic> json) => DepartamentoModels(
    nombre: json["nombre"],
    idDepartamento: json["idDepartamento"],
    departamentoSubmodulos: List<DepartamentoSubmodulo>.from(json["departamentoSubmodulos"].map((x) => DepartamentoSubmodulo.fromJson(x))),
  );
  factory DepartamentoModels.fromJsonWithUsers(Map<String, dynamic> json) => DepartamentoModels(
    nombre: json["nombre"],
    idDepartamento: json["idDepartamento"],
    usuarios: List<UsuarioModels>.from(json["usuarios"].map((x) => UsuarioModels.fromJson3(x))),
  );
  Map<String, dynamic> toJson() => {
    "idDepartamento": idDepartamento,
    "nombre": nombre,
    "estatus": estatus,
    "areaID": areaId,
    "puestos": List<dynamic>.from(puestos!.map((x) => x.toJson())),
  };
  Map<String, dynamic> toJson2() => {
    "departamentos" : {
      "nombre": nombre,
      "estatus": true,
    },
    "puestos": List<dynamic>.from(puestos!.map((x) => x.toJson2())),
  };
}
