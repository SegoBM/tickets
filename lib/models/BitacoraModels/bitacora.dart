import 'dart:convert';

List <BitacoraModels> bitacoraModelsFromJson(String str) =>
    List <BitacoraModels>.from(json.decode(str).map((x) => BitacoraModels.fromJson(x)));
String bitacoraModelsToJson(List<BitacoraModels> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class BitacoraModels {
  String? IdBitacora;
  String descripcion;
  String modulo;
  String fecha;
  String? operacionID;

  BitacoraModels({
    this.IdBitacora,
    required this.descripcion,
    required this.modulo,
    required this.fecha,
    required this.operacionID,
  });

  factory BitacoraModels.fromJson(Map<String, dynamic> json) => BitacoraModels(
    IdBitacora: json["idBitacora"],
    descripcion: json["descripcion"],
    modulo: json["modulo"],
    fecha: json["fecha"],
    operacionID: json["operacionID"],
  );

  Map<String, dynamic> toJson() => {
    "idBitacora": IdBitacora,
    "descripcion": descripcion,
    "modulo": modulo,
    "fecha": fecha,
    "operacionID": operacionID
  };
}
