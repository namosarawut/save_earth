import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:save_earth/repositores/request_repository.dart';

part 'create_request_event.dart';
part 'create_request_state.dart';




class CreateRequestBloc extends Bloc<CreateRequestEvent, CreateRequestState> {
  final RequestRepository repository;

  CreateRequestBloc(this.repository) : super(CreateRequestInitial()) {
    on<SubmitRequest>((event, emit) async {
      emit(CreateRequestLoading());
      try {
        final message = await repository.createRequest(
          itemId: event.itemId,
          userId: event.userId,
          reason: event.reason,
        );
        emit(CreateRequestSuccess(message));
      } catch (e) {
        emit(CreateRequestError("Failed to submit request"));
      }
    });
  }
}

