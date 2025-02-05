part of 'get_my_requests_bloc.dart';



abstract class GetMyRequestsState {}

class GetMyRequestsInitial extends GetMyRequestsState {}

class GetMyRequestsLoading extends GetMyRequestsState {}

class GetMyRequestsLoaded extends GetMyRequestsState {
  final List<RequestModel> requests;
  GetMyRequestsLoaded(this.requests);
}

class GetMyRequestsError extends GetMyRequestsState {
  final String message;
  GetMyRequestsError(this.message);
}

