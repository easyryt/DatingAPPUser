import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gad_fly/constant/api_end_point.dart';
import 'package:gad_fly/model/all_chat_model.dart';
import 'package:gad_fly/screens/chat.dart';
import 'package:gad_fly/screens/home/history_screen.dart';
import 'package:gad_fly/screens/home/home_page.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

class MainApplicationController extends GetxController {
  var pageIdx = 0.obs;
  var authToken = ''.obs;
  var partnerList = [].obs;
  AllChatModel? allChatModel;
  var chatList = [].obs;

  List<Widget> homeWidgets = [
    const HomePage(),
    //  const SizedBox(),
    const ChatScreen(),
    const CallHistoryScreen(),
  ];

  var searchText = ''.obs;
  List get filteredPartners {
    if (searchText.isEmpty) return partnerList;
    return partnerList.where((item) {
      String name = item["personalInfo"]["avatarName"].toLowerCase();
      return name.contains(searchText.value.toLowerCase());
    }).toList();
  }

  var callHistoryList = [].obs;
  Future getAllCallHistory() async {
    final response = await http.get(
      Uri.parse('${ApiEndpoints.baseUrl}/user/callHistory/getAll'),
      headers: {
        'x-user-token': authToken.value,
      },
    );
    if (response.statusCode == 200) {
      callHistoryList.clear();
      final responseData = json.decode(response.body);
      // if (data.containsKey('data')) {
      //   final List<dynamic> noteData = data['data'];
      //   List<Map<String, dynamic>> dataList =
      //   noteData.map((data) => data as Map<String, dynamic>).toList();
      //   mainApplicationController.partnerList.value = dataList;
      // } else {
      //   throw Exception('Invalid response format: "data" field not found');
      // }
      callHistoryList.value = responseData["data"];
      return true;
    } else {
      final responseData = json.decode(response.body);
      print(responseData);
      return false;
    }
  }

  Future getAllChat() async {
    final response = await http.get(
      Uri.parse('${ApiEndpoints.baseUrl}/user/chatHistory/getAll'),
      headers: {
        'x-user-token': authToken.value,
      },
    );
    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      // if (data.containsKey('data')) {
      //   final List<dynamic> noteData = data['data'];
      //   List<Map<String, dynamic>> dataList =
      //   noteData.map((data) => data as Map<String, dynamic>).toList();
      //   mainApplicationController.partnerList.value = dataList;
      // } else {
      //   throw Exception('Invalid response format: "data" field not found');
      // }
      allChatModel = AllChatModel.fromJson(responseData);
      return true;
    } else {
      final responseData = json.decode(response.body);
      print(responseData);
      return false;
    }
  }

  Future getMessages(conversationId) async {
    final response = await http.get(
      Uri.parse(
          '${ApiEndpoints.baseUrl}/user/chatHistory/messageHistory/$conversationId'),
      headers: {
        'x-user-token': authToken.value,
      },
    );
    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);

      // allChatModel = AllChatModel.fromJson(responseData);
      return responseData;
    } else {
      final responseData = json.decode(response.body);
      print(responseData);
      return null;
    }
  }

  var rechargeOfferList = [].obs;
  Future getRechargeOffer() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiEndpoints.baseUrl}/user/transaction/recharge/getAll'),
        headers: {
          'x-user-token': authToken.value,
        },
      );

      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);
        final data = responseData['data'];
        rechargeOfferList.value = data;
        return data;
      } else {
        print('Failed to load wallet: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error while fetching wallet: $e');
      return null;
    }
  }

  Future transactionCreate(requestBody, id) async {
    Uri uri = Uri.parse('${ApiEndpoints.baseUrl}/user/transaction/create/$id');

    try {
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          "x-user-token": authToken.value,
        },
        body: null, //json.encode(requestBody),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = json.decode(response.body);

        final data = responseData['data'];
        //  await getTransaction();
        return data;
      } else {
        final responseData = json.decode(response.body);
        if (kDebugMode) {
          print(responseData);
        }
        return null;
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error occurred: $error');
      }
      return null;
    }
  }

  var getTransactionList = [].obs;
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
        getTransactionList.value = data;
        return data;
      } else {
        print('Failed to load wallet: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error while fetching wallet: $e');
      return null;
    }
  }

  Future fetchRazorpayKey() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiEndpoints.baseUrl}/user/transaction/seceretKey'),
        headers: {
          'x-user-token': authToken.value,
        },
      );

      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);
        final data = responseData['data'];
        return data;
      } else {
        print('Failed to load wallet: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error while fetching wallet: $e');
      return null;
    }
  }

  Future verifyPayment(orderId, razorpayResponse) async {
    var paymentData = {
      "razorpay_order_id": razorpayResponse.orderId,
      "razorpay_payment_id": razorpayResponse.paymentId,
      "razorpay_signature": razorpayResponse.signature,
      "transactionId": orderId
    };

    Uri uri =
        Uri.parse('${ApiEndpoints.baseUrl}/user/transaction/verifyPayment');

    try {
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          "x-user-token": authToken.value,
        },
        body: json.encode(paymentData),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = json.decode(response.body);

        final data = responseData;

        await getTransaction();
        return data;
      } else {
        final responseData = json.decode(response.body);
        if (kDebugMode) {
          print(responseData);
        }
        return null;
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error occurred: $error');
      }
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

  String formatDate(String inputDate) {
    try {
      DateTime dateTime = DateTime.parse(inputDate);
      DateTime now = DateTime.now();
      // String outputDate = DateFormat('dd-MMM   hh:mm a').format(dateTime);
      // return outputDate;
      if (dateTime.year == now.year &&
          dateTime.month == now.month &&
          dateTime.day == now.day) {
        return 'Today ${DateFormat('hh:mm a').format(dateTime)}'; // "Today hh:mm a"
      } else {
        return DateFormat('dd-MMM  hh:mm a').format(dateTime);
      }
    } catch (e) {
      print('Invalid date format: $e');
      return 'Invalid Date';
    }
  }
}
