part of 'get_my_item_list_bloc.dart';

abstract class GetMyItemListEvent {}

class FetchMyItems extends GetMyItemListEvent {
  final int userId;
  FetchMyItems(this.userId);
}

