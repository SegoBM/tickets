
import 'dart:convert';

List <SatisfactionModel> commentaryModelsFromJson(String str) =>
    List <SatisfactionModel>.from(json.decode(str).map((x) => SatisfactionModel.fromJson(x)));

class SatisfactionModel {
  int? calificacion_General;
  int? calificacion_Tiempo;
  int? calificacion_Calidad;
  String? Comentario;
  String? ticketsID;



  SatisfactionModel({
    this.calificacion_General,
    this.calificacion_Tiempo,
    this.calificacion_Calidad,
    this.Comentario,
    this.ticketsID,
  });

  factory SatisfactionModel.fromJson(Map<String, dynamic> json) => SatisfactionModel(
    calificacion_General: json["calificacion_General"],
    calificacion_Tiempo: json["calificacion_Tiempo"],
    calificacion_Calidad: json["calificacion_Calidad"],
    Comentario: json["comentarios"],
    ticketsID: json["ticketsID"],
  );

}
