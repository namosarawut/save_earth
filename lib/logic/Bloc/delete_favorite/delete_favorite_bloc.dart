import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:save_earth/repositores/item_repository.dart';

part 'delete_favorite_event.dart';
part 'delete_favorite_state.dart';




class DeleteFavoriteBloc extends Bloc<DeleteFavoriteEvent, DeleteFavoriteState> {
  final ItemRepository repository;

  DeleteFavoriteBloc(this.repository) : super(DeleteFavoriteInitial()) {
    on<DeleteFavoriteItem>((event, emit) async {
      emit(DeleteFavoriteLoading());
      try {
        final message = await repository.deleteFavorite(
          userId: event.userId,
          itemId: event.itemId,
        );
        emit(DeleteFavoriteSuccess(message));
      } catch (e) {
        emit(DeleteFavoriteError("Failed to remove item from favorites"));
      }
    });
  }
}

