
import 'dart:convert';

List <StatusModels> commentaryModelsFromJson(String str) =>
    List <StatusModels>.from(json.decode(str).map((x) => StatusModels.fromJson(x)));

class StatusModels {
  String idTicket;
  String status;



  StatusModels({
    required this.idTicket,
    required this.status,

  });

  factory StatusModels.fromJson(Map<String, dynamic> json) => StatusModels(
    idTicket: json["id"],
    status: json["estatus"],

  );

}
