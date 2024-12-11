import 'dart:convert';

List <UsuarioPermisoModels> usuarioPermisoModelsFromJson(String str) =>
    List <UsuarioPermisoModels>.from(json.decode(str).map((x) => UsuarioPermisoModels.fromJson(x)));

String usuarioPermisoModelsToJson(List<UsuarioPermisoModels> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class UsuarioPermisoModels {
  String? idUsuarioPermiso;
  String? usuarioId;
  String permisoId;

  UsuarioPermisoModels({
    this.idUsuarioPermiso,
    this.usuarioId,
    required this.permisoId,
  });

  factory UsuarioPermisoModels.fromJson(Map<String, dynamic> json) => UsuarioPermisoModels(
    idUsuarioPermiso: json["idUsuarioPermiso"],
    usuarioId: json["usuarioID"],
    permisoId: json["permisoID"],
  );

  Map<String, dynamic> toJson() => {
    "idUsuarioPermiso": idUsuarioPermiso,
    "usuarioID": usuarioId,
    "permisoID": permisoId,
  };
  Map<String, dynamic> toJson2() => {
    "permisoID": permisoId,
  };
}
