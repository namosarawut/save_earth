part of 'delete_my_item_bloc.dart';

abstract class DeleteMyItemEvent {}

class DeleteItemById extends DeleteMyItemEvent {
  final int itemId;
  DeleteItemById(this.itemId);
}

