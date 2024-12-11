
import 'dart:convert';

List <ComentaryTicketModel> commentaryModelsFromJson(String str) =>
    List <ComentaryTicketModel>.from(json.decode(str).map((x) => ComentaryTicketModel.fromJson(x)));

class ComentaryTicketModel {
  String Ticket;
  String Comentarios;


  ComentaryTicketModel({
    required this.Ticket,
    required this.Comentarios,

  });

  factory ComentaryTicketModel.
  fromJson(Map<String, dynamic> json) => ComentaryTicketModel(
    Ticket: json["Ticket"],
    Comentarios: json["Comentarios"],

  );

}
