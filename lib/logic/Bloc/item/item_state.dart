part of 'item_bloc.dart';

abstract class ItemState {}

class ItemInitial extends ItemState {}

class ItemLoading extends ItemState {}

class ItemNamesLoaded extends ItemState {
  final List<String> itemNames;
  ItemNamesLoaded(this.itemNames);
}

class ItemError extends ItemState {
  final String message;
  ItemError(this.message);
}


class ItemListLoaded extends ItemState {
  final List<ItemModel> items;
  ItemListLoaded(this.items);
}


