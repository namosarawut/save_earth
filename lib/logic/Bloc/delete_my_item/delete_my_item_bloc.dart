import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:save_earth/repositores/item_repository.dart';

part 'delete_my_item_event.dart';
part 'delete_my_item_state.dart';






class DeleteMyItemBloc extends Bloc<DeleteMyItemEvent, DeleteMyItemState> {
  final ItemRepository repository;

  DeleteMyItemBloc(this.repository) : super(DeleteMyItemInitial()) {
    on<DeleteItemById>((event, emit) async {
      emit(DeleteMyItemLoading());
      try {
        final message = await repository.deleteItemById(event.itemId);
        emit(DeleteMyItemSuccess(message));
      } catch (e) {
        emit(DeleteMyItemError("Failed to delete item"));
      }
    });
  }
}
