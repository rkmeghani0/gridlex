import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class UserRepository {
  // static Future<AccountLabelResponse> getCompanyLabel() async {
  //   AccountLabelResponse accountLabelResponse;
  //   try {
  //     Response response = await dio.get(HttpUrls.getCompanyLabel);
  //     accountLabelResponse = AccountLabelResponse.fromJson(response.data);
  //     // return accountLabelResponse;
  //   } on DioError catch (error) {
  //     accountLabelResponse = AccountLabelResponse.fromJson(error.response.data);
  //     // return accountLabelResponse;
  //   }
  //   FirebaseAnalyticsHelper().customEvent(eventName: "api_request", parameter: {
  //     "url": HttpUrls.getCompanyLabel,
  //     "response": jsonEncode(accountLabelResponse).toString(),
  //   });
  //   return accountLabelResponse;
  // }
}
