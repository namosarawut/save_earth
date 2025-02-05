import 'package:dio/dio.dart';
import 'package:save_earth/data/model/request_model.dart';
import 'package:save_earth/service/api_service.dart';


class RequestRepository {
  final ApiService apiService;

  RequestRepository(this.apiService);

  Future<String> createRequest({
    required int itemId,
    required int userId,
    required String reason,
  }) async {
    try {
      final response = await apiService.post(
        "/requests",
        data: {
          "item_id": itemId,
          "user_id": userId,
          "reason": reason,
        },
      );
      return response.data["message"];
    } catch (e) {
      throw Exception("Failed to submit request");
    }
  }
  Future<List<RequestModel>> getMyRequests(int userId) async {
    try {
      final response = await apiService.get("/requests/user/$userId");
      return (response.data as List).map((json) => RequestModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception("Failed to fetch requests");
    }
  }
  Future<String> deleteMyRequest(int requestId) async {
    try {
      final response = await apiService.delete("/requests/$requestId");
      return response.data["message"];
    } catch (e) {
      throw Exception("Failed to delete request");
    }
  }
  Future<String> approveRequest({
    required int itemId,
    required int requestId,
  }) async {
    try {
      final response = await apiService.post(
        "/requests/approve",
        data: {
          "item_id": itemId,
          "request_id": requestId,
        },
      );
      return response.data["message"];
    } catch (e) {
      throw Exception("Failed to approve request");
    }
  }
}
