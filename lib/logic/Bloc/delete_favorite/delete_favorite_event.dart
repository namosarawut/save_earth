part of 'delete_favorite_bloc.dart';

abstract class DeleteFavoriteEvent {}

class DeleteFavoriteItem extends DeleteFavoriteEvent {
  final int userId;
  final int itemId;

  DeleteFavoriteItem({required this.userId, required this.itemId});
}

