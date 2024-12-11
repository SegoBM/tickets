import 'dart:convert';

List<ListaPrecioPSMK> listaPrecioPsmkFromJson(String str) => List<ListaPrecioPSMK>.from(json.decode(str).map((x) => ListaPrecioPSMK.fromJson(x)));

String listaPrecioPsmkToJson(List<ListaPrecioPSMK> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));
String listaPrecioPsmkToJson2(List<ListaPrecioPSMK> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson2())));
class ListaPrecioPSMK {
  String? idListaPrecio;
  String listaPrecioId;
  String? servicioProductoId;
  double precio;

  ListaPrecioPSMK({
    this.idListaPrecio,
    required this.listaPrecioId,
    this.servicioProductoId,
    required this.precio,
  });

  factory ListaPrecioPSMK.fromJson(Map<String, dynamic> json) => ListaPrecioPSMK(
    idListaPrecio: json["idListaPrecio"],
    listaPrecioId: json["listaPrecioID"],
    servicioProductoId: json["servicioProductoID"],
    precio: json["precio"],
  );

  Map<String, dynamic> toJson() => {
    "idListaPrecio": idListaPrecio,
    "listaPrecioID": listaPrecioId,
    "servicioProductoID": servicioProductoId,
    "precio": precio,
  };
  Map<String, dynamic> toJson2() => {
    "listaPrecioID": listaPrecioId,
    "precio": precio
  };

  @override
  String toString() {
    return 'ListaPrecioPSMK( listaPredioID:$listaPrecioId, precio: $precio)';
  }
}
