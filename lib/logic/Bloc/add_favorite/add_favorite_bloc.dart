import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:save_earth/repositores/item_repository.dart';
part 'add_favorite_event.dart';
part 'add_favorite_state.dart';

class AddFavoriteBloc extends Bloc<AddFavoriteEvent, AddFavoriteState> {
  final ItemRepository repository;

  AddFavoriteBloc(this.repository) : super(AddFavoriteInitial()) {
    on<AddFavoriteItem>((event, emit) async {
      emit(AddFavoriteLoading());
      try {
        final message = await repository.addFavorite(
          userId: event.userId,
          itemId: event.itemId,
        );
        emit(AddFavoriteSuccess(message));
      } catch (e) {
        emit(AddFavoriteError("Failed to add item to favorites"));
      }
    });
  }
}

