part of 'add_favorite_bloc.dart';

abstract class AddFavoriteState {}

class AddFavoriteInitial extends AddFavoriteState {}

class AddFavoriteLoading extends AddFavoriteState {}

class AddFavoriteSuccess extends AddFavoriteState {
  final String message;
  AddFavoriteSuccess(this.message);
}

class AddFavoriteError extends AddFavoriteState {
  final String message;
  AddFavoriteError(this.message);
}

