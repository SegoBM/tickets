import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:tickets/models/ComprasModels/ServiciosProductosModels/servicioProductosConProveedores.dart';
import '../../../controllers/ComprasController/ListaPrecioPSMK/listaPrecioPSMK.dart';

List <ServiciosProductosModels> serviciosProductosModelsFromJson(String str) =>
    List <ServiciosProductosModels>.from(json.decode(str).map((x) => ServiciosProductosModels.fromJson(x)));

List<ServiciosProductos> serviciosProductosPModelsFromJson(String str) =>
  List <ServiciosProductos>.from(json.decode(str).map((x) => ServiciosProductos.fromJson(x)));

ServiciosProductosModels serviciosProductosFromJsonS(String str) => ServiciosProductosModels.fromJson(json.decode(str));

String serviciosProductosModelsToJson(List<ServiciosProductosModels> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ServiciosProductos {
  ServiciosProductosModels serviciosProductos;
  List<ServicioProductoProveedores>? proveedoresList = [];
  List<ListaPrecioPSMK>? listaPrecioPSMK = [];

  ServiciosProductos({
    required this.serviciosProductos,
    this.proveedoresList,
    this.listaPrecioPSMK
  });

  factory ServiciosProductos.fromJson(Map<String, dynamic> json) =>
      ServiciosProductos(
      serviciosProductos: ServiciosProductosModels.fromJson(
          json["serviciosProductos"]),
  );


  factory ServiciosProductos.fromJson2(Map<String, dynamic> json) {
    return ServiciosProductos(
      serviciosProductos: ServiciosProductosModels.fromJson(json["servicioProductos"]),
      proveedoresList: json["proveedores"] != null
          ? List<ServicioProductoProveedores>.from(
          json["proveedores"].map((x) => ServicioProductoProveedores.fromJson(x)))
          : [],
      listaPrecioPSMK: json["listaPrecios"] != null
          ? List<ListaPrecioPSMK>.from(
          json["listaPrecios"].map((x) => ListaPrecioPSMK.fromJson(x)))
          : [],
    );
  }

  Map<String, dynamic> toJson3() => {
    "servicioProductos": serviciosProductos.toJson(),
    "proveedores": List<dynamic>.from(proveedoresList!.map((x) => x.toJson())),
    "listaPrecios": List<dynamic>.from(listaPrecioPSMK!.map((x) => x.toJson())),
  };
}


class ServiciosProductosModels {
  //datos generales
  String? idServiciosProductos;
  String codigo;
  String descripcion;
  String clasificacion;
  String categoria;
  int estatus;
  String? foto;
  //servicios y productos
  String concepto;
  //productos
  String unidad;
  //precio y control
  String moneda;
  String costeo;
  //sat
  String? claveSATID;
  //servicios
  String? duracionAproximada;

  ValueNotifier<bool> selectedNotifier = ValueNotifier(false);
  bool get selected => selectedNotifier.value;

  void toggleSelected(){
    selectedNotifier.value = !selectedNotifier.value;
  }

  factory ServiciosProductosModels.fromJson(Map<String, dynamic> json) => ServiciosProductosModels(
    idServiciosProductos: json["idServiciosProductos"],
    codigo: json["codigo"],
    descripcion: json["descripcion"],
    clasificacion: json["clasificacion"],
    categoria: json["categoria"],
    estatus: json["estatus"],
    foto: json["foto"],
    concepto: json["concepto"],
    unidad: json["unidad"],
    moneda: json["moneda"],
    costeo: json["costeo"],
    claveSATID: json["claveSATID"],
    duracionAproximada: json["duracionAproximada"],
  );

  ServiciosProductosModels({
    //generales
    this.idServiciosProductos,
    required this.codigo,
    required this.descripcion,
    required this.clasificacion,
    required this.categoria,
    required this.estatus,
    required this.foto,
    //servicios y productos
    required this.concepto,
    //servicios
    required this.duracionAproximada,
    //productos
    required this.unidad,
    //precios y control
    required this.moneda,
    required this.costeo,
    //sat
    this.claveSATID,
  });

  Map<String, dynamic> toJson() => {
    //generales
    "idServiciosProductos": idServiciosProductos,
    "codigo": codigo,
    "descripcion": descripcion,
    "clasificacion": clasificacion,
    "categoria": categoria,
    "estatus": estatus,
    "foto": foto,
    //servicios y productos
    "concepto": concepto,
    //servicios
    "duracionAproximada": duracionAproximada,
    //productos
    "unidad": unidad,
    //precios y control
    "moneda": moneda,
    "costeo": costeo,
    //sat
    "claveSATID": claveSATID,
  };

}
