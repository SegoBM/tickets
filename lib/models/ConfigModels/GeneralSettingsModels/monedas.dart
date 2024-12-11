import 'dart:convert';

List <MonedaModels> monedaModelsFromJson(String str) =>
    List <MonedaModels>.from(json.decode(str).map((x) => MonedaModels.fromJson(x)));
MonedaModels monedaModelFromJson(String str) {
  final jsonData = json.decode(str);
  return MonedaModels.fromJson(jsonData);
}
class MonedaModels {
  String? idMoneda;
  String nombre;
  String? abreviatura;
  double? tipoCambio;
  String? fechaActualizacion;
  bool? estatus;


  MonedaModels({
    this.idMoneda,
    required this.nombre,
    this.abreviatura,
    this.tipoCambio,
    this.fechaActualizacion,
    this.estatus
  });

  factory MonedaModels.fromJson(Map<String, dynamic> json) => MonedaModels(
    idMoneda: json["id"],
    nombre: json["nombre"],
    abreviatura: json["abreviatura"],
    tipoCambio: json["tipoCambio"],
    fechaActualizacion: json["fechaActualizacion"],
    estatus: json["estatus"]
  );
  Map<String, dynamic> toJson() => {
    "id": idMoneda,
    "nombre": nombre,
    "abreviatura": abreviatura,
    "tipoCambio": tipoCambio,
    "fechaActualizacion": fechaActualizacion,
    "estatus": estatus
  };
}
