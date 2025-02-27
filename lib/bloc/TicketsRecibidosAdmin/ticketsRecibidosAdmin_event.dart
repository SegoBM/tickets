part of 'ticketsRecibidosAdmin_bloc.dart';
sealed class TicketsEventAdmin {}

final class TicketsFetched extends TicketsEventAdmin {}


class TicketsFetchedByDateRange extends TicketsEventAdmin {
  final DateTime startDate;
  final DateTime endDate;

  TicketsFetchedByDateRange({required this.startDate, required this.endDate});
}