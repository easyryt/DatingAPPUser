import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:gad_fly/constant/api_end_point.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

class MainApplicationController extends GetxController {
  var pageIdx = 0.obs;
  var authToken = ''.obs;
  var partnerList = [].obs;

  Future transactionCreate(requestBody) async {
    Uri uri = Uri.parse('${ApiEndpoints.baseUrl}/user/transaction/create');

    try {
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          "x-user-token": authToken.value,
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = json.decode(response.body);

        final data = responseData['data'];
        return data;
      } else {
        final responseData = json.decode(response.body);
        return null;
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error occurred: $error');
      }
      return null;
    }
  }

  Future getTransaction() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiEndpoints.baseUrl}/user/transaction/history'),
        headers: {
          'x-user-token': authToken.value,
        },
      );

      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);
        final data = responseData['data'];
        return data;
      } else {
        print('Failed to load notes: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error while fetching notes: $e');
      return null;
    }
  }

  Future<bool> checkMicrophonePermission() async {
    final status = await Permission.microphone.status;

    if (status.isGranted) {
      print("Microphone permission already granted");
      return true; // Permission is already granted
    } else {
      final requestStatus = await Permission.microphone.request();

      if (requestStatus.isGranted) {
        print("Microphone access granted");
        return true;
      } else {
        print("Microphone permission denied");
        return false; // Permission denied
      }
    }
  }
}
