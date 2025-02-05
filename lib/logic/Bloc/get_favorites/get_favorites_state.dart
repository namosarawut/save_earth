part of 'get_favorites_bloc.dart';



abstract class GetFavoritesState {}

class GetFavoritesInitial extends GetFavoritesState {}

class GetFavoritesLoading extends GetFavoritesState {}

class GetFavoritesLoaded extends GetFavoritesState {
  final List<FavoriteModel> favorites;
  GetFavoritesLoaded(this.favorites);
}

class GetFavoritesError extends GetFavoritesState {
  final String message;
  GetFavoritesError(this.message);
}

