
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:save_earth/data/model/request_model.dart';
import 'package:save_earth/repositores/request_repository.dart';
part 'get_my_requests_event.dart';
part 'get_my_requests_state.dart';



class GetMyRequestsBloc extends Bloc<GetMyRequestsEvent, GetMyRequestsState> {
  final RequestRepository repository;

  GetMyRequestsBloc(this.repository) : super(GetMyRequestsInitial()) {
    on<FetchMyRequests>((event, emit) async {
      emit(GetMyRequestsLoading());
      try {
        final requests = await repository.getMyRequests(event.userId);
        emit(GetMyRequestsLoaded(requests));
      } catch (e) {
        emit(GetMyRequestsError("Failed to load requests"));
      }
    });
  }
}

