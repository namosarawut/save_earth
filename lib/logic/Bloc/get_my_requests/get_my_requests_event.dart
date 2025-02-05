part of 'get_my_requests_bloc.dart';

abstract class GetMyRequestsEvent {}

class FetchMyRequests extends GetMyRequestsEvent {
  final int userId;
  FetchMyRequests(this.userId);
}

