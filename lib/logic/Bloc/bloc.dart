import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:save_earth/logic/Bloc/google_auth/google_auth_bloc.dart';
import 'package:save_earth/logic/Bloc/auth/auth_bloc.dart';
import 'package:save_earth/logic/Bloc/item/item_bloc.dart';
import 'package:save_earth/repositores/auth_repository.dart';
import 'package:save_earth/repositores/item_repository.dart';
import 'package:save_earth/service/api_service.dart';

import 'InitBloc/init_bloc.dart';

class BlocList {
  final AuthRepository authRepository;
  final ItemRepository itemRepository;
  BlocList(this.authRepository, this.itemRepository);



  List<BlocProvider> get blocs {
    return [
      BlocProvider(create: (_) => InitBloc()),
      BlocProvider<GoogleAuthBloc>(create: (_) => GoogleAuthBloc()),
      BlocProvider<AuthBloc>(create: (_) => AuthBloc(authRepository)),
      BlocProvider<ItemBloc>(create: (_) => ItemBloc(itemRepository)),
    ];
  }
}
