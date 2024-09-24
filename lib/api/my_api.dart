import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zabor/api/error_interceptor.dart';

class CallApi {
  String? token;
  String? userId;
  final Dio _dio;
  CallApi([String baseUrl = 'https://api.zaboreats.com/api/'])
      : _dio = Dio(BaseOptions(baseUrl: baseUrl))
          ..interceptors.add(ErrorInterceptor());

  Future<Response<Map<String, dynamic>>> getDataWithToken(String apiUrl,
      {int? userId, Map<String, dynamic>? queryParameter}) async {
    await _getToken();
    // print(_setHeadersWithTokenV2());
    return _dio.get(
      apiUrl,
      queryParameters: queryParameter,
      options: Options(
        headers: _setHeadersWithTokenV2(),
      ),
    );
  }

  Future<Response<Map<String, dynamic>>> getDataWithoutToken(String apiUrl,
      {Map<String, dynamic>? queryParameter}) async {
    return _dio.get(
      apiUrl,
      queryParameters: queryParameter,
      options: Options(
        headers: _setHeadersWithoutToken(),
      ),
    );
  }

  Future<Response<Map<String, dynamic>>> postData(data, String apiUrl) async {
    return _dio.post(
      apiUrl,
      data: jsonEncode(data),
      options: Options(
        headers: _setHeadersWithToken(),
      ),
    );
  }

  Future<Response<Map<String, dynamic>>> deleteData(String apiUrl, data) async {
    await _getToken();
    return _dio.delete(
      apiUrl,
      data: jsonEncode(data),
      options: Options(
        headers: _setHeadersWithToken(),
      ),
    );
  }

  Future<Response<Map<String, dynamic>>> postGetDataWithToken(
      data, String apiUrl,
      [int? userId]) async {
    await _getToken();
    // print(_setHeadersWithTokenV2());
    return await _dio.post(
      apiUrl,
      data: jsonEncode(data),
      options: Options(
        headers: _setHeadersWithTokenV2(),
      ),
    );
  }

  Future<Response<Map<String, dynamic>>>
      postGetDataWithTokenAndClientPlatformHeader(
          data, String apiUrl, String clientPlatformHeader) async {
    await _getToken();

    print([
      "_setHeadersWithTokenAndClientPlatform(clientPlatformHeader):",
      _setHeadersWithTokenAndClientPlatform(clientPlatformHeader)
    ]);
    return await _dio.post(
      apiUrl,
      data: jsonEncode(data),
      options: Options(
        headers: _setHeadersWithTokenAndClientPlatform(clientPlatformHeader),
      ),
    );
  }

  Future<Response<Map<String, dynamic>>> patchDataWithToken(
      data, String apiUrl) async {
    await _getToken();
    return await _dio.patch(
      apiUrl,
      data: jsonEncode(data),
      options: Options(
        headers: _setHeadersWithToken(),
      ),
    );
  }

  Future<Response<Map<String, dynamic>>> putData(data, String apiUrl) async {
    await _getToken();
    return _dio.put(
      apiUrl,
      data: jsonEncode(data),
      options: Options(
        headers: _setHeadersWithToken(),
      ),
    );
  }

  _setHeadersWithTokenAndClientPlatform(String clientPlatformHeader) => {
        'Content-type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
        'Client-Platform': clientPlatformHeader,
        'Client-User-ID': userId,
        'Client-IP': '123.123.123.123'
      };
  _setHeadersWithToken() => {
        'Content-type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
        'Client-User-ID': 'id of user'
      };

  _setHeadersWithTokenV2() => {
        'Content-type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
        'Client-User-ID': userId
      };

  _setHeadersWithoutToken() => {
        'Content-type': 'application/json',
        // 'Content-Length': '<calculated when request is sent>',
        // 'Host': '<calculated when request is sent>',
        'User-Agent': 'PostmanRuntime/7.36.3',
        'Accept-Encoding': 'gzip, deflate, br',
        'Connection': 'keep-alive',
        'Authorization': 'Bearer $token',
        'Client-User-ID': userId
      };

  _getToken() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    token = localStorage.getString('token');
    userId = localStorage.getInt('uid').toString();
  }
}
