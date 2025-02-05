part of 'searh_data_bloc.dart';

abstract class SearchDataState {}
class SearchItemInitial extends SearchDataState {}

class SearchItemLoading extends SearchDataState {}

class SearchItemError extends SearchDataState {
  final String message;

  SearchItemError(this.message);
}
class SearchItemListLoaded extends SearchDataState {
  final List<ItemModel> items;
  SearchItemListLoaded(this.items);
}

