

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tickets/bloc/Tickets/tickets_bloc.dart';

import '../Data/Data_provider/Tickets/ticketsRecibidos_data_provider.dart';
import '../Data/Repository/Tickets/ticketsRecibidos_repository.dart';

class AppProviders{
  static List<BlocProvider> getProviders(){
    return[
      BlocProvider<TicketsBloc>(create: (context) => TicketsBloc(ticketsRecibidosRepository(TicketsAsignadosProvider())),),
    ];

  }
}