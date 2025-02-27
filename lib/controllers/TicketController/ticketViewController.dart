import 'package:tickets/models/ConfigModels/userSession.dart';
import 'package:tickets/models/TicketsModels/ticketsReportModel.dart';
import 'package:tickets/shared/utils/constants.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;

import '../../models/TicketsModels/ticket.dart';
import '../../shared/utils/user_preferences.dart';

const urlapi= url;
const waitTime1 = waitTime;

class TicketViewController with ChangeNotifier {
  TicketViewController() {}

  Future<List<TicketsModels>> getTicketsAsignados(String startDate, String endDate, String idUsuario) async {
    List<TicketsModels> listTickets = [];
    final url1 = Uri.http(urlapi, '/api/Tickets/TicketsAsignados',{"startDate": startDate, "endDate": endDate,"idUsuario":idUsuario});
    const int maxAttempts = 3; // Número máximo de intentos
    int attempts = 0;
    while (attempts < maxAttempts) {
      print('Intento $attempts');
      try {
        String? token = await UserSession().getToken();
        final response = await http.get(url1, headers: {
          "Access-Control-Allow-Origin": "*",
          "Access-Control-Allow-Credentials": "true",
          'Content-type': 'application/json',
          'Accept': 'application/json',
        });

        if (response.statusCode == 200) {
          print(token);
          listTickets = ticketsModelsFromJson(response.body);
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

  Future<List<TicketsModels>> getTicketsRecibidos(String startDate, String endDate, String idUsuario,String idDepartamento) async {
    List<TicketsModels> listTickets = [];
    final url1 = Uri.http(urlapi, '/api/Tickets/TicketsRecibidos', {"startDate": startDate, "endDate": endDate, "idUsuario": idUsuario, "idDepartmento": idDepartamento});
    const int maxAttempts = 3; // Número máximo de intentos
    int attempts = 0;

    while (attempts < maxAttempts) {
      print('Intento $attempts');
      try {
        String? token = await UserSession().getToken();
        final response = await http.get(url1, headers: {
          "Access-Control-Allow-Origin": "*",
          "Access-Control-Allow-Credentials": "true",
          'Content-type': 'application/json',
          'Accept': 'application/json',

        });

        if (response.statusCode == 200) {
          listTickets = ticketsModelsFromJson(response.body);
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
      print("final");
    }
    return listTickets;
  }

  Future<List<TicketsModels>> getTicketsRecibidosReport(String startDateReport, String endDateReport, String idUsuario,String idDepartamento) async {
    List<TicketsModels> listTickets = [];
    print(idUsuario);
    final url1 = Uri.http(urlapi, '/api/Tickets/TicketsRecibidos',{"startDate": startDateReport, "endDate": endDateReport, "idUsuario":idUsuario,"idDepartmento":idDepartamento});
    const int maxAttempts = 3; // Número máximo de intentos
    int attempts = 0;

    while (attempts < maxAttempts) {
      try {
        String? token = await UserSession().getToken();
        final response = await http.get(url1, headers: {
          "Access-Control-Allow-Origin": "*",
          "Access-Control-Allow-Credentials": "true",
          'Content-type': 'application/json',
          'Accept': 'application/json',

        });

        if (response.statusCode == 200) {
          listTickets = ticketsModelsFromJson(response.body);
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

  Future<List<TicketsReportModel>> getTicketsRecibidosReportAdmin(String startDateReport, String endDateReport, String? idUsuario,String? idDepartamento) async {
    List<TicketsReportModel> listTickets = [];
    final url1 = Uri.http(urlapi, '/api/Tickets/TicketsReporte',{"startDate": startDateReport.split(" ")[0], "endDate": endDateReport.split(" ")[0], "idUsuario":"","idDepartmento":idDepartamento});
    const int maxAttempts = 3; // Número máximo de intentos
    int attempts = 0;

    while (attempts < maxAttempts) {
      try {
        String? token = await UserSession().getToken();
        final response = await http.get(url1, headers: {
          "Access-Control-Allow-Origin": "*",
          "Access-Control-Allow-Credentials": "true",
          'Content-type': 'application/json',
          'Accept': 'application/json',

        });

        if (response.statusCode == 200) {
          listTickets = ticketsReportModelsFromJson(response.body);
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
      await Future.delayed(const Duration(milliseconds: 400));
    }
    return listTickets;
  }

  Future<List<TicketsReportModel>> getTicketsRecibidosReportUser(String startDateReport, String endDateReport, String? idUsuario,String? idDepartamento) async {
    print(startDateReport);
    print(endDateReport);
    print(idUsuario);
    print(idDepartamento);
    List<TicketsReportModel> listTickets = [];
    final url1 = Uri.http(urlapi, '/api/Tickets/TicketsReporte',{"startDate": startDateReport.split(" ")[0], "endDate": endDateReport.split(" ")[0], "idUsuario":idUsuario,"idDepartmento":idDepartamento});
    const int maxAttempts = 3; // Número máximo de intentos
    int attempts = 0;

    while (attempts < maxAttempts) {
      try {
        String? token = await UserSession().getToken();
        final response = await http.get(url1, headers: {
          "Access-Control-Allow-Origin": "*",
          "Access-Control-Allow-Credentials": "true",
          'Content-type': 'application/json',
          'Accept': 'application/json',
        });

        if (response.statusCode == 200) {
          listTickets = ticketsReportModelsFromJson(response.body);
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
      await Future.delayed(const Duration(milliseconds: 400));
    }
    return listTickets;
  }


  Future<List<TicketsModels>> getTicketsRecibidosAdmin(String startDateReport, String endDateReport, String idDepartamento) async {
    List<TicketsModels> listTickets = [];
    final url1 = Uri.http(urlapi, '/api/Tickets/TicketsRecibidosAdministrador',{"startDate": startDateReport, "endDate": endDateReport, "idDepartmento":idDepartamento});
    const int maxAttempts = 3; // Número máximo de intentos
    int attempts = 0;

    while (attempts < maxAttempts) {
      try {
        String? token = await UserSession().getToken();
        final response = await http.get(url1, headers: {
          "Access-Control-Allow-Origin": "*",
          "Access-Control-Allow-Credentials": "true",
          'Content-type': 'application/json',
          'Accept': 'application/json',

        });

        if (response.statusCode == 200) {
          listTickets = ticketsModelsFromJson(response.body);
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
      await Future.delayed(const Duration(milliseconds: 400));
    }
    return listTickets;
  }
}
