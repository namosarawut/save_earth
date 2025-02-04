import 'package:dio/dio.dart';
import 'package:save_earth/data/local_storage_helper.dart';

class ApiInterceptor extends Interceptor {
  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await LocalStorageHelper.getToken();
    options.headers.addAll({
      "Content-Type": "application/json",
      "Authorization": "Bearer $token", // เปลี่ยนเป็น token จริง
    });

    print("REQUEST[${options.method}] => PATH: ${options.path}");
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print("RESPONSE[${response.statusCode}] => DATA: ${response.data}");
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print("ERROR[${err.response?.statusCode}] => MESSAGE: ${err.message}");
    handler.next(err);
  }
}
