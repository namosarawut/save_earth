
part of 'google_auth_bloc.dart';


abstract class GoogleAuthEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class GoogleSignInRequested extends GoogleAuthEvent {}

class SignOutRequested extends GoogleAuthEvent {}
