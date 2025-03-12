import 'package:flutter_bloc/flutter_bloc.dart';
import '../../Data/Repository/Tickets/ticketsRecibidos_repository.dart';
import '../../controllers/TicketController/departamentController.dart';
import '../../models/TicketsModels/ticket.dart';
import '../../shared/utils/user_preferences.dart';


part 'ticketsRecibidos_event.dart';
part 'ticketsRecibidos_state.dart';

class TicketsBloc extends Bloc<TicketsEvent, TicketsState>{
  UserPreferences userPreferences = UserPreferences();
  DateTime today = DateTime.now();


  final TicketsRecibidosRepository ticketsRepository;
  TicketsBloc(this.ticketsRepository) : super(TicketsInitial()){
    on<TicketsFetched>((_getTicketsRecibidos));
    on<TicketsFetchedByDateRange>(_onTicketsFetchedByDateRange);
  }
  void _getTicketsRecibidos(TicketsFetched event, Emitter<TicketsState> emit,) async {
    emit(TicketsLoading());
    DateTime before = today.subtract(const Duration(days: 10));
    DateTime after = today.add(const Duration(days: 1));
    final departamentoController = departamentController();
    String idUsuario = await userPreferences.getUsuarioID();
    String? idPuesto = await userPreferences.getPuestoID();
    String idDepartamento =  await departamentoController.getPuesto(idPuesto!);

    try{
      final ticketsRecibidos = await ticketsRepository.getTicketsAsignados(   "${before.year}-${before.month}-${before.day}",
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
      TicketsFetchedByDateRange event, Emitter<TicketsState> emit) async {
    try {
      emit(TicketsLoading());

      String idUsuario = await userPreferences.getUsuarioID();
      String? idPuesto = await userPreferences.getPuestoID();
      final departamentoController = departamentController();
      String idDepartamento =  await departamentoController.getPuesto(idPuesto!);
      final tickets = await ticketsRepository.getTicketsAsignados(
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