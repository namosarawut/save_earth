enum Routes { loginAndRegister,mainApp}

extension TypeCoverter on Routes {
  String toStringPath() {
    switch (this) {
      case Routes.mainApp:
        return '/';
      case Routes.loginAndRegister:
        return 'loginAndRegister';
    }
  }
}
