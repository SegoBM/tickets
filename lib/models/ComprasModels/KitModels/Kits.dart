import 'dart:convert';
import 'package:tickets/models/ComprasModels/KitModels/KitsComponentes.dart';
import 'ListaPrecioK/ListaPrecioK.dart';

List<KitModels> kitModelsFromJson(String str) =>
    List<KitModels>.from(json.decode(str).map((x) => KitModels.fromJson(x)));

List<KitsConComponentes> kitsConComponentesModelsFromJson(String str) =>
  List<KitsConComponentes>.from(json.decode(str).map((x) => KitsComponentes.fromJson(x)));

KitModels kitFromJsonS(String str) => KitModels.fromJson(json.decode(str));

String kitmodelsToJson(List<KitModels> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class KitsConComponentes {
  KitModels kitModels;
  List<KitsComponentes>? kitsComponentes=[];
  List<ListaPrecioK>? listaPrecioK =[];

  KitsConComponentes({
    required this.kitModels,
    this.kitsComponentes,
    this.listaPrecioK
 });

  factory KitsConComponentes.fromJson(Map<String,dynamic> json) =>
      KitsConComponentes( kitModels: KitModels.fromJson(json ["kits"]),
      );

  factory KitsConComponentes.fromJson2(Map<String,dynamic> json){
    return KitsConComponentes(
      kitModels: KitModels.fromJson(json["kits"]),
      kitsComponentes: json["componentes"] != null
          ? List<KitsComponentes>.from(
          json["componentes"].map((x) => KitsConComponentes.fromJson(x)))
          : [],
      listaPrecioK: json["listaPrecioK"] != null
          ? List<ListaPrecioK>.from(
          json["listaPrecios"].map((x) => ListaPrecioK.fromJson(x)))
          : [],
    );
  }
}

  class KitModels {
    String? idKit;
    String codigo;
    String nombre;
    int estatus;
    String descripcion;
    DateTime? fecha;

  KitModels({
    this.idKit,
    required this.codigo,
    required this.nombre,
    required this.estatus,
    required this.descripcion,
    this.fecha,
  });

  factory KitModels.fromJson(Map<String, dynamic> json) => KitModels(
      idKit: json["idKit"],
      codigo: json["codigo"],
      nombre: json["nombre"],
      estatus: json["estatus"],
      descripcion: json["descripcion"],
      fecha: DateTime.parse(json["fecha"]),
  );

  Map<String, dynamic> toJson() => {
    "idKit" : idKit,
    "codigo" : codigo,
    "nombre" : nombre,
    "estatus" : estatus,
    "descripcion" : descripcion,
    "fecha" : fecha,
  };

    @override
    String toString() {
      return 'KitModels(codigo: $codigo, nombre: $nombre, descripcion: $descripcion, fecha: $fecha, estatus: $estatus)';
    }

}