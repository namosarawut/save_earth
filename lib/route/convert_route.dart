enum Routes {
  loginAndRegister,
  mainApp,
  editProfile,
  myItemList,
  requestsMyItem,
  requestsDetail,
  myItemDetail,
  myRequestsDetail,
  createMyItem,
}

extension TypeCoverter on Routes {
  String toStringPath() {
    switch (this) {
      case Routes.mainApp:
        return '/';
      case Routes.loginAndRegister:
        return 'loginAndRegister';
      case Routes.editProfile:
        return 'editProfile';
      case Routes.myItemList:
        return 'myItemList';
      case Routes.requestsMyItem:
        return 'requestsMyItem';
      case Routes.requestsDetail:
        return 'requestsDetail';
      case Routes.myItemDetail:
        return 'myItemDetail';
      case Routes.myRequestsDetail:
        return 'myRequestsDetail';
      case Routes.createMyItem:
        return 'createMyItem';
    }
  }
}
