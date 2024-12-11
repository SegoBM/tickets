import 'dart:convert';

List <PuestoModels> puestoModelsFromJson(String str) =>
    List <PuestoModels>.from(json.decode(str).map((x) => PuestoModels.fromJson(x)));
PuestoModels puestoModelFromJson(String str) {
  final jsonData = json.decode(str);
  return PuestoModels.fromJson(jsonData);
}

String puestoModelsToJson(List<PuestoModels> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class PuestoModels {
  String? idPuesto;
  String nombre;
  bool? estatus;
  String? departamentoId;

  PuestoModels({
    this.idPuesto,
    required this.nombre,
     this.estatus,
     this.departamentoId,
  });

  factory PuestoModels.fromJson(Map<String, dynamic> json) => PuestoModels(
    idPuesto: json["idPuesto"],
    nombre: json["nombre"],
    estatus: json["estatus"],
    departamentoId: json["departamentoID"],
  );

  Map<String, dynamic> toJson() => {
    "idPuesto": idPuesto,
    "nombre": nombre,
    "estatus": estatus,
    "departamentoID": departamentoId,
  };
  Map<String, dynamic> toJson2() => {
    "nombre": nombre,
    "estatus": true,
  };
}
