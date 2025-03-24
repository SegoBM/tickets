import '../../../models/TicketsModels/ticket.dart';
import 'package:intl/intl.dart';
import '../../Data_provider/Tickets/TicketsRecibidosAdmin_data_provider.dart';

class TicketsRecibidosAdminRepository {
  final TicketsRecibidosAdminProvider ticketsRecibidosAdminDataProvider;
  TicketsRecibidosAdminRepository(this.ticketsRecibidosAdminDataProvider);

  Future<List<TicketsModels>> getTicketsRecibidosAdmin(
      String startDate, String endDate, String idDepartamento) async {
    DateFormat dateFormat = DateFormat("yyyy-MM-dd");
    DateTime StartDate = dateFormat.parse(startDate);
    DateTime EndDate = dateFormat.parse(endDate);

    try {
      List<TicketsModels> listTickets = [];
      final url1 = Uri.http(urlapi, '/api/Tickets/TicketsRecibidosAdministrador', {"startDate": StartDate.toString(), "endDate": EndDate.toString(), "idDepartmento": idDepartamento});
      const int maxAttempts = 3;
      int attempts = 0;
      while (attempts < maxAttempts) {
        print('Intento $attempts');
        final response = await ticketsRecibidosAdminDataProvider.getTicketsRecibidosAdmin(url1);

        if (response != null) {
          print("hay datos");
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
        } else {
          attempts++;
          if (attempts >= maxAttempts) {
            return listTickets;
          }
        }
        await Future.delayed(const Duration(seconds: waitTime1));
      }
      return listTickets;
    } catch (e) {
      print(e);
      return [];
    }
  }
}
