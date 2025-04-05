import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gad_fly/constant/api_end_point.dart';
import 'package:gad_fly/controller/main_application_controller.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class ProfileController extends GetxController {
  var gender = 0.obs;
  var intersted = 1.obs;
  var imgUrl = "".obs;
  var aNameS = "".obs;
  var amount = 0.0.obs;
  var emailS = "".obs;
  var phoneNumberS = "".obs;
  final aNameController = TextEditingController();
  final oNameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
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
        if (responseData["data"]["avatarName"] != null) {
          aNameS.value = responseData["data"]["avatarName"];
          aNameController.text = responseData["data"]["avatarName"];
        }
        if (responseData["data"]["email"] != null) {
          emailS.value = responseData["data"]["email"];
          emailController.text = responseData["data"]["email"];
        }

        amount.value = double.parse("${responseData["data"]["walletAmount"]}");
        phoneNumberS.value = responseData["data"]["phone"] ?? "";
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

      request.fields['name'] = aNameController.text;
      request.fields['email'] = emailController.text;
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

  Future profileUpdate(requestBody) async {
    Uri uri =
        Uri.parse('${ApiEndpoints.baseUrl}/user/authAndWallet/updateProfile');

    try {
      final response = await http.put(
        uri,
        headers: {
          'Content-Type': 'application/json',
          "x-user-token": mainApplicationController.authToken.value,
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        // final responseData = json.decode(response.body);

        //  final data = responseData['data'];
        await getProfile();
        return true;
      } else {
        final responseData = json.decode(response.body);
        // if(responseData)
        Get.snackbar("Alert", responseData["message"]);
        return false;
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error occurred: $error');
      }
      Get.snackbar("Alert", "Something went wrong or Network Problem.");
      return false;
    }
  }
}
