part of 'approve_request_bloc.dart';

abstract class ApproveRequestState {}

class ApproveRequestInitial extends ApproveRequestState {}

class ApproveRequestLoading extends ApproveRequestState {}

class ApproveRequestSuccess extends ApproveRequestState {
  final String message;
  ApproveRequestSuccess(this.message);
}

class ApproveRequestError extends ApproveRequestState {
  final String message;
  ApproveRequestError(this.message);
}

