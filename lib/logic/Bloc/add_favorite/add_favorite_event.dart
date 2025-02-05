part of 'add_favorite_bloc.dart';

abstract class AddFavoriteEvent {}

class AddFavoriteItem extends AddFavoriteEvent {
  final int userId;
  final int itemId;

  AddFavoriteItem({required this.userId, required this.itemId});
}

