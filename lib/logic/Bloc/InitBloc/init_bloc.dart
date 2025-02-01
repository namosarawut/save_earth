import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'init_event.dart';
part 'init_state.dart';

class InitBloc extends Bloc<InitEvent, InitState> {
  InitBloc() : super(InitInitial()) {
    on<InitEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
