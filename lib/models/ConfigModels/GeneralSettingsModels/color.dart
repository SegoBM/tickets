import 'dart:convert';

List <ColorModels> colorModelsFromJson(String str) =>
    List <ColorModels>.from(json.decode(str).map((x) => ColorModels.fromJson(x)));
ColorModels colorModelFromJson(String str) {
  final jsonData = json.decode(str);
  return ColorModels.fromJson(jsonData);
}
class ColorModels {
  String? colorID;
  String nombre;
  String? hexadecimal;
  bool estatus;

  ColorModels({
    this.colorID,
    required this.nombre,
    this.hexadecimal,
    this.estatus = true
  });

  factory ColorModels.fromJson(Map<String, dynamic> json) => ColorModels(
      colorID: json["colorID"],
      nombre: json["nombre"],
      hexadecimal: json["hexadecimal"]
  );
  Map<String, dynamic> toJson() => {
    "colorID": colorID,
    "nombre": nombre,
    "hexadecimal": hexadecimal
  };
}
