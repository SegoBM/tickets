import 'dart:convert';

List<ServicioProductoProveedores> servicioProductoProveedoresFromJson(String str) =>
    List<ServicioProductoProveedores>.from(json.decode(str).map((x) => ServicioProductoProveedores.fromJson(x)));

String servicioProductoProveedoresToJson(List<ServicioProductoProveedores> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));
String servicioProductoProveedoresToJson2(List<ServicioProductoProveedores> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson2())));

class ServicioProductoProveedores {
  String? id;
  String? proveedorId;
  double? costo =0.0;
  double? descuento=0.0;
  double? total =0.0;
  int? calificacion=0;
  double? compraMinima=0.0;
  String? mejorConocido;
  bool? lm = false;

  ServicioProductoProveedores({
    this.id,
    this.proveedorId,
    this.costo,
    this.descuento,
    this.total,
    this.calificacion,
    this.compraMinima,
    this.mejorConocido,
    this.lm,
  });

  factory ServicioProductoProveedores.fromJson(Map<String, dynamic> json) => ServicioProductoProveedores(
    id: json["id"],
    proveedorId: json["proveedorID"],
    costo: json["costo"],
    descuento: json["descuento"],
    total: json["total"],
    calificacion: json["calificacion"],
    compraMinima: json["compraMinima"],
    mejorConocido: json["mejorConocido"],
    lm: json["lm"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "proveedorID": proveedorId,
    "costo": costo,
    "descuento": descuento,
    "total": total,
    "calificacion": calificacion,
    "compraMinima": compraMinima,
    "mejorConocido": mejorConocido,
    "lm": lm,
  };

  Map<String, dynamic> toJson2() => {
    "proveedorID": proveedorId,
    "costo": costo,
    "descuento": descuento,
    "total": total,
    "calificacion": calificacion,
    "compraMinima": compraMinima,
    "mejorConocido": mejorConocido,
    "lm": lm,
  };

  @override
  String toString(){
    return 'Proveedores(id:$proveedorId, costo: $costo, descuento: $descuento, total: $total, calificacion: $calificacion, mejorConocido: $mejorConocido, lm: $lm)';
  }

}
