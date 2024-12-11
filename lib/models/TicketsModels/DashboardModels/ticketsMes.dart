import 'dart:convert';

List<TicketsMes> ticketsMesFromJson(String str) => List<TicketsMes>.from(json.decode(str).map((x) => TicketsMes.fromJson(x)));

String ticketsMesToJson(List<TicketsMes> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class TicketsMes {
  int mes;
  int ticketsAbiertos;
  int ticketsCerrados;

  TicketsMes({
    required this.mes,
    required this.ticketsAbiertos,
    required this.ticketsCerrados,
  });

  factory TicketsMes.fromJson(Map<String, dynamic> json) => TicketsMes(
    mes: json["mes"],
    ticketsAbiertos: json["tickets_abiertos"],
    ticketsCerrados: json["tickets_cerrados"],
  );

  Map<String, dynamic> toJson() => {
    "mes": mes,
    "tickets_abiertos": ticketsAbiertos,
    "tickets_cerrados": ticketsCerrados,
  };
}