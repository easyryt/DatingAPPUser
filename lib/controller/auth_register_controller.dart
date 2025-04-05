import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gad_fly/constant/api_end_point.dart';
import 'package:gad_fly/controller/main_application_controller.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthRegisterController extends GetxController {
  var sentOtp = false.obs;
  var isLoading = false.obs;
  var isError = false.obs;
  TextEditingController phoneTextEditingController = TextEditingController();
  TextEditingController otpTextEditingController = TextEditingController();
  final MainApplicationController mainApplicationController =
      Get.put(MainApplicationController());
  getOtp() async {
    isError.value = false;
    isLoading.value = true;
    Uri uri = Uri.parse('${ApiEndpoints.baseUrl}/user/authAndWallet/register');

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        // 'x-partner-token': 'application/json',
      },
      body: json.encode({
        "phone": phoneTextEditingController.text,
        // "fcmToken": widget.fcmToken,
      }),
    );
    isLoading.value = false;
    if (response.statusCode == 200) {
      final responseData = response.body;
      final data = jsonDecode(responseData);
      otpTextEditingController.text = data["otp"];
      sentOtp.value = true;
      return true;
    } else {
      return false;
    }
  }

  verifyOtp() async {
    isLoading.value = true;

    Uri uri = Uri.parse('${ApiEndpoints.baseUrl}/user/authAndWallet/logIn');

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        // 'x-partner-token': 'application/json',
      },
      body: json.encode({
        "phone": phoneTextEditingController.text,
        "otp": otpTextEditingController.text,
      }),
    );
    isLoading.value = false;
    if (response.statusCode == 200) {
      final responseData = response.body;
      final data = jsonDecode(responseData);
      mainApplicationController.authToken.value = data["token"];
      await saveTokenToSharedPreferences(data["token"]);
      return data["token"];
    } else {
      final responseData = response.body;
      if (kDebugMode) {
        print(responseData);
      }
      return "";
    }
  }

  Future<void> saveTokenToSharedPreferences(String authToken) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', authToken);
  }
}
