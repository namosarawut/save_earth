part of 'create_item_event_bloc.dart';

abstract class CreateItemState {}

class CreateItemInitial extends CreateItemState {}

class CreateItemLoading extends CreateItemState {}

class CreateItemSuccess extends CreateItemState {
  final String message;
  CreateItemSuccess(this.message);
}

class CreateItemFailure extends CreateItemState {
  final String error;
  CreateItemFailure(this.error);
}

