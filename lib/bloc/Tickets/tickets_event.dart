part of 'tickets_bloc.dart';
sealed class TicketsEvent {}

final class TicketsFetched extends TicketsEvent {}

class TicketsFetchedByDateRange extends TicketsEvent {
  final DateTime startDate;
  final DateTime endDate;

  TicketsFetchedByDateRange({required this.startDate, required this.endDate});
}