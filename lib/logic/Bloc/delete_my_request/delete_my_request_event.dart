part of 'delete_my_request_bloc.dart';

abstract class DeleteMyRequestEvent {}

class DeleteRequestById extends DeleteMyRequestEvent {
  final int requestId;
  DeleteRequestById(this.requestId);
}

