import 'dart:convert';

MaterialesWSuppliers materialesWSuppliersFromJson(String str) => MaterialesWSuppliers.fromJson(json.decode(str));

String materialesWSuppliersToJson(MaterialesWSuppliers data) => json.encode(data.toJson());

class MaterialesWSuppliers {
  MaterialSuppModel material;
  List<String> proveedoresIDs;

  MaterialesWSuppliers({
    required this.material,
    required this.proveedoresIDs,
  });

  factory MaterialesWSuppliers.fromJson(Map<String, dynamic> json) => MaterialesWSuppliers(
    material: MaterialSuppModel.fromJson(json["material"]),
    proveedoresIDs: List<String>.from(json["proveedoresIDs"].map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "material": material.toJson2(),
    "proveedoresIDs": List<String>.from(proveedoresIDs.map((x) => x)),
  };

}
class MaterialSuppModel {
  String? idMaterial;
  String categoria;
  String codigoProducto;
  String unidadMedidaCompra;
  String unidadMedidaVenta;
  String composicion;
  double? espesorMm;
  double? ancho;
  double? largo;
  int metrosXRollo;
  double? costo;
  double? precioVenta;
  double? igi;
  int estatus;
  String referenciaCalidad;
  String referenciaColor;
  double? gsm;
  double? pesoXBulto;
  String descripcion;
  String foto;
  String subFamiliaId;
  double? fraccionArancelaria;
  MaterialSuppModel({
     this.idMaterial,
     required this.categoria,
     required this.codigoProducto,
     required this.unidadMedidaCompra,
     required this.unidadMedidaVenta,
     required this.composicion,
     this.espesorMm,
     this.ancho,
     this.largo,
     required this.metrosXRollo,
     this.costo,
     this.precioVenta,
     this.igi,
     required this.estatus,
     required this.referenciaCalidad,
     required this.referenciaColor,
     this.gsm,
     this.pesoXBulto,
     required this.descripcion,
     required this.foto,
     required this.subFamiliaId,
     this.fraccionArancelaria,
  });

  factory MaterialSuppModel.fromJson(Map<String, dynamic> json) => MaterialSuppModel(
    idMaterial: json["idMaterial"],
    categoria: json["categoria"],
    codigoProducto: json["codigoProducto"],
    unidadMedidaCompra: json["unidadMedidaCompra"],
    unidadMedidaVenta: json["unidadMedidaVenta"],
    composicion: json["composicion"],
    espesorMm: json["espesorMM"],
    ancho: json["ancho"],
    largo: json["largo"],
    metrosXRollo: json["metrosXRollo"],
    costo: json["costo"],
    precioVenta: json["precioVenta"],
    igi: json["igi"],
    estatus: json["estatus"],
    referenciaCalidad: json["referenciaCalidad"],
    referenciaColor: json["referenciaColor"],
    gsm: json["gsm"],
    pesoXBulto: json["pesoXBulto"],
    descripcion: json["descripcion"],
    foto: json["foto"],
    subFamiliaId: json["subFamiliaId"],
    fraccionArancelaria: json["fraccionArancelaria"],
  );

  Map<String, dynamic> toJson() => {
    "idMaterial": idMaterial,
    "categoria": categoria,
    "codigoProducto": codigoProducto,
    "unidadMedidaCompra": unidadMedidaCompra,
    "unidadMedidaVenta": unidadMedidaVenta,
    "composicion": composicion,
    "espesorMM": espesorMm,
    "ancho": ancho,
    "largo": largo,
    "metrosXRollo": metrosXRollo,
    "costo": costo,
    "precioVenta": precioVenta,
    "igi": igi,
    "estatus": estatus,
    "referenciaCalidad": referenciaCalidad,
    "referenciaColor": referenciaColor,
    "gsm": gsm,
    "pesoXBulto": pesoXBulto,
    "descripcion": descripcion,
    "foto": foto,
    "subFamiliaId": subFamiliaId,
    "fraccionArancelaria": fraccionArancelaria,
  };

  Map<String, dynamic> toJson2() => {
    "categoria": categoria,
    "codigoProducto": codigoProducto,
    "unidadMedidaCompra": unidadMedidaCompra,
    "unidadMedidaVenta": unidadMedidaVenta,
    "composicion": composicion,
    "espesorMM": espesorMm,
    "ancho": ancho,
    "largo": largo,
    "metrosXRollo": metrosXRollo,
    "costo": costo,
    "precioVenta": precioVenta,
    "igi": igi,
    "estatus": estatus,
    "referenciaCalidad": referenciaCalidad,
    "referenciaColor": referenciaColor,
    "gsm": gsm,
    "pesoXBulto": pesoXBulto,
    "descripcion": descripcion,
    "foto": foto,
    "subFamiliaId": subFamiliaId,
    "fraccionArancelaria": fraccionArancelaria,
  };
}
