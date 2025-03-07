import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatController extends GetxController {
  var messages = <Map<String, dynamic>>[].obs;
  var isTyping = false.obs;

  final TextEditingController messageController = TextEditingController();
}
