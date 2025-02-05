import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:save_earth/repositores/request_repository.dart';

part 'delete_my_request_event.dart';
part 'delete_my_request_state.dart';

class DeleteMyRequestBloc extends Bloc<DeleteMyRequestEvent, DeleteMyRequestState> {
  final RequestRepository repository;

  DeleteMyRequestBloc(this.repository) : super(DeleteMyRequestInitial()) {
    on<DeleteRequestById>((event, emit) async {
      emit(DeleteMyRequestLoading());
      try {
        final message = await repository.deleteMyRequest(event.requestId);
        emit(DeleteMyRequestSuccess(message));
      } catch (e) {
        emit(DeleteMyRequestError("Failed to delete request"));
      }
    });
  }
}
