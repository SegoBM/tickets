import 'dart:convert';

List<ListaPrecioK> listaPrecioK(String str) =>
    List<ListaPrecioK>.from(json.decode(str).map((x) =>
        ListaPrecioK.fromJson(x)));

String listaPrecioKToJson(List<ListaPrecioK> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));


class ListaPrecioK{
 String? idListaPrecioK;
 double? precioSugerido;
 double? descuento;
 double? ganancia;
 double? total;
 String? ListaPrecioID;
 String? KitsID;

 ListaPrecioK({
   this.idListaPrecioK,
   this.precioSugerido,
   this.descuento,
   this.ganancia,
   this.total,
   this.ListaPrecioID,
   this.KitsID,
});

 factory ListaPrecioK.fromJson(Map<String, dynamic> json) => ListaPrecioK(
  idListaPrecioK: json["idListaPrecioK"],
   precioSugerido: json["precioSugerido"],
   descuento: json["descuento"],
   ganancia: json["ganancia"],
   total: json["total"],
   ListaPrecioID: json["ListaPrecioID"],
   KitsID: json["KitsID"]
 );

 Map<String, dynamic> toJson() => {
   "idListaPrecioK" : idListaPrecioK,
   "precioSugerido": precioSugerido,
   "descuento": descuento,
   "ganancia": ganancia,
   "total": total,
   "ListaPrecioID" : ListaPrecioID,
   "KitsID" : KitsID
 };

 @override
 String toString(){
   return 'ListaPrecioK(idListaID: $idListaPrecioK, precioSugerido: $precioSugerido, descuento: $descuento, ganancia: $ganancia, total: $ListaPrecioID, KitsID: $KitsID )';
 }
}