import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:alpha/GeneralFiles/General.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:crypto/crypto.dart';

class ApiBaseHelper {
  Future<dynamic> _returnResponse(Response response) async {
    if (response.statusCode == 200 || response.statusCode == 201) {
      var responseJson = json.decode(response.body.toString());
      return responseJson;
    }
    String msg = arEn(
      'حدث خطأ أثناء الاتصال بالخادم برمز الحالة : ${response.statusCode}',
      'Error occurred while communicating with server with status code : ${response.statusCode}',
    );
    done(cont!);
    showDialog(
      barrierDismissible: false,
      useRootNavigator: false,
      barrierColor: Colors.transparent,
      context: cont!,
      builder: (BuildContext context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
          child: Directionality(
            textDirection: direction,
            child: AlertDialog(
              elevation: 10,
              titlePadding: EdgeInsets.zero,
              actionsPadding: EdgeInsets.zero,
              buttonPadding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(10.0),
                ),
              ),
              title: Container(
                padding: EdgeInsets.only(right: 30, top: 10, left: 30),
                child: Row(
                  children: [
                    Icon(
                      Icons.report_problem,
                      color: Colors.red,
                    ),
                    SizedBox(width: 5),
                    Text(
                      arEn('خطأ', 'Error'),
                      style: TextStyle(fontSize: fSize(7)),
                    ),
                  ],
                ),
              ),
              content: Builder(
                builder: (context) {
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 30),
                    width: width,
                    child: Text(msg),
                  );
                },
              ),
              contentPadding: EdgeInsets.symmetric(vertical: 10),
              actions: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(width: 5),
                      redOK(arEn('ارسال تقرير', 'Send report'), () {
                        Navigator.pop(context, true);
                        reportError(response.body);
                      }),
                      SizedBox(width: 5),
                      redCancel(arEn('الغاء', 'Cancel'), () {
                        Navigator.pop(context, false);
                      }),
                      SizedBox(width: 5),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    // throw FetchDataException(response.statusCode.toString());
    dynamic value = {"result": "", "error": true};

    return value;
  }

  Future<String> generateSignature(String signature) async {
    String ipAddress = '192.168.1.1';
    var encodedKey = utf8.encode(signature); // signature=encryption key
    var hmacSha256 = new Hmac(sha256, encodedKey); // HMAC-SHA256 with key
    var bytesDataIn = utf8.encode(ipAddress); // encode the data to Unicode.
    var digest = hmacSha256.convert(bytesDataIn); // encrypt target data
    String singedValue = digest.toString();
    return singedValue;
  }

  Future<dynamic> excute(String url, Map<String, dynamic> body) async {
    //String token = await Candidate().getToken();
    Uri _baseUrl = Uri.parse('$myProtocol$serverURL/$url');
    // String encoded = base64Url.encode(utf8.encode(body.toString()));
    // List<int> bodyBytes = utf8.encode(body.toString());
    // String myHash = await generateSignature(url);

    var responseJson;
    try {
      final response = await post(
        _baseUrl,
        headers: headers,
        body: body,
        encoding: Encoding.getByName("utf-8"),
      );
      if (response.reasonPhrase != 'OK') {
        errorMSG = response.body;
      }
      responseJson = _returnResponse(response);
    } on SocketException {
      toast(arEn('لا يوجد اتصال بالإنترنت', 'No Internet connection'));
      throw FetchDataException(
          arEn('لا يوجد اتصال بالإنترنت', 'No Internet connection'));
    }
    return responseJson;
  }
}

class AppException implements Exception {
  final _message;
  final _prefix;

  AppException([this._message, this._prefix]);

  String toString() {
    return "$_prefix$_message";
  }
}

class FetchDataException extends AppException {
  FetchDataException([String? message])
      : super(message, "Error During Communication: ");
}

class BadRequestException extends AppException {
  BadRequestException([message]) : super(message, "Invalid Request: ");
}

class UnauthorisedException extends AppException {
  UnauthorisedException([message]) : super(message, "Unauthorised: ");
}

class InvalidInputException extends AppException {
  InvalidInputException([String? message]) : super(message, "Invalid Input: ");
}
