import 'dart:convert';

List<AjustesGeneralesModels> ajustesGeneralesModelsFromJson(String str) => List<AjustesGeneralesModels>.from(json.decode(str).map((x) => AjustesGeneralesModels.fromJson(x)));

String ajustesGeneralesModelsToJson(List<AjustesGeneralesModels> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class AjustesGeneralesModels {
  String id;
  bool permisosForzosos;
  bool multiEmpresa;
  bool multiMoneda;
  bool solicitarTipoDeCambio;
  int cantidades;
  int costosPrecios;
  int montos;

  AjustesGeneralesModels({
    required this.id,
    required this.permisosForzosos,
    required this.multiEmpresa,
    required this.multiMoneda,
    required this.solicitarTipoDeCambio,
    required this.cantidades,
    required this.costosPrecios,
    required this.montos,
  });

  factory AjustesGeneralesModels.fromJson(Map<String, dynamic> json) => AjustesGeneralesModels(
    id: json["id"],
    permisosForzosos: json["permisosForzosos"],
    multiEmpresa: json["multiEmpresa"],
    multiMoneda: json["multiMoneda"],
    solicitarTipoDeCambio: json["solicitarTipoDeCambio"],
    cantidades: json["cantidades"],
    costosPrecios: json["costosPrecios"],
    montos: json["montos"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "permisosForzosos": permisosForzosos,
    "multiEmpresa": multiEmpresa,
    "multiMoneda": multiMoneda,
    "solicitarTipoDeCambio": solicitarTipoDeCambio,
    "cantidades": cantidades,
    "costosPrecios": costosPrecios,
    "montos": montos,
  };
}
