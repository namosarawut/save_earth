part of 'get_favorites_bloc.dart';

abstract class GetFavoritesEvent {}

class FetchFavoritesByUserId extends GetFavoritesEvent {
  final int userId;
  FetchFavoritesByUserId(this.userId);
}

