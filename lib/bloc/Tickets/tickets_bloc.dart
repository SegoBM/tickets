import 'package:flutter_bloc/flutter_bloc.dart';
import '../../Data/Repository/Tickets/ticketsRecibidos_repository.dart';
import '../../controllers/TicketController/departamentController.dart';
import '../../models/TicketsModels/ticket.dart';
import '../../shared/utils/user_preferences.dart';


part 'tickets_event.dart';
part 'tickets_state.dart';

class TicketsBloc extends Bloc<TicketsEvent, TicketsState>{
  UserPreferences userPreferences = UserPreferences();
  DateTime today = DateTime.now();


  final ticketsRecibidosRepository ticketsRepository;
  TicketsBloc(this.ticketsRepository) : super(TicketsInitial()){
    on<TicketsFetched>((_getTicketsRecibidos));

  }
  void _getTicketsRecibidos(TicketsFetched event, Emitter<TicketsState> emit,) async {
    DateTime before = today.subtract(const Duration(days: 5));
    DateTime after = today.add(const Duration(days: 1));
    final departamentoController = departamentController();
    String idUsuario = await userPreferences.getUsuarioID();
    String? idPuesto = await userPreferences.getPuestoID();
    String idDepartamento =  await departamentoController.getPuesto(idPuesto!);


    emit(TicketsLoading());
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
}