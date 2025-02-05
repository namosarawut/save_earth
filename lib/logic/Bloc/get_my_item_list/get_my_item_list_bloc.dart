import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:save_earth/data/model/my_item_list_model.dart';
import 'package:save_earth/repositores/item_repository.dart';

part 'get_my_item_list_event.dart';
part 'get_my_item_list_state.dart';

class GetMyItemListBloc extends Bloc<GetMyItemListEvent, GetMyItemListState> {
  final ItemRepository repository;

  GetMyItemListBloc(this.repository) : super(GetMyItemListInitial()) {
    on<FetchMyItems>((event, emit) async {
      emit(GetMyItemListLoading());
      try {
        final items = await repository.getItemsByUserId(event.userId);
        emit(GetMyItemListLoaded(items));
      } catch (e) {
        emit(GetMyItemListError("Failed to load items"));
      }
    });
  }
}