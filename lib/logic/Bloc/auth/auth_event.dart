part of 'auth_bloc.dart';

abstract class AuthEvent {}

class RegisterUser extends AuthEvent {
  final String username;
  final String email;
  final String password;

  RegisterUser(this.username, this.email, this.password);
}
class LoginUser extends AuthEvent {
  final String username;
  final String password;

  LoginUser(this.username, this.password);
}
class LoginWithGoogle extends AuthEvent {
  final String uid;
  final String email;

  LoginWithGoogle(this.uid, this.email);
}


class LogoutUser extends AuthEvent {}
