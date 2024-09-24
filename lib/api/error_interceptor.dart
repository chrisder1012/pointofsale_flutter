import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class ErrorInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    print(options.uri.toString());
    handler.next(options);
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) {
    debugPrint("");
    debugPrint("**********************");
    debugPrint(err.requestOptions.uri.toString());
    debugPrint(err.response?.statusCode?.toString());
    debugPrint(err.message);
    debugPrint("**********************");
    debugPrint("");
    handler.next(err);
  }
}
