import 'dart:convert';

List<TicketsPromedio> ticketsPromedioFromJson(String str) => List<TicketsPromedio>.from(json.decode(str).map((x) => TicketsPromedio.fromJson(x)));

String ticketsPromedioToJson(List<TicketsPromedio> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class TicketsPromedio {
  int tiempoPromedioHoras;

  TicketsPromedio({
    required this.tiempoPromedioHoras,
  });

  factory TicketsPromedio.fromJson(Map<String, dynamic> json) => TicketsPromedio(
    tiempoPromedioHoras: json["tiempo_promedio_horas"],
  );

  Map<String, dynamic> toJson() => {
    "tiempo_promedio_horas": tiempoPromedioHoras,
  };
}