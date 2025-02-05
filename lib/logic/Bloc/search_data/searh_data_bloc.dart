import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:save_earth/data/model/item_model.dart';
import 'package:save_earth/repositores/item_repository.dart';

part 'searh_data_event.dart';
part 'searh_data_state.dart';



class SearchDataBloc extends Bloc<SearchDataEvent, SearchDataState> {
  final ItemRepository repository;

  SearchDataBloc(this.repository) : super(SearchItemInitial()) {
    on<SearchItems>((event, emit) async {
      emit(SearchItemLoading());
      try {
        final items = await repository.searchItems(
          name: event.name,
          latitude: event.latitude,
          longitude: event.longitude,
        );
        emit(SearchItemListLoaded(items));
      } catch (e) {
        emit(SearchItemError("Failed to search items"));
      }
    });

    // on<GetItemsByCategory>((event, emit) async {
    //   emit(SearchItemLoading());
    //   try {
    //     final items = await repository.getItemsByCategory(event.categoryName);
    //     emit(SearchItemListLoaded(items));
    //   } catch (e) {
    //     print("error: $e");
    //     emit(SearchItemError("Failed to load items by category"));
    //   }
    // });

    on<GetItemsByCategory>((event, emit) async {
      emit(SearchItemLoading());
      try {
        final items = await repository.getItemsByCategory(
          category: event.category,
          latitude: event.latitude,
          longitude: event.longitude,
        );
        print("get cate success");
        emit(SearchItemListLoaded(items));
      } catch (e) {
        emit(SearchItemError("Failed to load items by category"));
      }
    });

  }

}
