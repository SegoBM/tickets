import 'package:tickets/models/TicketsModels/DashboardModels/ticketsEstatus.dart';
import 'package:tickets/models/TicketsModels/DashboardModels/ticketsMes.dart';
import 'package:tickets/models/TicketsModels/DashboardModels/ticketsPrioridad.dart';
import 'package:tickets/models/TicketsModels/DashboardModels/ticketsPromedio.dart';
import 'package:tickets/shared/utils/constants.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

import '../../models/TicketsModels/DashboardModels/ticketsResume.dart';

const urlapi= url;
const waitTime1 = waitTime;

class DashboardController with ChangeNotifier {
  DashboardController() {}

  Future<List<TicketsResume>> getTicketsResume (String userID) async {
    List<TicketsResume> listTickets = [];
    final url1 = Uri.http(urlapi, '/api/Dashboard/ticketsResume',{"userID": userID});
    const int maxAttempts = 3; // Número máximo de intentos
    int attempts = 0;
    while (attempts < maxAttempts) {
      print('Intento $attempts');
      try {
        final response = await http.get(url1, headers: {
          "Access-Control-Allow-Origin": "*",
          "Access-Control-Allow-Credentials": "true",
          'Content-type': 'application/json',
          'Accept': 'application/json'
        });

        if (response.statusCode == 200) {
          listTickets = ticketsResumeFromJson(response.body);
          return listTickets;
        } else {
          print('*Error en la solicitud*: ${response.statusCode}');
          attempts++;
          if (attempts >= maxAttempts) {
            return listTickets;
          }
        }
      } catch (e) {
        print('Error al enviar la solicitud: $e');
        attempts++;
        if (attempts >= maxAttempts) {
          return listTickets;
        }
      }
      await Future.delayed(const Duration(seconds: waitTime1));
    }
    return listTickets;
  }
  Future<List<TicketsPrioridad>> getTicketsPrioridad (String userID) async {
    List<TicketsPrioridad> listTickets = [];
    final url1 = Uri.http(urlapi, '/api/Dashboard/ticketsPrioridad',{"userID": userID});
    const int maxAttempts = 3; // Número máximo de intentos
    int attempts = 0;
    while (attempts < maxAttempts) {
      print('Intento $attempts');
      try {
        final response = await http.get(url1, headers: {
          "Access-Control-Allow-Origin": "*",
          "Access-Control-Allow-Credentials": "true",
          'Content-type': 'application/json',
          'Accept': 'application/json'
        });

        if (response.statusCode == 200) {
          listTickets = ticketsPrioridadFromJson(response.body);
          return listTickets;
        } else {
          print('*Error en la solicitud*: ${response.statusCode}');
          attempts++;
          if (attempts >= maxAttempts) {
            return listTickets;
          }
        }
      } catch (e) {
        print('Error al enviar la solicitud: $e');
        attempts++;
        if (attempts >= maxAttempts) {
          return listTickets;
        }
      }
      await Future.delayed(const Duration(seconds: waitTime1));
    }
    return listTickets;
  }
  Future<List<TicketsMes>> getTicketsMes (String userID) async {
    List<TicketsMes> listTickets = [];
    final url1 = Uri.http(urlapi, '/api/Dashboard/ticketsMes',{"userID": userID});
    const int maxAttempts = 3; // Número máximo de intentos
    int attempts = 0;
    while (attempts < maxAttempts) {
      print('Intento $attempts');
      try {
        final response = await http.get(url1, headers: {
          "Access-Control-Allow-Origin": "*",
          "Access-Control-Allow-Credentials": "true",
          'Content-type': 'application/json',
          'Accept': 'application/json'
        });

        if (response.statusCode == 200) {
          listTickets = ticketsMesFromJson(response.body);
          return listTickets;
        } else {
          print('*Error en la solicitud*: ${response.statusCode}');
          attempts++;
          if (attempts >= maxAttempts) {
            return listTickets;
          }
        }
      } catch (e) {
        print('Error al enviar la solicitud: $e');
        attempts++;
        if (attempts >= maxAttempts) {
          return listTickets;
        }
      }
      await Future.delayed(const Duration(seconds: waitTime1));
    }
    return listTickets;
  }
  Future<List<TicketsEstatus>> getTicketsEstatus(String userID) async{
    List<TicketsEstatus> listTickets = [];
    final url1 = Uri.http(urlapi, '/api/Dashboard/ticketsEstatus',{"userID": userID});
    const int maxAttempts = 3; // Número máximo de intentos
    int attempts = 0;
    while (attempts < maxAttempts) {
      print('Intento $attempts');
      try {
        final response = await http.get(url1, headers: {
          "Access-Control-Allow-Origin": "*",
          "Access-Control-Allow-Credentials": "true",
          'Content-type': 'application/json',
          'Accept': 'application/json'
        });

        if (response.statusCode == 200) {
          listTickets = ticketsEstatusFromJson(response.body);
          return listTickets;
        } else {
          print('*Error en la solicitud*: ${response.statusCode}');
          attempts++;
          if (attempts >= maxAttempts) {
            return listTickets;
          }
        }
      } catch (e) {
        print('Error al enviar la solicitud: $e');
        attempts++;
        if (attempts >= maxAttempts) {
          return listTickets;
        }
      }
      await Future.delayed(const Duration(seconds: waitTime1));
    }
    return listTickets;
  }
  Future<List<TicketsPromedio>> getTicketsPromedio(String userID) async {
    List<TicketsPromedio> listTickets = [];
    final url1 = Uri.http(urlapi, '/api/Dashboard/ticketsPromedio',{"userID": userID});
    const int maxAttempts = 3; // Número máximo de intentos
    int attempts = 0;
    while (attempts < maxAttempts) {
      print('Intento $attempts');
      try {
        final response = await http.get(url1, headers: {
          "Access-Control-Allow-Origin": "*",
          "Access-Control-Allow-Credentials": "true",
          'Content-type': 'application/json',
          'Accept': 'application/json'
        });

        if (response.statusCode == 200) {
          listTickets = ticketsPromedioFromJson(response.body);
          return listTickets;
        } else {
          print('*Error en la solicitud*: ${response.statusCode}');
          attempts++;
          if (attempts >= maxAttempts) {
            return listTickets;
          }
        }
      } catch (e) {
        print('Error al enviar la solicitud: $e');
        attempts++;
        if (attempts >= maxAttempts) {
          return listTickets;
        }
      }
      await Future.delayed(const Duration(seconds: waitTime1));
    }
    return listTickets;
  }
}