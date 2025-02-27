part of 'ticketsRecibidosAdmin_bloc.dart';


sealed class TicketsStateRecibidosAdmin{}

final class TicketsInitial extends TicketsStateRecibidosAdmin{}

final class TicketsLoading extends TicketsStateRecibidosAdmin{}

final class TicketsSuccess extends TicketsStateRecibidosAdmin{
  final List<TicketsModels> tickets;
  TicketsSuccess({required this.tickets});
}

final class TicketsFailure extends TicketsStateRecibidosAdmin{
  final String message;
  TicketsFailure({required this.message});
}
