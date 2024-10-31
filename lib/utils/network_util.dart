import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:alpha/GeneralFiles/General.dart';

class NetworkUtil {
  static NetworkUtil _instance = new NetworkUtil.internal();
  NetworkUtil.internal();
  factory NetworkUtil() => _instance;

  final JsonDecoder _decoder = new JsonDecoder();

  Future<dynamic> get(String url) {
    String mUrl = '$myProtocol/$serverURL' + url;
    return http.get(Uri.parse(mUrl)).then((http.Response response) {
      final String res = response.body;
      final int statusCode = response.statusCode;

      if (statusCode < 200 || statusCode > 400 || json == null) {
        throw new Exception("Error while fetching data");
      }
      return _decoder.convert(res);
    });
  }

  Future<dynamic> post(String url, {Map? body}) {
    String mUrl = '$myProtocol$serverURL' + url;
    return http
        .post(Uri.parse(mUrl), body: body, headers: headers)
        .then((http.Response response) {
      final String res = response.body;
      final int statusCode = response.statusCode;

      if (statusCode < 200 || statusCode > 400 || json == null) {
        throw new Exception("Error while fetching data $statusCode");
      }
      return _decoder.convert(res);
    });
  }
}
