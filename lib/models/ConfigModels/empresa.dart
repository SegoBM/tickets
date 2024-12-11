import 'dart:convert';

import 'package:flutter/cupertino.dart';

List <EmpresaModels> empresaModelsFromJson(String str) =>
    List <EmpresaModels>.from(json.decode(str).map((x) => EmpresaModels.fromJson(x)));
String empresaModelsToJson(List<EmpresaModels> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class EmpresaModels {
  String? idEmpresa;
  String nombre;
  String direccion;
  String razonSocial;
  bool? estatus;
  String rfc;
  int cp;
  String giro;
  String telefono;
  String correo;
  String regimenFiscal;
  String? selloDigital;
  String? direccionFiscal;
  String? logo;
  ValueNotifier<bool> selectedNotifier = ValueNotifier(false);
  bool get selected => selectedNotifier.value;

  EmpresaModels({
    this.idEmpresa,
    required this.nombre, required this.direccion,
    required this.razonSocial, this.estatus,
    required this.rfc, required this.cp,
    required this.giro, required this.telefono,
    required this.correo, required this.regimenFiscal,
    this.selloDigital, this.direccionFiscal, this.logo
  });

  void toggleSelected() {
    selectedNotifier.value = !selectedNotifier.value;
  }
  factory EmpresaModels.fromJson(Map<String, dynamic> json) => EmpresaModels(
    idEmpresa: json["idEmpresa"],
    nombre: json["nombre"],
    direccion: json["direccion"],
    razonSocial: json["razonSocial"],
    estatus: json["estatus"],
    rfc: json["rfc"],
    cp: json["cp"],
    giro: json["giro"],
    telefono: json["telefono"],
    correo: json["correo"],
    regimenFiscal: json["regimenFiscal"],
    selloDigital: json ["selloDigital"],
    direccionFiscal: json ["direccionFiscal"],
    logo: json ["logo"]
  );

  Map<String, dynamic> toJson() => {
    "idEmpresa": idEmpresa,
    "nombre": nombre,
    "direccion": direccion,
    "razonSocial": razonSocial,
    "estatus": estatus,
    "rfc": rfc,
    "cp": cp,
    "giro": giro,
    "telefono": telefono,
    "correo": correo,
    "regimenFiscal": regimenFiscal,
    "selloDigital" : selloDigital,
    "direccionFiscal": direccionFiscal,
    "logo": logo
  };
}
