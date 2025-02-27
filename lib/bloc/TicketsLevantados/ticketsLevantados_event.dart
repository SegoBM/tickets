part of 'ticketsLevantados_bloc.dart';
sealed class TicketsEventLevantados {}

final class TicketsFetched extends TicketsEventLevantados {}


class TicketsFetchedByDateRange extends TicketsEventLevantados {
  final DateTime startDate;
  final DateTime endDate;

  TicketsFetchedByDateRange({required this.startDate, required this.endDate});
}