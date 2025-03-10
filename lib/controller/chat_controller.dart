import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatController extends GetxController {
  // var messages = <Map<String, dynamic>>[].obs;
  var messages = <Message>[].obs;
  var isTyping = false.obs;

  final TextEditingController messageController = TextEditingController();
}

class Message {
  final String conversationId;
  final String senderId;
  final String receiverId;
  final String content;
  final String? status;
  final String senderType;
  final String id;
  final String createdAt;
  final String updatedAt;

  Message({
    required this.conversationId,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.senderType,
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.status,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      conversationId: json['conversationId'],
      senderId: json['senderId'],
      receiverId: json['receiverId'],
      content: json['content'],
      status: json['status'],
      senderType: json['senderType'],
      id: json['_id'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }
}
