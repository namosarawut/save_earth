import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:save_earth/repositores/item_repository.dart';

part 'create_item_event_event.dart';
part 'create_item_event_state.dart';




class CreateItemBloc extends Bloc<CreateItemEvent, CreateItemState> {
  final ItemRepository repository;

  CreateItemBloc(this.repository) : super(CreateItemInitial()) {
    on<CreateItem>((event, emit) async {
      emit(CreateItemLoading());
      try {
        final message = await repository.createItem(
          name: event.name,
          category: event.category,
          description: event.description,
          latitude: event.latitude,
          longitude: event.longitude,
          posterUserId: event.posterUserId,
          image: event.image,
        );
        emit(CreateItemSuccess(message));
      } catch (e) {
        emit(CreateItemFailure("Failed to create item"));
      }
    });
  }
}

