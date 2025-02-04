part of 'auth_bloc.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final String message;
  final String token;
  final UserModel? user;

  AuthSuccess(this.message, this.token, this.user);
}

class AuthFailure extends AuthState {
  final String error;
  AuthFailure(this.error);
}

class UserFetched extends AuthState {
  final UserModel user;
  UserFetched(this.user);
}

class ProfileUpdateSuccess extends AuthState {
  final String message;
  ProfileUpdateSuccess(this.message);
}