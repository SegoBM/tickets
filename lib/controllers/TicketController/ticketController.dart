import 'dart:convert';
import 'package:tickets/shared/utils/constants.dart';
import 'package:flutter/widgets.dart';
import 'package:tickets/shared/utils/user_preferences.dart';
import 'package:http/http.dart' as http;

import '../../models/ConfigModels/userSession.dart';
import '../../models/TicketsModels/ticket.dart';

const urlapi= url;
const waitTime1 = waitTime;

class TicketController with ChangeNotifier {
  TicketController() {}

  Future<TicketsModels?> updateTicket(TicketsModels ticket) async {
    final url1 = Uri.http(urlapi, '/api/Tickets/ID');

    const int maxAttempts = 3; // Número máximo de intentos
    int attempts = 0;
    while(attempts < maxAttempts){
      try {
        String? token = await UserSession().getToken();
        final resp = await http.put(url1,
          body: jsonEncode({
            "idTickets": '${ticket.IDTickets}',
            "usuarioAsignadoID" : ticket.UsuarioAsignadoID!=""?"${ticket.UsuarioAsignadoID}":null,
            "departamentoID" : '${ticket.DepartamentoID}',
            "titulo" : '',
            "descripcion" : '${ticket.Descripcion}',
            "estatus" : '${ticket.Estatus}',
            "prioridad" : '${ticket.Prioridad}',
            "etiqueta" : '${ticket.Etiqueta}',
            "imagen1" : '${ticket.Imagen1}',
            "imagen2" : '${ticket.Imagen2}',
            "imagen3" : '${ticket.Imagen3}'
          }),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        );
        if (resp.statusCode == 200 || resp.statusCode == 201) {
          return TicketsModels.fromJson(jsonDecode(resp.body));
        } else {
          attempts++;
          if (attempts >= maxAttempts) {
            return null;
          }
        }
      } catch (e) {
        print('Error al enviar la solicitud: $e');
        attempts++;
        if (attempts >= maxAttempts) {
          return null;
        }
      }
      await Future.delayed(const Duration(milliseconds: waitTime1));
    }
  }


  Future<bool> saveTickets(TicketsModels ticket) async {
    UserPreferences userPreferences = UserPreferences();
    String idUsuario = await userPreferences.getUsuarioID();
    final url1 = Uri.http(urlapi, '/api/Tickets');
    const int maxAttempts = 3; // Número máximo de intentos
    int attempts = 0;

    while (attempts < maxAttempts) {
      try {
        String? token = await UserSession().getToken();
        final resp = await http.post(url1,
          body: jsonEncode({
            "UsuarioID": '${idUsuario}',
            "UsuarioAsignadoID": ticket.UsuarioAsignadoID != "" ? ticket.UsuarioAsignadoID : null,
            "DepartamentoID": '${ticket.DepartamentoID}',
            "Titulo": '${ticket.Titulo}',
            "Descripcion": '${ticket.Descripcion}',
            "Estatus": '${ticket.Estatus}',
            "Prioridad": '${ticket.Prioridad}',
            "Etiqueta": '${ticket.Etiqueta}',
            "Imagen1": '${ticket.Imagen1}',
            "Imagen2": '${ticket.Imagen2}',
            "Imagen3": '${ticket.Imagen3}',
          }),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',

          },
        );
        if (resp.statusCode == 200 || resp.statusCode == 201) {
          return true;
        } else {
          attempts++;
          if (attempts >= maxAttempts) {
            return false;
          }
        }
      } catch (e) {
        print('Error al enviar la solicitud: $e');
        attempts++;
        if (attempts >= maxAttempts) {
          return false;
        }
      }
      await Future.delayed(const Duration(milliseconds: waitTime1));
    }
    return false;
  }
}
