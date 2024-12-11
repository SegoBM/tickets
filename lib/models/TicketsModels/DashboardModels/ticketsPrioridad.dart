import 'dart:convert';

List<TicketsPrioridad> ticketsPrioridadFromJson(String str) => List<TicketsPrioridad>.from(json.decode(str).map((x) => TicketsPrioridad.fromJson(x)));

String ticketsPrioridadToJson(List<TicketsPrioridad> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class TicketsPrioridad {
  String prioridad;
  int cantidad;

  TicketsPrioridad({
    required this.prioridad,
    required this.cantidad,
  });

  factory TicketsPrioridad.fromJson(Map<String, dynamic> json) => TicketsPrioridad(
    prioridad: json["prioridad"],
    cantidad: json["cantidad"],
  );

  Map<String, dynamic> toJson() => {
    "prioridad": prioridad,
    "cantidad": cantidad,
  };
}