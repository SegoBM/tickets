import 'dart:convert';

List <PermisoModels> permisoModelsFromJson(String str) =>
    List <PermisoModels>.from(json.decode(str).map((x) => PermisoModels.fromJson(x)));

String permisoModelsToJson(List<PermisoModels> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));


class PermisoModels {
  String idPermiso;
  String nombre;
  String descripcion;
  String tipoUsuario;
  String subModuloId;
  bool activo;

  PermisoModels({
    required this.idPermiso,
    required this.nombre,
    required this.descripcion,
    required this.tipoUsuario,
    required this.subModuloId,
    this.activo = false
  });

  factory PermisoModels.fromJson(Map<String, dynamic> json) => PermisoModels(
    idPermiso: json["idPermiso"],
    nombre: json["nombre"],
    descripcion: json["descripcion"],
    tipoUsuario: json["tipoUsuario"],
    subModuloId: json["subModuloID"],
  );

  Map<String, dynamic> toJson() => {
    "idPermiso": idPermiso,
    "nombre": nombre,
    "descripcion": descripcion,
    "tipoUsuario": tipoUsuario,
    "subModuloID": subModuloId,
  };
}
