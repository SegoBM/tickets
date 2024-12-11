import 'dart:convert';

List <UnidadModels> unidadModelsFromJson(String str) =>
    List <UnidadModels>.from(json.decode(str).map((x) => UnidadModels.fromJson(x)));
UnidadModels unidadModelFromJson(String str) {
  final jsonData = json.decode(str);
  return UnidadModels.fromJson(jsonData);
}
class UnidadModels {
  String? idUnidad;
  String nombre;
  String? abreviatura;
  bool? estatus;

  UnidadModels({
    this.idUnidad,
    required this.nombre,
    this.abreviatura,
    this.estatus
  });

  factory UnidadModels.fromJson(Map<String, dynamic> json) => UnidadModels(
      idUnidad: json["id"],
      nombre: json["nombre"],
      abreviatura: json["abreviatura"],
      estatus: json["estatus"]
  );
  Map<String, dynamic> toJson() => {
    "idUnidad": idUnidad,
    "nombre": nombre,
    "abreviatura": abreviatura,
    "estatus": estatus
  };
}
