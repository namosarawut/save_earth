part of 'delete_my_item_bloc.dart';

abstract class DeleteMyItemState {}

class DeleteMyItemInitial extends DeleteMyItemState {}

class DeleteMyItemLoading extends DeleteMyItemState {}

class DeleteMyItemSuccess extends DeleteMyItemState {
  final String message;
  DeleteMyItemSuccess(this.message);
}

class DeleteMyItemError extends DeleteMyItemState {
  final String message;
  DeleteMyItemError(this.message);
}
