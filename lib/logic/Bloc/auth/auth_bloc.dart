
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:save_earth/data/local_storage_helper.dart';
import 'package:save_earth/data/model/user_model.dart';
import 'package:save_earth/repositores/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository repository;

  AuthBloc(this.repository) : super(AuthInitial()) {
    on<RegisterUser>((event, emit) async {
      emit(AuthLoading());
      try {
        final message = await repository.registerUser(event.username, event.email, event.password);
        emit(AuthSuccess(message, "", null));
      } catch (e) {
        emit(AuthFailure("Registration failed"));
      }
    });

    on<LoginUser>((event, emit) async {
      emit(AuthLoading());
      try {
        final response = await repository.loginUser(event.username, event.password);
        final token = response["token"];
        final UserModel user = response["user"];
        // บันทึก Token และ User ลงใน Local Storage
        await LocalStorageHelper.saveToken(token);
        await LocalStorageHelper.saveUser(user);
        emit(AuthSuccess("Login successful", token, user));
      } catch (e) {
        emit(AuthFailure("Login failed"));
      }
    });

    on<LoginWithGoogle>((event, emit) async {
      emit(AuthLoading());
      try {
        final response = await repository.loginWithGoogle(event.uid, event.email);
        final token = response["token"];
        final UserModel user = response["user"];

        await LocalStorageHelper.saveToken(token);
        await LocalStorageHelper.saveUser(user);

        emit(AuthSuccess("Google Login successful", token, user));
      } catch (e) {
        emit(AuthFailure("Google Login failed"));
      }
    });

    on<LogoutUser>((event, emit) async {
      await LocalStorageHelper.clearAll(); // ลบ Token และ User
      emit(AuthInitial()); // กลับไปสู่สถานะเริ่มต้น
    });

  }
}



