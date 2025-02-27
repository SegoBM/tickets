part of 'ticketsLevantados_bloc.dart';


sealed class TicketsStateLevantados{}

final class TicketsInitial extends TicketsStateLevantados{}

final class TicketsLoading extends TicketsStateLevantados{}

final class TicketsSuccess extends TicketsStateLevantados{
  final List<TicketsModels> tickets;
  TicketsSuccess({required this.tickets});
}

final class TicketsFailure extends TicketsStateLevantados{
  final String message;
  TicketsFailure({required this.message});
}
