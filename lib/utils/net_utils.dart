import 'dart:async';
import 'package:dio/dio.dart';

Dio dio = Dio();

class NetUtils {
  static Future get(String url, {Map<String, dynamic> params}) async {
  var response = await dio.get(url, queryParameters: params);
    return response.data;
  }

  static Future post(String url, Map<String, dynamic> params) async {
    var response = await dio.post(url, data: params);
    return response.data;
  }
}
