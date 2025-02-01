
import 'package:flutter_bloc/flutter_bloc.dart';

import 'InitBloc/init_bloc.dart';

final List<BlocProvider> blocs = [
  BlocProvider(create: (_) => InitBloc()),

];
