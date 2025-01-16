part of 'tickets_bloc.dart';


sealed class TicketsState{}

final class TicketsInitial extends TicketsState{}

final class TicketsLoading extends TicketsState{}

final class TicketsSuccess extends TicketsState{
   final List<TicketsModels> tickets;
   TicketsSuccess({required this.tickets});
}

final class TicketsFailure extends TicketsState{
  final String message;
  TicketsFailure({required this.message});
}
