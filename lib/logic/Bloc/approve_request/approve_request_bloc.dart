import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:save_earth/repositores/request_repository.dart';

part 'approve_request_event.dart';
part 'approve_request_state.dart';

class ApproveRequestBloc extends Bloc<ApproveRequestEvent, ApproveRequestState> {
  final RequestRepository repository;

  ApproveRequestBloc(this.repository) : super(ApproveRequestInitial()) {
    on<ApproveRequestById>((event, emit) async {
      emit(ApproveRequestLoading());
      try {
        final message = await repository.approveRequest(
          itemId: event.itemId,
          requestId: event.requestId,
        );
        emit(ApproveRequestSuccess(message));
      } catch (e) {
        emit(ApproveRequestError("Failed to approve request"));
      }
    });
  }
}

