part of 'approve_request_bloc.dart';

abstract class ApproveRequestEvent {}

class ApproveRequestById extends ApproveRequestEvent {
  final int itemId;
  final int requestId;

  ApproveRequestById({required this.itemId, required this.requestId});
}

