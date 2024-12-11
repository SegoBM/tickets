import 'dart:convert';

List<TicketsEstatus> ticketsEstatusFromJson(String str) => List<TicketsEstatus>.from(json.decode(str).map((x) => TicketsEstatus.fromJson(x)));

String ticketsEstatusToJson(List<TicketsEstatus> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class TicketsEstatus {
  String estatus;
  int cantidad;

  TicketsEstatus({
    required this.estatus,
    required this.cantidad,
  });

  factory TicketsEstatus.fromJson(Map<String, dynamic> json) => TicketsEstatus(
    estatus: json["estatus"],
    cantidad: json["cantidad"],
  );

  Map<String, dynamic> toJson() => {
    "estatus": estatus,
    "cantidad": cantidad,
  };
}