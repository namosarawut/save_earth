
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:save_earth/logic/Bloc/google_auth/google_auth_bloc.dart';

import 'InitBloc/init_bloc.dart';

final List<BlocProvider> blocs = [
  BlocProvider(create: (_) => InitBloc()),
  BlocProvider<GoogleAuthBloc>(create: (_) => GoogleAuthBloc()),

];
