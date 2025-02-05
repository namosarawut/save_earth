part of 'create_request_bloc.dart';

abstract class CreateRequestEvent {}

class SubmitRequest extends CreateRequestEvent {
  final int itemId;
  final int userId;
  final String reason;

  SubmitRequest({
    required this.itemId,
    required this.userId,
    required this.reason,
  });
}

