import 'dart:convert';

List<ClaveSATModels> claveSATModelsFromJson(String str) =>
  List<ClaveSATModels>.from(json.decode(str).map((x) => ClaveSATModels.fromJson(x)));

ClaveSATModels claveSATFromJsonS(String str) => ClaveSATModels.fromJson(json.decode(str));

String claveSATToJson(List<ClaveSATModels> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ClaveSATModels {
  String? idClaveSat;
  String? descripcion;
  int? clavePs;
  String claveUnidadMedida;

  ClaveSATModels({
   this.idClaveSat,
   this.descripcion,
    this.clavePs,
    required this.claveUnidadMedida,
  });

  factory ClaveSATModels.fromJson(Map<String, dynamic> json) => ClaveSATModels(
    idClaveSat: json["idClaveSAT"],
    descripcion: json["descripcion"],
    clavePs: json["clavePS"],
    claveUnidadMedida: json["claveUnidadMedida"],
  );

  Map<String, dynamic> toJson() => {
    "idClaveSAT": idClaveSat,
    "descripcion": descripcion,
    "clavePS": clavePs,
    "claveUnidadMedida": claveUnidadMedida,
  };

  @override
  String toString(){
    return 'ClaveSATModels(idClave: $idClaveSat, clavePS: $clavePs, descripcion: $descripcion, claveUnidadMedina: $claveUnidadMedida)';
  }
}
