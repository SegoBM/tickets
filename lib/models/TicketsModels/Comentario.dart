
import 'dart:convert';

List <ComentaryModels> commentaryModelsFromJson(String str) =>
    List <ComentaryModels>.from(json.decode(str).map((x) => ComentaryModels.fromJson(x)));

class ComentaryModels {
  String? IDComentario;
  String idTicket;
  String IDUsuario;
  String Comentario;
  String? FechaHoraComentario;
  String? NombreUsuario;


  ComentaryModels({
    this.IDComentario,
  required this.idTicket,
  required this.IDUsuario,
  required this.Comentario,
   this.FechaHoraComentario,
    this.NombreUsuario,
  });

  factory ComentaryModels.fromJson(Map<String, dynamic> json) => ComentaryModels(
    IDComentario: json["idComentario"],
    idTicket: json["ticketID"],
    IDUsuario: json["usuarioID"],
    Comentario: json["comentario"],
    FechaHoraComentario: json["fecha_hora"],
    NombreUsuario: json["nombreUsuario"],
  );

}
