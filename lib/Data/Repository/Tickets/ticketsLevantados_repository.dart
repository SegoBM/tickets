import '../../../models/TicketsModels/ticket.dart';
import '../../Data_provider/Tickets/ticketsLevantados_data_provider.dart';
import 'package:intl/intl.dart';

class TicketsLevantadosRepository{
  final TicketsLevantadosProvider ticketsLevantadosDataProvider;
  TicketsLevantadosRepository(this.ticketsLevantadosDataProvider);

  Future<List<TicketsModels>> getTicketsLevantados(
      String startDate, String endDate, String idUsuario,String idDepartamento) async {
    DateFormat dateFormat = DateFormat("yyyy-MM-dd");
    DateTime StartDate = dateFormat.parse(startDate);
    DateTime EndDate = dateFormat.parse(endDate);
    print(StartDate);
    print(EndDate);

    try {
      List<TicketsModels> listTickets = [];
      final url1 = Uri.http(urlapi, '/api/Tickets/TicketsAsignados', {"startDate": StartDate.toString(), "endDate": EndDate.toString(), "idUsuario": idUsuario, "idDepartmento": idDepartamento});
      const int maxAttempts = 3;
      int attempts = 0;
      while (attempts < maxAttempts) {
        print('Intento $attempts');
        final response = await ticketsLevantadosDataProvider.getTicketsLevantados(url1);
        print("aqui");
      print(url1);
        if (response != null) {
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
