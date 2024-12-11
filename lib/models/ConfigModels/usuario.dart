import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tickets/models/ConfigModels/empresa.dart';

List <UsuarioModels> usuarioModelsFromJson(String str) =>
    List <UsuarioModels>.from(json.decode(str).map((x) => UsuarioModels.fromJson(x)));
List <UsuarioModels> usuarioModelsFromJson2(String str) =>
    List <UsuarioModels>.from(json.decode(str).map((x) => UsuarioModels.fromJson2(x)));

UsuarioModels usuarioFromJsonS(String str) => UsuarioModels.fromJson(json.decode(str));

UsuarioModels usuarioFromJsonS2(String str) => UsuarioModels.fromJson2(json.decode(str));

String usuarioModelsToJson(List<UsuarioModels> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class UsuarioModels {
  String? idUsuario;
  String nombre;
  String apellidoPaterno;
  String? apellidoMaterno;
  String userName;
  String contrasenia;
  String tipoUsuario;
  bool? estatus;
  String? puestoId;
  String? nombrePuesto;
  String? nombreDepartamento;
  String? empresaID;
  String? empresaNombre;
  List<EmpresaModels> empresas;
  String? imagen;
  //bool selected;
  ValueNotifier<bool> selectedNotifier = ValueNotifier(false);
  bool get selected => selectedNotifier.value;

  UsuarioModels({
    this.idUsuario,
    required this.nombre,
    required this.apellidoPaterno,
    this.apellidoMaterno,
    required this.userName,
    required this.contrasenia,
    required this.tipoUsuario,
    this.estatus,
    this.puestoId,
    this.nombreDepartamento,
    this.nombrePuesto,
    this.empresaID,
    this.empresaNombre,
    this.empresas = const [],
    this.imagen,
  });
  void toggleSelected() {
    selectedNotifier.value = !selectedNotifier.value;
  }
  factory UsuarioModels.fromJson(Map<String, dynamic> json) => UsuarioModels(
    idUsuario: json["idUsuario"],
    nombre: json["nombre"],
    apellidoPaterno: json["apellidoPaterno"],
    apellidoMaterno: json["apellidoMaterno"],
    userName: json["userName"],
    contrasenia: json["contrasenia"],
    tipoUsuario: json["tipoUsuario"],
    estatus: json["estatus"],
    puestoId: json["puestoID"],
    nombrePuesto: json["nombrePuesto"],
    nombreDepartamento: json["nombreDepartamento"],
    imagen: json["imagen"],
    empresas: List<EmpresaModels>.from(json["empresas"].map((x) => EmpresaModels.fromJson(x))),
  );
  factory UsuarioModels.fromJson2(Map<String, dynamic> json) => UsuarioModels(
    idUsuario: json["idUsuario"],
    nombre: json["nombre"],
    apellidoPaterno: json["apellidoPaterno"],
    apellidoMaterno: json["apellidoMaterno"],
    userName: json["userName"],
    contrasenia: json["contrasenia"],
    tipoUsuario: json["tipoUsuario"],
    estatus: json["estatus"],
    puestoId: json["puestoId"],
    nombrePuesto: json["nombrePuesto"],
    nombreDepartamento: json["nombreDepartamento"],
    imagen: json["imagen"],
  );
  factory UsuarioModels.fromJson3(Map<String, dynamic> json) => UsuarioModels(
    idUsuario: json["idUsuario"],
    nombre: json["nombre"],
    apellidoPaterno: json["apellidoPaterno"],
    apellidoMaterno: json["apellidoMaterno"],
    userName: json["userName"],
    contrasenia: json["contrasenia"],
    tipoUsuario: json["tipoUsuario"],
  );
  Map<String, dynamic> toJson() => {
    "idUsuario": idUsuario,
    "nombre": nombre,
    "apellidoPaterno": apellidoPaterno,
    "apellidoMaterno": apellidoMaterno,
    "userName": userName,
    "contrasenia": contrasenia,
    "tipoUsuario": tipoUsuario,
    "estatus": estatus,
    "puestoID": puestoId,
    "nombrePuesto": nombrePuesto,
    "nombreDepartamento": nombreDepartamento
  };
}
