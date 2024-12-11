import 'dart:convert';

List <DatosBancariosModels> datosBancariosModelsFromJson(String str) =>
    List <DatosBancariosModels>.from(json.decode(str).map((x) => DatosBancariosModels.fromJson(x)));

DatosBancariosModels datosBancariosFromJsonS(String str) => DatosBancariosModels.fromJson(json.decode(str));

String datosBancariosModelsToJson(List<DatosBancariosModels> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class DatosBancariosModels {
  String idDatosBancarios;
  String banco;
  String clabe;
  String nombreTitular;
  String tipoCuenta;
  String moneda;
  String metodoPago;
  String bancoInternacional;
  String clabeInternacional;
  String tipoCuentaInternacional;
  String proveedorId;

  DatosBancariosModels({
    required this.idDatosBancarios,
    required this.banco,
    required this.clabe,
    required this.nombreTitular,
    required this.tipoCuenta,
    required this.moneda,
    required this.metodoPago,
    required this.bancoInternacional,
    required this.clabeInternacional,
    required this.tipoCuentaInternacional,
    required this.proveedorId,
  });

  factory DatosBancariosModels.fromJson(Map<String, dynamic> json) => DatosBancariosModels(
    idDatosBancarios: json["idDatosBancarios"],
    banco: json["banco"],
    clabe: json["clabe"],
    nombreTitular: json["nombreTitular"],
    tipoCuenta: json["tipoCuenta"],
    moneda: json["moneda"],
    metodoPago: json["metodoPago"],
    bancoInternacional: json["bancoInternacional"],
    clabeInternacional: json["clabeInternacional"],
    tipoCuentaInternacional: json["tipoCuentaInternacional"],
    proveedorId: json["proveedorId"],
  );

  Map<String, dynamic> toJson() => {
    "idDatosBancarios": idDatosBancarios,
    "banco": banco,
    "clabe": clabe,
    "nombreTitular": nombreTitular,
    "tipoCuenta": tipoCuenta,
    "moneda": moneda,
    "metodoPago": metodoPago,
    "bancoInternacional": bancoInternacional,
    "clabeInternacional": clabeInternacional,
    "tipoCuentaInternacional": tipoCuentaInternacional,
    "proveedorId": proveedorId,
  };
}
