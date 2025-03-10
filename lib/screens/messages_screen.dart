import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:gad_fly/constant/color_code.dart';
import 'package:gad_fly/controller/chat_controller.dart';
import 'package:gad_fly/controller/main_application_controller.dart';
import 'package:gad_fly/model/messages_model.dart';
import 'package:gad_fly/services/socket_service.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class MessagesScreen extends StatefulWidget {
  final String receiverId;
  final String name;
  const MessagesScreen(
      {super.key, required this.receiverId, required this.name});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final ChatController chatController = Get.put(ChatController());
  final ScrollController _scrollController = ScrollController();
  MainApplicationController mainApplicationController = Get.find();

  ChatService chatService = ChatService();
  MessagesModel? messagesModel;

  initFunction() async {
    if (mainApplicationController.authToken.value != "") {
      await chatService.connect(
        (_) {},
      );
      await fetchPreviousMessages();
      // await mainApplicationController
      //     .getMessages(widget.receiverId)
      //     .then((onValue) {
      //   if (onValue != null) {
      //     messagesModel = MessagesModel.fromJson(onValue);
      //     if (onValue['data'].containsKey('messages')) {
      //       final List<dynamic> messageData = onValue['data']["messages"];
      //       List<Map<String, dynamic>> dataList = messageData
      //           .map((data) => data as Map<String, dynamic>)
      //           .toList();
      //       //  mainApplicationController.partnerList.value = dataList;
      //       // chatController.messages.add(dataList);
      //       for (var messageMap in dataList) {
      //         chatController.messages.add(Message.fromJson(messageMap));
      //       }
      //     } else {
      //       throw Exception('Invalid response format: "data" field not found');
      //     }
      //   }
      // });
    }
  }

  @override
  void initState() {
    initFunction();
    chatService.socket.on('new-message', (data) {
      chatController.messages.add(Message.fromJson(data));
      _scrollToBottom();
    });
    chatService.socket.on('message-sent', (data) {
      chatController.messages.add(Message.fromJson(data));
      _scrollToBottom();
    });

    chatService.socket.on('typing-start', (data) {
      chatController.isTyping.value = true;
    });

    chatService.socket.on('typing-stop', (data) {
      chatController.isTyping.value = false;
    });

    chatService.socket.on('previous-messages', (data) {
      // chatController.messages.add(Message.fromJson(data));
      if (data != 0 && data != null) {
        final List<dynamic> messageData = data;
        List<Map<String, dynamic>> dataList =
            messageData.map((data) => data as Map<String, dynamic>).toList();
        //  mainApplicationController.partnerList.value = dataList;
        // chatController.messages.add(dataList);
        for (var messageMap in dataList) {
          chatController.messages.add(Message.fromJson(messageMap));
        }
      }
      _scrollToBottom();
    });

    super.initState();
    KeyboardVisibilityController().onChange.listen((bool isVisible) {
      if (isVisible) {
        _scrollToBottom();
      }
    });
  }

  void _onRequestAccepted(Map<String, dynamic> data) async {
    // mainApplicationController.partnerList.clear();
    // if (data.containsKey('data')) {
    //   final List<dynamic> noteData = data['data'];
    //   List<Map<String, dynamic>> dataList =
    //       noteData.map((data) => data as Map<String, dynamic>).toList();
    //   mainApplicationController.partnerList.value = dataList;
    // } else {
    //   throw Exception('Invalid response format: "data" field not found');
    // }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: white,
      appBar: AppBar(
          backgroundColor: white,
          surfaceTintColor: white,
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.arrow_back_ios_new,
                size: 18,
              )),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.name ?? "Message",
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              Obx(() => chatController.isTyping.value
                  ? const Text(
                      "Typing...",
                      style:
                          TextStyle(fontSize: 10, fontWeight: FontWeight.w400),
                    )
                  : const SizedBox.shrink()),
            ],
          )),
      body: Column(
        children: [
          Expanded(
            child: Obx(() => ListView.builder(
                  itemCount: chatController.messages.length,
                  controller: _scrollController,
                  itemBuilder: (context, index) {
                    var message = chatController.messages[index];
                    return Align(
                      alignment: message.senderType == 'user'
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        margin: EdgeInsets.only(
                            bottom: 1,
                            top: 1,
                            left:
                                message.senderType == 'user' ? width * 0.1 : 10,
                            right: message.senderType == 'user'
                                ? 10
                                : width * 0.1),
                        decoration: BoxDecoration(
                          color: message.senderType == 'user'
                              ? appColorR
                              : appColorMessage,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                            bottomLeft: message.senderType == 'user'
                                ? Radius.circular(10)
                                : Radius.zero,
                            bottomRight: message.senderType == 'user'
                                ? Radius.zero
                                : const Radius.circular(10),
                          ),
                        ),
                        constraints: BoxConstraints(
                          maxWidth: width * 0.85,
                        ),
                        child: Column(
                          crossAxisAlignment: message.senderType == 'user'
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            Text(
                              message.content,
                              style: const TextStyle(
                                  fontSize: 15,
                                  color:
                                      // message.senderType == 'user'
                                      //     ?
                                      Colors.white
                                  // : Colors.black,
                                  ),
                            ),
                            // const SizedBox(width: 6),
                            Text(
                              formatDate(message.createdAt),
                              style: TextStyle(
                                  fontSize: 8, color: Colors.grey.shade300),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                )),
          ),
          // Padding(
          //   padding: const EdgeInsets.all(8.0),
          //   child: Row(
          //     children: [
          //       Expanded(
          //         child: TextField(
          //           controller: chatController.messageController,
          //           onChanged: (value) {
          //             if (value.isNotEmpty) {
          //               startTyping(widget.receiverId);
          //             } else {
          //               stopTyping(widget.receiverId);
          //             }
          //           },
          //           decoration: InputDecoration(
          //             isDense: true,
          //             hintText: "Type a message",
          //             border: OutlineInputBorder(
          //               borderRadius: BorderRadius.circular(10),
          //             ),
          //           ),
          //         ),
          //       ),
          //       IconButton(
          //           icon: const Icon(Icons.send),
          //           onPressed: () async {
          //             await sendMessage(widget.receiverId);
          //             stopTyping(widget.receiverId);
          //           })
          //     ],
          //   ),
          // ),
          Container(
            margin: const EdgeInsets.all(8.0),
            padding:
                const EdgeInsets.only(right: 8.0, left: 8, top: 6, bottom: 6),
            decoration: BoxDecoration(
                color: const Color(0xFFFFC9E0).withOpacity(0.2),
                border: Border.all(color: Colors.grey.shade300, width: 1),
                borderRadius: BorderRadius.circular(16)),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: chatController.messageController,
                    cursorColor: black,
                    style: TextStyle(color: black),
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        startTyping(widget.receiverId);
                      } else {
                        stopTyping(widget.receiverId);
                      }
                    },
                    decoration: InputDecoration(
                        isDense: true,
                        hintText: "Type a message",
                        hintStyle: GoogleFonts.roboto(color: black),
                        border: InputBorder.none),
                  ),
                ),
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: () async {
                    await sendMessage(widget.receiverId);
                    stopTyping(widget.receiverId);
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                            colors: [appColorP, appColorP, appColorR],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight)),
                    child: Icon(
                      Icons.send,
                      color: white,
                      size: 24,
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  sendMessage(String receiverId) {
    if (chatController.messageController.text.trim().isEmpty) return;

    chatService.socket.emit('send-message', {
      'receiverId': receiverId,
      'content': chatController.messageController.text.trim()
    });

    chatController.messageController.clear();
  }

  fetchPreviousMessages() {
    chatService.socket.emit('fetch-previous-messages', {
      'receiverId': widget.receiverId,
      'limit': 20,
    });
  }

  void startTyping(String receiverId) {
    chatService.socket.emit('typing-start', {'receiverId': receiverId});
  }

  void stopTyping(String receiverId) {
    chatService.socket.emit('typing-stop', {'receiverId': receiverId});
  }

  String formatDate(String inputDate) {
    try {
      DateTime dateTime = DateTime.parse(inputDate);
      DateTime now = DateTime.now();
      // String outputDate = DateFormat('hh:mm a').format(dateTime);
      // return outputDate;
      if (dateTime.year == now.year &&
          dateTime.month == now.month &&
          dateTime.day == now.day) {
        return DateFormat('hh:mm a').format(dateTime);
      } else if (dateTime.year == now.year) {
        return DateFormat('dd-MMM hh:mm a').format(dateTime);
      } else {
        return DateFormat('dd-MMM-yyyy hh:mm a').format(dateTime);
      }
    } catch (e) {
      print('Invalid date format: $e');
      return 'Invalid Date';
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
}
