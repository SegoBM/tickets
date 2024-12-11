import 'dart:convert';

List<VersionErp> versionErpFromJson(String str) => List<VersionErp>.from(json.decode(str).map((x) => VersionErp.fromJson(x)));

String versionErpToJson(List<VersionErp> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class VersionErp {
  String id;
  String versionFullErp;

  VersionErp({
    required this.id,
    required this.versionFullErp,
  });

  factory VersionErp.fromJson(Map<String, dynamic> json) => VersionErp(
    id: json["id"],
    versionFullErp: json["versionFullERP"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "versionFullERP": versionFullErp,
  };
}