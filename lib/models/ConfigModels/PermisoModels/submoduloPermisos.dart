import 'dart:convert';

import 'package:tickets/models/ConfigModels/PermisoModels/permiso.dart';



List<SubmoduloPermisos> submoduloPermisosFromJson(String str) => List<SubmoduloPermisos>.from(json.decode(str).map((x) => SubmoduloPermisos.fromJson(x)));

List<SubmoduloPermisos> submoduloPermisos2FromJson(String str) =>
    List<SubmoduloPermisos>.from(json.decode(str).map((x) => SubmoduloPermisos.fromJson2(x)));

String submoduloPermisosToJson(List<SubmoduloPermisos> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class SubmoduloPermisos {
  String submoduloId;
  String nombreSubmodulo;
  List<PermisoModels>? permisos;
  bool activo;
  String? descripcion;

  SubmoduloPermisos({
    required this.submoduloId,
    required this.nombreSubmodulo,
    this.permisos,
    this.activo = false,
    this.descripcion,
  });

  factory SubmoduloPermisos.fromJson(Map<String, dynamic> json) => SubmoduloPermisos(
    submoduloId: json["submoduloId"],
    nombreSubmodulo: json["nombreSubmodulo"],
    permisos: List<PermisoModels>.from(json["permisos"].map((x) => PermisoModels.fromJson(x))),
  );

  factory SubmoduloPermisos.fromJson2(Map<String, dynamic> json) => SubmoduloPermisos(
    submoduloId: json["idSubmodulo"],
    nombreSubmodulo: json["nombre"],
    descripcion: json["descripcion"],
  );

  Map<String, dynamic> toJson() => {
    "submoduloId": submoduloId,
    "nombreSubmodulo": nombreSubmodulo,
    "permisos": List<dynamic>.from(permisos!.map((x) => x.toJson())),
  };
}
