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

class GetUserById extends AuthEvent {
  final int userId;

  GetUserById(this.userId);
}

class UpdateUserProfile extends AuthEvent {
  final int userId;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final File? profileImage;

  UpdateUserProfile({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    this.profileImage,
  });
}

class LogoutUser extends AuthEvent {}

