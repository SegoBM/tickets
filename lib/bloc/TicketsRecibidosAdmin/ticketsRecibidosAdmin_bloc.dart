import 'package:flutter_bloc/flutter_bloc.dart';

import '../../Data/Repository/Tickets/ticketsRecibidosAdmin_repository.dart';
import '../../controllers/TicketController/departamentController.dart';
import '../../models/TicketsModels/ticket.dart';
import '../../shared/utils/user_preferences.dart';


part 'ticketsRecibidosAdmin_event.dart';
part 'ticketsRecibidosAdmin_state.dart';

class TicketsBlocRecibidosAdmin extends Bloc<TicketsEventAdmin, TicketsStateRecibidosAdmin>{
  UserPreferences userPreferences = UserPreferences();
  DateTime today = DateTime.now();


  final TicketsRecibidosAdminRepository ticketsRecibidosAdminRepository;
  TicketsBlocRecibidosAdmin(this.ticketsRecibidosAdminRepository) : super(TicketsInitial()){
    on<TicketsFetched>((_getTicketsRecibidosAdmin));
    on<TicketsFetchedByDateRange>(_onTicketsFetchedByDateRange);
  }
  void _getTicketsRecibidosAdmin(TicketsFetched event, Emitter<TicketsStateRecibidosAdmin> emit,) async {
    emit(TicketsLoading());
    DateTime before = today.subtract(const Duration(days: 5));
    DateTime after = today.add(const Duration(days: 1));
    final departamentoController = departamentController();
    String idUsuario = await userPreferences.getUsuarioID();
    String? idPuesto = await userPreferences.getPuestoID();
    String idDepartamento =  await departamentoController.getPuesto(idPuesto!);

    try{
      final ticketsRecibidos = await ticketsRecibidosAdminRepository.getTicketsRecibidosAdmin(   "${before.year}-${before.month}-${before.day}",
          "${after.year}-${after.month}-${after.day},",idDepartamento);
      if(ticketsRecibidos.isEmpty){
        print('Descarga fallidad');
        emit(TicketsFailure(message: 'No users found'));
      }else{
        emit(TicketsSuccess( tickets: ticketsRecibidos));
      }
    }catch(e){
      emit(TicketsFailure(message: e.toString()));
    }
  }
  Future<void> _onTicketsFetchedByDateRange(
      TicketsFetchedByDateRange event, Emitter<TicketsStateRecibidosAdmin> emit) async {
    try {
      emit(TicketsLoading());

      String? idPuesto = await userPreferences.getPuestoID();
      final departamentoController = departamentController();
      String idDepartamento =  await departamentoController.getPuesto(idPuesto!);
      final tickets = await ticketsRecibidosAdminRepository.getTicketsRecibidosAdmin(
          "${event.startDate}",
          "${event.endDate}",
            idDepartamento
      );
      if (tickets.isEmpty) {
        emit(TicketsFailure(message: 'No tickets found'));
      }
      emit(TicketsSuccess(tickets: tickets));
    } catch (error) {
      emit(TicketsFailure(message: error.toString()));
    }
  }
}