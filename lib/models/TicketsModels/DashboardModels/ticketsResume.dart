import 'dart:convert';

List<TicketsResume> ticketsResumeFromJson(String str) => List<TicketsResume>.from(json.decode(str).map((x) => TicketsResume.fromJson(x)));

String ticketsResumeToJson(List<TicketsResume> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class TicketsResume {
  String idTickets;
  String estatus;
  DateTime fechaCreacion;

  TicketsResume({
    required this.idTickets,
    required this.estatus,
    required this.fechaCreacion,
  });

  factory TicketsResume.fromJson(Map<String, dynamic> json) => TicketsResume(
    idTickets: json["idTickets"],
    estatus: json["estatus"],
    fechaCreacion: DateTime.parse(json["fecha_creacion"]),
  );

  Map<String, dynamic> toJson() => {
    "idTickets": idTickets,
    "estatus": estatus,
    "fecha_creacion": fechaCreacion.toIso8601String(),
  };
}
