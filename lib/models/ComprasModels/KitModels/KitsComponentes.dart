import 'dart:convert';

List<KitsComponentes> kitsComponentesFromJson(String str) =>
    List<KitsComponentes>.from(json.decode(str).map((x) => KitsComponentes.fromJson(x)));

String kitsComponentesToJson(List<KitsComponentes> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson)));

class KitsComponentes {
  String? id;
  String? servicioID;
  String? productoID;
  String? materialID;
  double? cantidad = 0.0;
  String? KitID;

  KitsComponentes({
    this.id,
    this.servicioID,
    this.productoID,
    this.materialID,
    this.cantidad,
    this.KitID
});

  factory KitsComponentes.fromJson(Map<String, dynamic> json) => KitsComponentes(
    id: json["id"],
    servicioID: json["servicioID"],
    productoID: json["productoID"],
    materialID: json["materialID"],
    cantidad: json["cantidad"],
    KitID: json["KitID"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "servicioID": servicioID,
    "productoID": productoID,
    "materialID": materialID,
    "cantidad": cantidad,
    "KitID" : KitID,
  };

  @override
  String toString(){
    return 'Componentes(id:$id, servicio:$servicioID, producto:$productoID, material:$materialID, cantidad:$cantidad, kitID:$KitID)';
  }

}




