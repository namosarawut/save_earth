part of 'google_auth_bloc.dart';

abstract class GoogleAuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends GoogleAuthState {}

class GoogleAuthLoading extends GoogleAuthState {}

class Authenticated extends GoogleAuthState {
  final User user;
  Authenticated(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthError extends GoogleAuthState {
  final String error;
  AuthError(this.error);

  @override
  List<Object?> get props => [error];
}

class Unauthenticated extends GoogleAuthState {}
