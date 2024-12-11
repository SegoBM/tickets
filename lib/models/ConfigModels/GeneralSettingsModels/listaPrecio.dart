import 'dart:convert';

List<ListaPrecio> listaPrecioFromJson(String str) => List<ListaPrecio>.from(json.decode(str).map((x)
  => ListaPrecio.fromJson(x)));

String listaPrecioToJson(List<ListaPrecio> data)
  => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

ListaPrecio listaPrecioModelFromJson(String str) {
  final jsonData = json.decode(str);
  return ListaPrecio.fromJson(jsonData);
}
class ListaPrecio {
  String idListaPrecio;
  String? precio;
  String? descripcion;
  bool? estatus;
  double? cantidad;
  bool porcentaje;
  double porcentajeValue;
  bool monto;
  double montoValue;
  bool capturaManual;
  bool listaBase;
  bool? isChecked;

  ListaPrecio({
    required this.idListaPrecio,
    this.precio,
    this.descripcion,
    this.estatus,
    this.cantidad = 0.0,
    this.porcentaje = false,
    this.porcentajeValue = 0,
    this.monto = false,
    this.montoValue = 0,
    this.capturaManual = false,
    this.listaBase = false,
    this.isChecked =false,
  });

  factory ListaPrecio.fromJson(Map<String, dynamic> json) => ListaPrecio(
    idListaPrecio: json["idListaPrecio"],
    precio: json["precio"],
    descripcion: json["descripcion"],
    estatus: json["estatus"],
    cantidad: json["cantidad"]??0.0,
    porcentaje: json["porcentaje"]?? false,
    porcentajeValue: json["porcentajeValue"]?? 0,
    monto: json["monto"]?? false,
    montoValue: json["montoValue"]?? 0,
    capturaManual: json["capturaManual"]?? false,
    listaBase: json["listaBase"],
  );

  Map<String, dynamic> toJson() => {
    "idListaPrecio": idListaPrecio,
    "precio": precio,
    "descripcion": descripcion,
    "estatus": estatus,
    "cantidad": cantidad,
    "porcentaje": porcentaje,
    "monto": monto,
    "capturaManual": capturaManual,
    "listaBase": listaBase,
  };
}
