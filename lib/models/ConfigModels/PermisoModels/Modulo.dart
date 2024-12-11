

import 'dart:convert';

import 'package:tickets/models/ConfigModels/PermisoModels/submoduloPermisos.dart';

List<Modulo> moduloFromJson(String str) => List<Modulo>.from(json.decode(str).map((x) => Modulo.fromJson(x)));

String moduloToJson(List<Modulo> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Modulo {
  String idModulo;
  String nombreModulo;
  List<SubmoduloPermisos> submodulos;

  Modulo({
    required this.idModulo,
    required this.nombreModulo,
    required this.submodulos,
  });

  factory Modulo.fromJson(Map<String, dynamic> json) => Modulo(
    idModulo: json["idModulo"],
    nombreModulo: json["nombreModulo"],
    submodulos: List<SubmoduloPermisos>.from(json["submodulos"].map((x) => SubmoduloPermisos.fromJson2(x))),
  );

  Map<String, dynamic> toJson() => {
    "idModulo": idModulo,
    "nombreModulo": nombreModulo,
    "submodulos": List<dynamic>.from(submodulos.map((x) => x.toJson())),
  };
}