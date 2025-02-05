part of 'get_my_item_list_bloc.dart';


abstract class GetMyItemListState {}

class GetMyItemListInitial extends GetMyItemListState {}

class GetMyItemListLoading extends GetMyItemListState {}

class GetMyItemListLoaded extends GetMyItemListState {
  final List<ItemListModel> items;
  GetMyItemListLoaded(this.items);
}

class GetMyItemListError extends GetMyItemListState {
  final String message;
  GetMyItemListError(this.message);
}
