import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gad_fly/constant/api_end_point.dart';
import 'package:gad_fly/controller/main_application_controller.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class ProfileController extends GetxController {
  var gender = 0.obs;
  var intersted = 0.obs;
  var imgUrl = "".obs;
  var nameS = "".obs;
  var amount = 0.obs;
  var emailS = "".obs;
  var phoneNumberS = "".obs;
  final name = TextEditingController();
  final email = TextEditingController();
  final languagesController = TextEditingController();
  final languagesController1 = TextEditingController();

  MainApplicationController mainApplicationController = Get.find();

  getProfile() async {
    final response = await http.get(
      Uri.parse('${ApiEndpoints.baseUrl}/user/authAndWallet/getProfile'),
      headers: {
        'x-user-token': mainApplicationController.authToken.value,
      },
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      if (responseData is Map<String, dynamic>) {
        nameS.value = responseData["data"]["name"];
        amount.value = responseData["data"]["walletAmount"];
        name.text = responseData["data"]["name"];
        emailS.value = responseData["data"]["email"];
        email.text = responseData["data"]["email"];
        // phoneNumberS.value = responseData["data"]["phone"] ?? "";
        // languagesController.text = responseData["data"]["phone"] ?? "";
        return responseData;
      } else {
        print("Error: Invalid response format");
        return null;
      }
    } else {
      return null;
    }
  }

  Future updateProfile() async {
    try {
      final Uri apiUrl =
          Uri.parse("${ApiEndpoints.baseUrl}/user/authAndWallet/updateProfile");

      var request = http.MultipartRequest('PUT', apiUrl);

      request.headers['x-user-token'] =
          mainApplicationController.authToken.value;

      request.fields['name'] = name.text;
      request.fields['email'] = email.text;
      final languages = [languagesController.text, languagesController1.text];

      for (int i = 0; i < languages.length; i++) {
        request.fields['languages'] = languages[i];
      }
      request.fields['gender'] = gender.value == 0
          ? "male"
          : gender.value == 1
              ? "female"
              : "other";
      request.fields['intersted'] = intersted.value == 0
          ? "male"
          : intersted.value == 1
              ? "female"
              : "other";

      var response = await request.send();

      if (response.statusCode == 200) {
        await getProfile();
        return true;
      } else {
        if (kDebugMode) {
          print("Failed to upload: ${response.statusCode}");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error uploading info: $e");
      }
    }
  }
}
