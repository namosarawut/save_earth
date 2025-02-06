import 'package:dio/dio.dart';
import 'package:save_earth/constants/constants.dart';
import 'package:save_earth/intercepter/api_interceptor.dart';


class ApiService {
  late Dio _dio;

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: saveEarthBaseUrl, // ตั้งค่า base URL ของ API
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ));

    _dio.interceptors.add(ApiInterceptor());
  }
  // Function สำหรับ GET
  Future<Response> get(String endpoint, {Map<String, dynamic>? query}) async {
    return await _dio.get(endpoint, queryParameters: query);
  }

  // Function สำหรับ POST
  Future<Response> post(String endpoint, {dynamic data}) async {
    return await _dio.post(endpoint, data: data);
  }

  // Function สำหรับ PUT
  Future<Response> put(String endpoint, {dynamic data}) async {
    return await _dio.put(endpoint, data: data);
  }

  // Function สำหรับ DELETE
  Future<Response> delete(String endpoint, {dynamic data}) async {
    return await _dio.delete(endpoint, data: data);
  }
}
