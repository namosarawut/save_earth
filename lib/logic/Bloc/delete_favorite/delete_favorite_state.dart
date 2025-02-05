part of 'delete_favorite_bloc.dart';

abstract class DeleteFavoriteState {}

class DeleteFavoriteInitial extends DeleteFavoriteState {}

class DeleteFavoriteLoading extends DeleteFavoriteState {}

class DeleteFavoriteSuccess extends DeleteFavoriteState {
  final String message;
  DeleteFavoriteSuccess(this.message);
}

class DeleteFavoriteError extends DeleteFavoriteState {
  final String message;
  DeleteFavoriteError(this.message);
}
