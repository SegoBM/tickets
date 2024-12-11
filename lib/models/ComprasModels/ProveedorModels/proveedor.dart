import 'dart:convert';

import 'package:flutter/cupertino.dart';

List <ProveedorModels> proveedorModelsFromJson(String str) =>
    List <ProveedorModels>.from(json.decode(str).map((x) => ProveedorModels.fromJson(x)));

ProveedorModels proveedorFromJsonS(String str) => ProveedorModels.fromJson(json.decode(str));

String proveedorModelsToJson(List<ProveedorModels> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ProveedorModels {
  String idProveedor;
  String nombre;
  String razonSocial;
  String rfc;
  String correoElectronico;
  String telefono;
  String descripcion;
  String colonia;
  String calle;
  String numExt;
  String numInt;
  int codigoPostal;
  String ciudad;
  String pais;
  bool estatus;
  String estado;
  ValueNotifier<bool> selectedNotifier = ValueNotifier(false);
  bool get selected => selectedNotifier.value;

  ProveedorModels({
    required this.idProveedor,
    required this.nombre,
    required this.razonSocial,
    required this.rfc,
    required this.correoElectronico,
    required this.telefono,
    required this.descripcion,
    required this.colonia,
    required this.calle,
    required this.numExt,
    required this.numInt,
    required this.codigoPostal,
    required this.ciudad,
    required this.pais,
    required this.estatus,
    required this.estado,
  });
  void toggleSelected() {
    selectedNotifier.value = !selectedNotifier.value;
  }

  factory ProveedorModels.fromJson(Map<String, dynamic> json) => ProveedorModels(
    idProveedor: json["idProveedor"],
    nombre: json["nombre"],
    razonSocial: json["razonSocial"],
    rfc: json["rfc"],
    correoElectronico: json["correoElectronico"],
    telefono: json["telefono"],
    descripcion: json["descripcion"],
    colonia: json["colonia"],
    calle: json["calle"],
    numExt: json["numExt"],
    numInt: json["numInt"],
    codigoPostal: json["codigoPostal"],
    ciudad: json["ciudad"],
    pais: json["pais"],
    estatus: json["estatus"],
    estado: json["estado"],
  );

  Map<String, dynamic> toJson() => {
    "idProveedor": idProveedor,
    "nombre": nombre,
    "razonSocial": razonSocial,
    "rfc": rfc,
    "correoElectronico": correoElectronico,
    "telefono": telefono,
    "descripcion": descripcion,
    "colonia": colonia,
    "calle": calle,
    "numExt": numExt,
    "numInt": numInt,
    "codigoPostal": codigoPostal,
    "ciudad": ciudad,
    "pais": pais,
    "estatus": estatus,
    "estado": estado,
  };

  @override
  String toString(){
    return 'Proveedores(id:$idProveedor, rfc: $rfc, razonSocial: $razonSocial)';
  }

}
