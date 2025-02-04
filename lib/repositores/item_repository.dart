import 'dart:io';

import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:save_earth/data/model/item_model.dart';
import 'package:save_earth/service/api_service.dart';


class ItemRepository {
  final ApiService apiService;

  ItemRepository(this.apiService);

  /// **ดึงรายการชื่อไอเทมที่ไม่ซ้ำกัน**
  Future<List<String>> getUniqueItemNames() async {
    try {
      final response = await apiService.get("/items/unique-names");
      List<String> itemNames = List<String>.from(response.data);
      return itemNames;
    } catch (e) {
      throw Exception("Failed to fetch unique item names");
    }
  }
  Future<List<ItemModel>> searchItems({String? name, required double latitude, required double longitude}) async {
    try {
      Map<String, dynamic> queryParams = {
        "latitude": latitude.toString(),
        "longitude": longitude.toString(),
      };

      if (name != null && name.isNotEmpty) {
        queryParams["name"] = name;
      }

      final response = await apiService.get("/items/search", query: queryParams);
      List<ItemModel> items = (response.data["items"] as List).map((item) => ItemModel.fromJson(item)).toList();
      return items;
    } catch (e) {
      throw Exception("Failed to search items");
    }
  }

  /// **สร้างไอเทมใหม่**
  Future<String> createItem({
    required String name,
    required String category,
    required String description,
    required double latitude,
    required double longitude,
    required int posterUserId,
    File? image,
  }) async {
    try {
      // ตรวจสอบ MIME type ของไฟล์
      String? mimeType = image != null ? lookupMimeType(image.path) : null;
      print("📌 Uploading File: ${image?.path}");
      print("📌 Detected MIME Type: $mimeType");

      FormData formData = FormData.fromMap({
        "name": name,
        "category": category,
        "description": description,
        "latitude": latitude.toString(),
        "longitude": longitude.toString(),
        "poster_user_id": posterUserId.toString(),
        if (image != null)
          "image": await MultipartFile.fromFile(
            image.path,
            contentType: mimeType != null ? MediaType.parse(mimeType) : MediaType("image", "jpeg"),
          ),
      });

      final response = await apiService.post("/items", data: formData);
      return response.data["message"]; // "Item created successfully"
    } on DioException catch (e) {
      print("🚨 SERVER RESPONSE: ${e.response?.data}");
      throw Exception("Server Error: ${e.response?.data["message"] ?? "Unknown error"}");
    }
  }
}




