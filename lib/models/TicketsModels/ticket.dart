import 'dart:convert';

List<TicketsModels> ticketsModelsFromJson(String str) =>
    List<TicketsModels>.from(
        json.decode(str).map((x) => TicketsModels.fromJson(x)));
TicketsModels ticketsModelsSingleFromJson(String str) =>
    TicketsModels.fromJson5(json.decode(str));

class TicketsModels {
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
  String? NombreDepartamentoUsuarioLevantado;
  String? FechaAtencion;

  TicketsModels(
      {this.IDTickets,
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
      this.NombreDepartamentoUsuarioLevantado,
      this.FechaAtencion});

  factory TicketsModels.fromJson(Map<String, dynamic> json) => TicketsModels(
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
      NombreDepartamentoUsuarioLevantado: json["nombreDepartamentoUsuario"],
      FechaAtencion: json["fecha_atencion"]);

  factory TicketsModels.fromJson5(Map<String, dynamic> json) => TicketsModels(
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
      NombreDepartamentoUsuarioLevantado: json["nombreDepartamentoUsuario"],
      FechaAtencion: json["fecha_atencion"]);
}
