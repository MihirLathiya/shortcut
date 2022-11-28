import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../apis/app_exception.dart';

enum APIType {
  aPost,
  aGet,
}

class APIService {
  var response;
  // final String baseUrl = 'https://api.relysia.com/';
  // String authorizationToken = "\$1\$aRkFpEz3\$qGGbgw/.xtfSv8rvK/j5y0";
  // String clientServiceToken = "frontend-client";
  // String authKeyToken = "simplerestapi";
  // String contentLength = "<calculated when request is sent>";
  // String host = "<calculated when request is sent>";
  String contentTypeToken = "application/x-www-form-urlencoded";

  /// tokens for api body...1595922666X5f1fd8bb5f662
  String clientKeyToken = "1595922666X5f1fd8bb5f662";
  String deviceTypeToken = "MOB";
  @override
  Future getResponse(
      {required String url,
      required APIType apitype,
      Map<String, dynamic>? body,
      Map<String, String>? header,
      bool fileUpload = false}) async {
    // Map<String, String> header = {
    //   "Authorization": "$authorizationToken",
    //   "Client-Service": "$clientServiceToken",
    //   "Auth-Key": "$authKeyToken",
    //   "Content-Type": "$contentTypeToken",
    // };

    try {
      if (apitype == APIType.aGet) {
        final result = await http.get(Uri.parse(url), headers: header);
        response = returnResponse(result.statusCode, result.body);
        // log("res${result.body}");
      } else if (fileUpload) {
      } else {
        print("REQUEST url ======>>>>> $url");
        print("REQUEST PARAMETER ======>>>>> $body");

        final result =
            await http.post(Uri.parse(url), body: body, headers: header);
        log("resp${result.body}");
        response = returnResponse(result.statusCode, result.body);
        print(result.statusCode);
      }
    } on SocketException {
      throw FetchDataException('No Internet access');
    }

    return response;
  }

  returnResponse(int status, String result) {
    switch (status) {
      case 200:
        return jsonDecode(result);
      case 201:
        return jsonDecode(result);
      case 400:
        return jsonDecode(result);
      // throw BadRequestException('Bad Request');
      case 401:
        throw UnauthorisedException('Unauthorised user');
      case 404:
        throw ServerException('Server Error');
      case 500:
      default:
        throw FetchDataException('Internal Server Error');
    }
  }
}
