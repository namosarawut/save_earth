part of 'delete_my_request_bloc.dart';

abstract class DeleteMyRequestState {}

class DeleteMyRequestInitial extends DeleteMyRequestState {}

class DeleteMyRequestLoading extends DeleteMyRequestState {}

class DeleteMyRequestSuccess extends DeleteMyRequestState {
  final String message;
  DeleteMyRequestSuccess(this.message);
}

class DeleteMyRequestError extends DeleteMyRequestState {
  final String message;
  DeleteMyRequestError(this.message);
}

