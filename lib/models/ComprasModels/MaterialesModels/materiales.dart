import 'dart:convert';

import 'package:flutter/cupertino.dart';

List<MaterialesModels> materialesModelsFromJson (String str) =>
    List <MaterialesModels>.from(json.decode(str).map((x) => MaterialesModels.fromJson(x)));

List<MaterialesModels> materialesModelsFromJson2 (String str) =>
    List <MaterialesModels>.from(json.decode(str).map((x) => MaterialesModels.fromJson2(x)));

MaterialesModels materialesModelsFromJsonS (String str) => MaterialesModels.fromJson(json.decode(str));

String materialesModelsToJson(List<MaterialesModels> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class MaterialesModels{
  String? idMaterial;
  String categoria;
  String codigoProducto;
  String unidadMedidaCompra;
  String unidadMedidaVenta;
  String composicion;
  double? espesorMM ;
  double? ancho;
  double? largo;
  int metrosXRollo;
  double? costo;
  double? precioVenta;
  double? igi;
  String referenciaCalidad;
  String referenciaColor;
  double? gsm;
  double? pesoXBulto;
  String descripcion;
  String foto;
  String? subFamiliaID;
  double? fraccionArancelaria;
  int estatus;
  String? subFamiliaNombre;
  String? familiaNombre;
  ///String? color;
  ///Sring? talla;
  ///String? referenciaOrigenColor;
  ///String? referenciaTalla;
  ///
  ///String? referenciaColor;
  List<String>? proveedoresIDs;


  ValueNotifier<bool> selectedNotifier = ValueNotifier(false);
  bool get selected => selectedNotifier.value;

  factory MaterialesModels.fromJson(Map<String, dynamic> json) => MaterialesModels (
    idMaterial: json["idMaterial"] ?? '',
    categoria : json["categoria"] ?? '',
    codigoProducto: json["codigoProducto"] ?? '',
    unidadMedidaCompra: json["unidadMedidaCompra"] ?? '',
    unidadMedidaVenta: json["unidadMedidaVenta"] ?? '',
    composicion: json["composicion"] ?? '',
    espesorMM: json["espesorMM"].toDouble() ?? 0.0,
    ancho: json["ancho"].toDouble() ?? 0.0,
    largo: json["largo"].toDouble() ?? 0.0,
    metrosXRollo: json["metrosXRollo"] ?? '',
    costo: json["costo"].toDouble() ?? 0.0,
    precioVenta: json["precioVenta"].toDouble() ?? 0.0,
    igi: json["igi"].toDouble() ?? 0.0,
    referenciaCalidad: json["referenciaCalidad"] ?? '',
    referenciaColor: json["referenciaColor"]?? '',
    gsm: json["gsm"].toDouble() ?? 0.0,
    pesoXBulto: json["pesoXBulto"].toDouble() ?? 0.0,
    descripcion: json["descripcion"] ?? '',
    foto: json["foto"] ?? '',
    subFamiliaID: json["subFamilia"]["subFamilia"]?? '', // Acceso a subFamiliaID
    subFamiliaNombre: json["subFamilia"]["subFamiliaNombre"]?? '', // Nuevo campo subFamiliaNombre
    familiaNombre: json["subFamilia"]["familia"]["familiaNombre"]?? '',
    fraccionArancelaria: json["fraccionArancelaria"]?? '',
    estatus: json["estatus"] ?? 0,
  );
  factory MaterialesModels.fromJson2(Map<String, dynamic> json) => MaterialesModels(
    idMaterial: json["idMaterial"]?? '',
    categoria: json["categoria"]?? '',
    codigoProducto: json["codigoProducto"?? ''],
    unidadMedidaCompra: json["unidadMedidaCompra"?? ''],
    unidadMedidaVenta: json["unidadMedidaVenta"?? ''],
    composicion: json["composicion"?? ''],
    espesorMM: json["espesorMM"].toDouble() ?? 0.0,
    ancho: json["ancho"]?.toDouble() ?? 0.0,
    largo: json["largo"]?.toDouble() ?? 0.0,
    metrosXRollo: json["metrosXRollo"]?? '',
    costo: json["costo"]?.toDouble() ?? 0.0,
    precioVenta: json["precioVenta"]?.toDouble() ?? 0.0,
    igi: json["igi"]?? '',
    estatus: json["estatus"],
    referenciaCalidad: json["referenciaCalidad"]?? '',
    referenciaColor: json["referenciaColor"]?? '',
    gsm: json["gsm"]?.toDouble() ?? 0.0,
    pesoXBulto: json["pesoXBulto"]?.toDouble() ?? 0.0,
    descripcion: json["descripcion"]?? '',
    foto: json["foto"]?? '',
    subFamiliaID: json["subFamiliaID"]?? '',
    familiaNombre: json["subFamilia"]["familia"]["familiaNombre"]?? '',
    subFamiliaNombre: json["subFamilia"]["subFamiliaNombre"]?? '',
    fraccionArancelaria: json["fraccionArancelaria"]?.toDouble() ?? 0.0,
    proveedoresIDs: json["proveedoresIDs"] != null ? List<String>.from(json["proveedoresIDs"]): null,
  );
  MaterialesModels({
    this.idMaterial,
    required this.categoria,
    required this.codigoProducto,
    required this.unidadMedidaCompra,
    required this.unidadMedidaVenta,
    required this.composicion,
    this.espesorMM,
    this.ancho,
    this.largo,
    required this.metrosXRollo,
    this.costo,
    this.precioVenta,
    this.igi,
    required this.referenciaCalidad,
    required this.referenciaColor,
    this.gsm,
    this.pesoXBulto,
    required this.descripcion,
    required this.foto,
    this.subFamiliaID,
    required this.fraccionArancelaria,
    required this.estatus,
    this.subFamiliaNombre,
    this.familiaNombre,
    this.proveedoresIDs,
  });
  toggleSelected() {
    selectedNotifier.value = !selectedNotifier.value;
  }
  Map<String, dynamic> toJson() => {
    "idMaterial": idMaterial,
    "categoria": categoria,
    "codigoProducto": codigoProducto,
    "unidadMedidaCompra": unidadMedidaCompra,
    "unidadMedidaVenta": unidadMedidaVenta,
    "composicion": composicion,
    "espesorMM": espesorMM,
    "ancho": ancho,
    "largo": largo,
    "metrosXRollo": metrosXRollo,
    "costo": costo,
    "precioVenta": precioVenta,
    "igi": igi,
    "referenciaCalidad": referenciaCalidad,
    "referenciaColor": referenciaColor,
    "gsm": gsm,
    "pesoXBulto": pesoXBulto,
    "descripcion": descripcion,
    "foto": foto,
    "subFamiliaID": subFamiliaID,
    "fraccionArancelaria": fraccionArancelaria,
    "estatus": estatus,
    "subFamiliaNombre": subFamiliaNombre,
    "familiaNombre": familiaNombre,
    if (proveedoresIDs != null)
      "proveedoresIDs": List<dynamic>.from(proveedoresIDs!),
  };
}