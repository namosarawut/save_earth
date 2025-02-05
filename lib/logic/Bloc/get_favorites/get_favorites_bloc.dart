import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:save_earth/data/model/favorite_model.dart';
import 'package:save_earth/repositores/item_repository.dart';

part 'get_favorites_event.dart';
part 'get_favorites_state.dart';




class GetFavoritesBloc extends Bloc<GetFavoritesEvent, GetFavoritesState> {
  final ItemRepository repository;

  GetFavoritesBloc(this.repository) : super(GetFavoritesInitial()) {
    on<FetchFavoritesByUserId>((event, emit) async {
      emit(GetFavoritesLoading());
      try {
        final favorites = await repository.getFavoritesByUserId(event.userId);
        emit(GetFavoritesLoaded(favorites));
      } catch (e) {
        emit(GetFavoritesError("Failed to load favorites"));
      }
    });
  }
}

