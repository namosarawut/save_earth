import 'package:dio/dio.dart';
import 'package:save_earth/service/api_service.dart';

import '../data/model/user_model.dart';

class AuthRepository {
  final ApiService apiService;

  AuthRepository(this.apiService);

  Future<String> registerUser(String username, String email, String password) async {

    try {
      final response = await apiService.post("/auth/register", data: {
        "username": username,
        "email": email,
        "password": password
      });

      return response.data["message"]; // "User registered successfully"
    } catch (e) {
      throw Exception("Registration failed");
    }
  }
  Future<Map<String, dynamic>> loginUser(String username, String password) async {
    try {
      final response = await apiService.post("/auth/login", data: {
        "username": username,
        "password": password
      });

      final token = response.data["token"];
      final userJson = response.data["user"];
      final user = UserModel.fromJson(userJson); // แปลง JSON เป็น Object

      return {"token": token, "user": user};
    } catch (e) {
      throw Exception("Login failed");
    }
  }

  Future<Map<String, dynamic>> loginWithGoogle(String uid, String email) async {
    try {
      final response = await apiService.post("/auth/google-auth", data: {
        "uid": uid,
        "email": email
      });

      final token = response.data["token"];
      final userJson = response.data["user"];
      final user = UserModel.fromJson(userJson);

      return {"token": token, "user": user};
    } catch (e) {
      throw Exception("Google Login failed");
    }
  }
}


