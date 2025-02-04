import 'dart:io';

import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:save_earth/service/api_service.dart';

import '../data/model/user_model.dart';

class AuthRepository {
  final ApiService apiService;

  AuthRepository(this.apiService);

  Future<String> registerUser(
      String username, String email, String password) async {
    try {
      final response = await apiService.post("/auth/register",
          data: {"username": username, "email": email, "password": password});

      return response.data["message"]; // "User registered successfully"
    } catch (e) {
      throw Exception("Registration failed");
    }
  }

  Future<Map<String, dynamic>> loginUser(
      String username, String password) async {
    try {
      final response = await apiService.post("/auth/login",
          data: {"username": username, "password": password});

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
      final response = await apiService
          .post("/auth/google-auth", data: {"uid": uid, "email": email});

      final token = response.data["token"];
      final userJson = response.data["user"];
      final user = UserModel.fromJson(userJson);

      return {"token": token, "user": user};
    } catch (e) {
      throw Exception("Google Login failed");
    }
  }

  Future<UserModel> getUserById(int userId) async {
    try {
      final response = await apiService.get("/user/$userId");
      return UserModel.fromJson(response.data);
    } catch (e) {
      throw Exception("Failed to get user data");
    }
  }

  /// **อัปเดตโปรไฟล์ผู้ใช้**
  Future<String> updateUserProfile({
    required int userId,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    File? profileImage,
  }) async {
    try {
      // ตรวจสอบ MIME type ของไฟล์
      String? mimeType = profileImage != null ? lookupMimeType(profileImage.path) : null;
      print("📌 Uploading File: ${profileImage?.path}");
      print("📌 Detected MIME Type: $mimeType");

      FormData formData = FormData.fromMap({
        "user_id": userId.toString(),
        "first_name": firstName,
        "last_name": lastName,
        "phone_number": phoneNumber,
        if (profileImage != null)
          "profile_image": await MultipartFile.fromFile(
            profileImage.path,
            contentType: mimeType != null ? MediaType.parse(mimeType) : MediaType("image", "jpeg"),
          ),
      });

      final response = await apiService.put("/user/update-profile", data: formData);
      return response.data["message"];
    } on DioException catch (e) {
      print("🚨 SERVER RESPONSE: ${e.response?.data}");
      throw Exception("Server Error: ${e.response?.data["message"] ?? "Unknown error"}");
    }
  }
}
