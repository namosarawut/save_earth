import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:save_earth/logic/Bloc/approve_request/approve_request_bloc.dart';
import 'package:save_earth/logic/Bloc/create_item/create_item_event_bloc.dart';
import 'package:save_earth/logic/Bloc/create_request/create_request_bloc.dart';
import 'package:save_earth/logic/Bloc/delete_my_item/delete_my_item_bloc.dart';
import 'package:save_earth/logic/Bloc/delete_my_request/delete_my_request_bloc.dart';
import 'package:save_earth/logic/Bloc/get_my_item_list/get_my_item_list_bloc.dart';
import 'package:save_earth/logic/Bloc/get_my_requests/get_my_requests_bloc.dart';
import 'package:save_earth/logic/Bloc/google_auth/google_auth_bloc.dart';
import 'package:save_earth/logic/Bloc/auth/auth_bloc.dart';
import 'package:save_earth/logic/Bloc/item/item_bloc.dart';
import 'package:save_earth/logic/Bloc/search_data/searh_data_bloc.dart';
import 'package:save_earth/repositores/auth_repository.dart';
import 'package:save_earth/repositores/item_repository.dart';
import 'package:save_earth/repositores/request_repository.dart';
import 'package:save_earth/service/api_service.dart';

import 'InitBloc/init_bloc.dart';

class BlocList {
  final AuthRepository authRepository;
  final ItemRepository itemRepository;
  final RequestRepository requestRepository;
  BlocList(this.authRepository, this.itemRepository,this.requestRepository);



  List<BlocProvider> get blocs {
    return [
      BlocProvider(create: (_) => InitBloc()),
      BlocProvider<GoogleAuthBloc>(create: (_) => GoogleAuthBloc()),
      BlocProvider<AuthBloc>(create: (_) => AuthBloc(authRepository)),
      BlocProvider<ItemBloc>(create: (_) => ItemBloc(itemRepository)),
      BlocProvider<CreateItemBloc>(create: (_) => CreateItemBloc(itemRepository)),
      BlocProvider<GetMyItemListBloc>(create: (_) => GetMyItemListBloc(itemRepository)),
      BlocProvider<DeleteMyItemBloc>(create: (_) => DeleteMyItemBloc(itemRepository)),
      BlocProvider<SearchDataBloc>(create: (_) => SearchDataBloc(itemRepository)),
      BlocProvider<CreateRequestBloc>(create: (_) => CreateRequestBloc(requestRepository)),
      BlocProvider<GetMyRequestsBloc>(create: (_) => GetMyRequestsBloc(requestRepository)),
      BlocProvider<DeleteMyRequestBloc>(create: (_) => DeleteMyRequestBloc(requestRepository)),
      BlocProvider<ApproveRequestBloc>(create: (_) => ApproveRequestBloc(requestRepository)),
    ];
  }
}
