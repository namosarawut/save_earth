import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:save_earth/data/model/item_model.dart';
import 'package:save_earth/repositores/item_repository.dart';

part 'item_event.dart';
part 'item_state.dart';




class ItemBloc extends Bloc<ItemEvent, ItemState> {
  final ItemRepository repository;

  ItemBloc(this.repository) : super(ItemInitial()) {
    on<LoadUniqueItemNames>((event, emit) async {
      emit(ItemLoading());
      try {
        final itemNames = await repository.getUniqueItemNames();
        emit(ItemNamesLoaded(itemNames));
      } catch (e) {
        emit(ItemError("Failed to load item names"));
      }
    });




  }


}
