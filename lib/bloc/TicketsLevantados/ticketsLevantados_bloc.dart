import 'package:flutter_bloc/flutter_bloc.dart';
import '../../Data/Repository/Tickets/ticketsLevantados_repository.dart';
import '../../Data/Repository/Tickets/ticketsRecibidos_repository.dart';
import '../../controllers/TicketController/departamentController.dart';
import '../../models/TicketsModels/ticket.dart';
import '../../shared/utils/user_preferences.dart';

part 'ticketsLevantados_event.dart';
part 'ticketsLevantados_state.dart';

class TicketsLevantadosBloc extends Bloc<TicketsEventLevantados, TicketsStateLevantados>{
  UserPreferences userPreferences = UserPreferences();
  DateTime today = DateTime.now();


  final TicketsLevantadosRepository ticketsRepository;
  TicketsLevantadosBloc(this.ticketsRepository) : super(TicketsInitial()){
    on<TicketsFetched>((_getTicketsRecibidos));
    on<TicketsFetchedByDateRange>(_onTicketsFetchedByDateRange);
  }
  void _getTicketsRecibidos(TicketsFetched event, Emitter<TicketsStateLevantados> emit,) async {
    emit(TicketsLoading());
    DateTime before = today.subtract(const Duration(days: 10));
    DateTime after = today.add(const Duration(days: 1));
    final departamentoController = departamentController();
    String idUsuario = await userPreferences.getUsuarioID();
    String? idPuesto = await userPreferences.getPuestoID();
    String idDepartamento =  await departamentoController.getPuesto(idPuesto!);

    try{
      final ticketsRecibidos = await ticketsRepository.getTicketsLevantados(   "${before.year}-${before.month}-${before.day}",
          "${after.year}-${after.month}-${after.day},", idUsuario,idDepartamento);
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
      TicketsFetchedByDateRange event, Emitter<TicketsStateLevantados> emit) async {
    try {
      emit(TicketsLoading());

      String idUsuario = await userPreferences.getUsuarioID();
      String? idPuesto = await userPreferences.getPuestoID();
      final departamentoController = departamentController();
      String idDepartamento =  await departamentoController.getPuesto(idPuesto!);
      final tickets = await ticketsRepository.getTicketsLevantados(
          "${event.startDate}",
          "${event.endDate}",
          idUsuario,idDepartamento
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