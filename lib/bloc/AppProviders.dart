

import 'package:flutter_bloc/flutter_bloc.dart';
import '../Data/Data_provider/Tickets/TicketsRecibidosAdmin_data_provider.dart';
import '../Data/Data_provider/Tickets/ticketsLevantados_data_provider.dart';
import '../Data/Data_provider/Tickets/ticketsRecibidos_data_provider.dart';
import '../Data/Repository/Tickets/ticketsLevantados_repository.dart';
import '../Data/Repository/Tickets/ticketsRecibidosAdmin_repository.dart';
import '../Data/Repository/Tickets/ticketsRecibidos_repository.dart';
import 'Tickets Recibidos/ticketsRecibidos_bloc.dart';
import 'TicketsLevantados/ticketsLevantados_bloc.dart';
import 'TicketsRecibidosAdmin/ticketsRecibidosAdmin_bloc.dart';

class AppProviders{
  static List<BlocProvider> getProviders(){
    return[
      BlocProvider<TicketsBloc>(create: (context) => TicketsBloc(TicketsRecibidosRepository(TicketsAsignadosProvider())),),
      BlocProvider<TicketsLevantadosBloc>(create: (context) => TicketsLevantadosBloc(TicketsLevantadosRepository(TicketsLevantadosProvider())),),
      BlocProvider<TicketsBlocRecibidosAdmin>(create: (context) => TicketsBlocRecibidosAdmin(TicketsRecibidosAdminRepository(TicketsRecibidosAdminProvider())),),

    ];

  }
}