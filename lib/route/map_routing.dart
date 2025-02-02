
import 'package:flutter/material.dart';
import 'package:save_earth/presentation/screens/account/account_manage_screen.dart';
import 'package:save_earth/presentation/screens/auth/login_register_screen.dart';
import 'package:save_earth/presentation/screens/item/create_my_item_screen.dart';
import 'package:save_earth/presentation/screens/item/my_item_detail.dart';
import 'package:save_earth/presentation/screens/item/my_item_list_screen.dart';
import 'package:save_earth/presentation/screens/item/my_requests_detail.dart';
import 'package:save_earth/presentation/screens/item/requests_detail_screen.dart';
import 'package:save_earth/presentation/screens/item/the_requests_my_item.dart';
import 'package:save_earth/presentation/screens/main/main_screen.dart';
import 'package:save_earth/route/convert_route.dart';

final Map<String, WidgetBuilder> evShopRoutes = {
  (Routes.mainApp).toStringPath(): (BuildContext _) => const MainAppScreen(),
  (Routes.loginAndRegister).toStringPath(): (BuildContext _) => const LoginAndRegisterPage(),
  (Routes.editProfile).toStringPath(): (BuildContext _) => const EditProfilePage(),
  (Routes.myItemList).toStringPath(): (BuildContext _) => const MyItemsListScreen(),
  (Routes.requestsMyItem).toStringPath(): (BuildContext _) => const TheRequestsMyItemScreen(),
  (Routes.requestsDetail).toStringPath(): (BuildContext _) => const RequestDetailPage(),
  (Routes.myItemDetail).toStringPath(): (BuildContext _) =>  MyItemDetailScreen(),
  (Routes.myRequestsDetail).toStringPath(): (BuildContext _) =>  MyRequestsDetailScreen(),
  (Routes.createMyItem).toStringPath(): (BuildContext _) =>  CreateMyItemScreen(),
};

class CurrentRouteObserver extends RouteObserver<PageRoute<dynamic>> {
  CurrentRouteObserver._();

  static final instance = CurrentRouteObserver._();
  static final _stack = <String>[];

  String _name = "";
  String _last = "";

  String get name => _name;
  String get last => _last;
  List<String> get stack => _stack;

  void _sendScreenView(PageRoute<dynamic> route) {
    var screenName = route.settings.name;
    _name = screenName ?? "";
    // do something with it, ie. send it to analytics service collector
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    if (route is PageRoute) {
      _sendScreenView(route);
    }
    var name = route.settings.name ?? "";
    _stack.add(name);
    _last = name;
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute is PageRoute) {
      _sendScreenView(newRoute);
    }
    var name = newRoute?.settings.name ?? "";
    _stack.removeLast();
    _stack.add(name);
    _last = name;
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute is PageRoute && route is PageRoute) {
      _sendScreenView(previousRoute);
    }
    _stack.removeLast();
  }
}
