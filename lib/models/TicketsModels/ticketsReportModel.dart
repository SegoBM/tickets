
import 'dart:convert';

List <TicketsReportModel> ticketsReportModelsFromJson(String str) =>
    List <TicketsReportModel>.from(json.decode(str).map((x) => TicketsReportModel.fromJson(x)));

class TicketsReportModel {
  String? IDTickets;
  String UsuarioID;
  String? UsuarioAsignadoID;
  String DepartamentoID;
  String Titulo;
  String Descripcion;
  String Estatus;
  String? FechaCreacion;
  String? FechaAsignacion;
  String? FechaFinalizacion;
  int? NumeroTicket;
  String Prioridad;
  String? Etiqueta;
  String? Imagen1;
  String? Imagen2;
  String? Imagen3;
  String? UsuarioNombre;
  String? NombreDepartamento;
  String? NombreUsuarioAsignado;
  int? CalificacionGeneral;
  int? CalificacionTiempo;
  int? CalificacionCalidad;
  String? Comentarios;

  TicketsReportModel({
    this.IDTickets,
    required this.UsuarioID,
    this.UsuarioAsignadoID,
    required this.DepartamentoID,
    required this.Titulo,
    required this.Descripcion,
    required this.Estatus,
    this.FechaCreacion,
    this.FechaAsignacion,
    this.FechaFinalizacion,
    this.NumeroTicket,
    required this.Prioridad,
    this.Etiqueta,
    this.Imagen1,
    this.Imagen2,
    this.Imagen3,
    this.UsuarioNombre,
    this.NombreDepartamento,
    this.NombreUsuarioAsignado,
    this.CalificacionGeneral,
    this.CalificacionTiempo,
    this.CalificacionCalidad,
    this.Comentarios
  });

  factory TicketsReportModel.fromJson(Map<String, dynamic> json) {
    var encuestaSatisfaccion = json["encuestaSatisfaccion"] ?? {};
    return TicketsReportModel(
        IDTickets: json["idTickets"],
        UsuarioID: json["usuarioID"],
        UsuarioAsignadoID: json["usuarioAsignadoID"],
        DepartamentoID: json["departamentoID"],
        Titulo: json["titulo"],
        Descripcion: json["descripcion"],
        Estatus: json["estatus"],
        FechaCreacion: json["fecha_creacion"],
        FechaAsignacion: json["fecha_asignacion"],
        FechaFinalizacion: json["fecha_finalizacion"],
        NumeroTicket: json["numero_ticket"],
        Prioridad: json["prioridad"],
        Etiqueta: json["etiqueta"],
        Imagen1: json["imagen1"],
        Imagen2: json["imagen2"],
        Imagen3: json["imagen3"],
        UsuarioNombre: json["nombreUsuario"],
        NombreDepartamento: json["nombreDepartamento"],
        NombreUsuarioAsignado: json["nombreUsuarioAsignado"],
        CalificacionGeneral: encuestaSatisfaccion["calificacion_General"],
        CalificacionTiempo: encuestaSatisfaccion["calificacion_Tiempo"],
        CalificacionCalidad: encuestaSatisfaccion["calificacion_Calidad"],
        Comentarios: encuestaSatisfaccion["comentarios"]
    );
  }
}
