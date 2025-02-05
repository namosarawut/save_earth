part of 'create_request_bloc.dart';

abstract class CreateRequestState {}

class CreateRequestInitial extends CreateRequestState {}

class CreateRequestLoading extends CreateRequestState {}

class CreateRequestSuccess extends CreateRequestState {
  final String message;
  CreateRequestSuccess(this.message);
}

class CreateRequestError extends CreateRequestState {
  final String message;
  CreateRequestError(this.message);
}

