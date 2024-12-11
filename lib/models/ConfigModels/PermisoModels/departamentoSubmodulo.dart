import 'dart:convert';

List<DepartamentoSubmodulo> departamentoSubmoduloFromJson(String str) => List<DepartamentoSubmodulo>.from(json.decode(str).map((x) => DepartamentoSubmodulo.fromJson(x)));

String departamentoSubmoduloToJson(List<DepartamentoSubmodulo> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class DepartamentoSubmodulo {
  String? idDepartamentoSubmodulo;
  String? departamentoId;
  String subModuloId;

  DepartamentoSubmodulo({
     this.idDepartamentoSubmodulo,
     this.departamentoId,
    required this.subModuloId,
  });

  factory DepartamentoSubmodulo.fromJson(Map<String, dynamic> json) => DepartamentoSubmodulo(
    idDepartamentoSubmodulo: json["idDepartamentoSubmodulo"],
    departamentoId: json["departamentoID"],
    subModuloId: json["subModuloID"],
  );

  Map<String, dynamic> toJson() => {
    "idDepartamentoSubmodulo": idDepartamentoSubmodulo,
    "departamentoID": departamentoId,
    "subModuloID": subModuloId,
  };
}