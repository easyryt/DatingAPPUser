import 'package:flutter/material.dart';
import 'package:gad_fly/controller/chat_controller.dart';
import 'package:gad_fly/controller/main_application_controller.dart';
import 'package:gad_fly/services/socket_service.dart';
import 'package:get/get.dart';

class ChatScreen extends StatefulWidget {
  final String receiverId;
  const ChatScreen({super.key, required this.receiverId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatController chatController = Get.put(ChatController());

  MainApplicationController mainApplicationController = Get.find();

  ChatService chatService = ChatService();

  initFunction() async {
    if (mainApplicationController.authToken.value != "") {
      await chatService.connect(
        context,
        mainApplicationController.authToken.value,
        _onRequestAccepted,
        (_) {},
      );
    }
  }

  @override
  void initState() {
    initFunction();
    chatService.socket.on('new-message', (data) {
      chatController.messages.add(data);
    });

    chatService.socket.on('typing-start', (data) {
      chatController.isTyping.value = true;
    });

    chatService.socket.on('typing-stop', (data) {
      chatController.isTyping.value = false;
    });
    super.initState();
  }

  void _onRequestAccepted(Map<String, dynamic> data) async {
    mainApplicationController.partnerList.clear();
    if (data.containsKey('data')) {
      final List<dynamic> noteData = data['data'];
      List<Map<String, dynamic>> dataList =
          noteData.map((data) => data as Map<String, dynamic>).toList();
      mainApplicationController.partnerList.value = dataList;
    } else {
      throw Exception('Invalid response format: "data" field not found');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Chat")),
      body: Column(
        children: [
          Expanded(
            child: Obx(() => ListView.builder(
                  itemCount: chatController.messages.length,
                  itemBuilder: (context, index) {
                    var message = chatController.messages[index];
                    return Align(
                      alignment: message['senderType'] == 'user'
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        padding: EdgeInsets.all(10),
                        margin:
                            EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        decoration: BoxDecoration(
                          color: message['senderType'] == 'user'
                              ? Colors.blueAccent
                              : Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          message['content'],
                          style: TextStyle(
                              color: message['senderType'] == 'user'
                                  ? Colors.white
                                  : Colors.black),
                        ),
                      ),
                    );
                  },
                )),
          ),
          Obx(() => chatController.isTyping.value
              ? const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("Typing..."),
                )
              : const SizedBox.shrink()),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: chatController.messageController,
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        startTyping(widget.receiverId);
                      } else {
                        stopTyping(widget.receiverId);
                      }
                    },
                    decoration: InputDecoration(
                      hintText: "Type a message",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () => sendMessage(widget.receiverId),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  void sendMessage(String receiverId) {
    if (chatController.messageController.text.trim().isEmpty) return;

    chatService.socket.emit('send-message', {
      'receiverId': receiverId,
      'content': chatController.messageController.text.trim()
    });

    chatController.messageController.clear();
  }

  void startTyping(String receiverId) {
    chatService.socket.emit('typing-start', {'receiverId': receiverId});
  }

  void stopTyping(String receiverId) {
    chatService.socket.emit('typing-stop', {'receiverId': receiverId});
  }
}
