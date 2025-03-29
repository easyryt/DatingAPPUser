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
  const MessagesScreen({
    super.key,
    required this.receiverId,
    required this.name,
  });

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final ChatController chatController = Get.put(ChatController());
  final ScrollController _scrollController = ScrollController();
  MainApplicationController mainApplicationController = Get.find();
  List<String> messageIds = [];

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

  _markUnseenMessagesAsSeen() {
    List<String> unseenMessageIds = [];
    for (var message in chatController.messages) {
      if (message.status != "seen" && message.senderType == "partner") {
        unseenMessageIds.add(message.id);
      }
    }
    if (unseenMessageIds.isNotEmpty) {
      markMessagesAsSeen(unseenMessageIds);
    }
  }

  @override
  void initState() {
    initFunction();
    chatService.socket.on('new-messageA', (data) {
      chatController.messages.add(Message.fromJson(data));
      messageIds.clear();
      if (data["senderType"] != "user") {
        messageIds.add(data["_id"]);
        markMessagesAsSeen(messageIds);
      }
      _scrollToBottom();
    });
    // chatService.socket.on('message-sent', (data) {
    //   chatController.messages.add(Message.fromJson(data));
    //   _scrollToBottom();
    // });

    chatService.socket.on('typing-start', (data) {
      chatController.isTyping.value = true;
    });

    chatService.socket.on('typing-stop', (data) {
      chatController.isTyping.value = false;
    });

    // chatService.socket.on('message-status', (data) {
    //   print(data);
    // });

    chatService.socket.on('message-status', (data) {
      var messageIds;
      final status = data['status'];
      if (data['status'] == "delivered") {
        messageIds = data['messageId'];
      } else {
        for (var messageId in data['messageIds']) {
          messageIds = messageId;
          final int index = chatController.messages
              .indexWhere((message) => message.id == messageIds);

          if (index != -1) {
            chatController.messages[index].status = status;
            chatController.messages.refresh(); // To update the UI
          }
        }
      }
    });

    chatService.socket.on('previous-messages', (data) async {
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
        await _markUnseenMessagesAsSeen();
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

  @override
  void dispose() {
    chatService.socket.off('new-messageA');
    chatService.socket.off('typing-start');
    chatService.socket.off('typing-stop');
    chatService.socket.off('message-status');
    chatService.socket.off('previous-messages');
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        await chatService.fetchChatList();
        return false;
      },
      child: Scaffold(
        backgroundColor: white,
        appBar: AppBar(
          backgroundColor: white,
          surfaceTintColor: white,
          leading: IconButton(
              onPressed: () async {
                Navigator.pop(context);
                await chatService.fetchChatList();
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
          ),
          actions: [
            IconButton(
                onPressed: () {
                  // Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //         builder: (_) => OutgoingCallScreen(
                  //               id: widget.receiverId,
                  //               name: widget.name,
                  //             )));
                },
                icon: const Icon(
                  Icons.call,
                  size: 20,
                )),
            const SizedBox(width: 10),
          ],
        ),
        body: Container(
          height: height,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [white, white, appColor.withOpacity(0.1)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter)),
          child: Column(
            children: [
              // Expanded(
              //   child: Obx(() => ListView.builder(
              //         itemCount: chatController.messages.length,
              //         controller: _scrollController,
              //         itemBuilder: (context, index) {
              //           var message = chatController.messages[index];
              //           return Align(
              //             alignment: message.senderType == 'user'
              //                 ? Alignment.centerRight
              //                 : Alignment.centerLeft,
              //             child: Container(
              //               padding: const EdgeInsets.symmetric(
              //                   horizontal: 12, vertical: 4),
              //               margin: EdgeInsets.only(
              //                   bottom: 1,
              //                   top: 1,
              //                   left: message.senderType == 'user'
              //                       ? width * 0.1
              //                       : 10,
              //                   right: message.senderType == 'user'
              //                       ? 10
              //                       : width * 0.1),
              //               decoration: BoxDecoration(
              //                 color: message.senderType == 'user'
              //                     ? appColor
              //                     : appColorMessage.withOpacity(0.4),
              //                 borderRadius: BorderRadius.only(
              //                   topLeft: const Radius.circular(10),
              //                   topRight: const Radius.circular(10),
              //                   bottomLeft: message.senderType == 'user'
              //                       ? const Radius.circular(10)
              //                       : Radius.zero,
              //                   bottomRight: message.senderType == 'user'
              //                       ? Radius.zero
              //                       : const Radius.circular(10),
              //                 ),
              //               ),
              //               constraints: BoxConstraints(
              //                 maxWidth: width * 0.85,
              //               ),
              //               child: Column(
              //                 crossAxisAlignment: message.senderType == 'user'
              //                     ? CrossAxisAlignment.end
              //                     : CrossAxisAlignment.start,
              //                 children: [
              //                   Text(
              //                     message.content,
              //                     style: TextStyle(
              //                       fontSize: 15,
              //                       color: message.senderType == 'user'
              //                           ? white
              //                           : black,
              //                     ),
              //                   ),
              //                   // const SizedBox(width: 6),
              //                   Text(
              //                     formatDate(message.createdAt),
              //                     style: TextStyle(
              //                         fontSize: 8,
              //                         color: message.senderType == 'user'
              //                             ? Colors.grey.shade300
              //                             : Colors.grey.shade600),
              //                   ),
              //                 ],
              //               ),
              //             ),
              //           );
              //           // return BubbleSpecialOne(
              //           //   text: message
              //           //       .content, //\n${formatDate(message.createdAt)}',
              //           //   isSender: message.senderType == 'user' ? true : false,
              //           //   color: message.senderType == 'user'
              //           //       ? appColor
              //           //       : appColorMessage.withOpacity(0.6),
              //           //   tail: false,
              //           //   sent: message.senderType == 'user'
              //           //       ? message.status == "sent"
              //           //           ? true
              //           //           : false
              //           //       : false,
              //           //   seen: message.senderType == 'user'
              //           //       ? message.status == "seen"
              //           //           ? true
              //           //           : false
              //           //       : false,
              //           //   delivered: message.senderType == 'user'
              //           //       ? message.status == "delivered"
              //           //           ? true
              //           //           : false
              //           //       : false,
              //           //   textStyle: TextStyle(
              //           //     fontSize: 15,
              //           //     color: message.senderType == 'user' ? white : black,
              //           //   ),
              //           // );
              //         },
              //       )),
              // ),
              Expanded(
                child: Obx(() => ListView.builder(
                      itemCount: chatController.messages.length,
                      controller: _scrollController,
                      // reverse: true,
                      itemBuilder: (context, index) {
                        var message = chatController.messages[index];
                        chatController.conversationId.value =
                            message.conversationId;
                        bool isUser = message.senderType == 'user';
                        bool showDateSeparator = false;
                        if (index == 0) {
                          showDateSeparator = true;
                        } else {
                          DateTime currentMessageDate =
                              DateTime.parse(message.createdAt);
                          DateTime previousMessageDate = DateTime.parse(
                              chatController.messages[index - 1].createdAt);
                          if (currentMessageDate.day !=
                                  previousMessageDate.day ||
                              currentMessageDate.month !=
                                  previousMessageDate.month ||
                              currentMessageDate.year !=
                                  previousMessageDate.year) {
                            showDateSeparator = true;
                          }
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (showDateSeparator)
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: Center(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade300,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      formatDate1(message.createdAt,
                                          showTime: false), // Only show date
                                      style: const TextStyle(
                                          fontSize: 12, color: Colors.black),
                                    ),
                                  ),
                                ),
                              ),
                            Align(
                              alignment: isUser
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Stack(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 4),
                                    margin: EdgeInsets.only(
                                      bottom: 6,
                                      left: isUser ? 50 : 10,
                                      right: isUser ? 10 : 50,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isUser
                                          ? appColor
                                          : appColorMessage.withOpacity(0.6),
                                      borderRadius: BorderRadius.only(
                                        topLeft: const Radius.circular(10),
                                        topRight: const Radius.circular(10),
                                        bottomLeft: isUser
                                            ? const Radius.circular(10)
                                            : Radius.zero,
                                        bottomRight: isUser
                                            ? Radius.zero
                                            : const Radius.circular(10),
                                      ),
                                    ),
                                    constraints: BoxConstraints(
                                      maxWidth:
                                          MediaQuery.of(context).size.width *
                                              0.75,
                                    ),
                                    child: Column(
                                      crossAxisAlignment: isUser
                                          ? CrossAxisAlignment.start
                                          : CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          message.content,
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: isUser
                                                ? Colors.white
                                                : Colors.black,
                                          ),
                                        ),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            const SizedBox(width: 10.0),
                                            Text(
                                              formatDate1(message.createdAt),
                                              style: TextStyle(
                                                fontSize: 5,
                                                color: isUser
                                                    ? appColor
                                                    : appColorMessage
                                                        .withOpacity(0.6),
                                              ),
                                            ),
                                            if (isUser) ...[
                                              const SizedBox(width: 2),
                                              Icon(
                                                  message.status == "seen"
                                                      ? Icons.done_all
                                                      : message.status ==
                                                              "delivered"
                                                          ? Icons.done_all
                                                          : Icons.check,
                                                  size: 10,
                                                  color: appColor),
                                            ],
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Positioned(
                                      bottom: 9,
                                      right: isUser ? 10 : 54,
                                      child: Row(
                                        children: [
                                          Text(
                                            formatDate1(message.createdAt),
                                            style: GoogleFonts.roboto(
                                              color: isUser
                                                  ? Colors.grey.shade300
                                                  : Colors.grey.shade600,
                                              fontSize: 7,
                                            ),
                                          ),
                                          const SizedBox(width: 2.0),
                                          if (isUser) ...[
                                            Icon(
                                              message.status == "seen"
                                                  ? Icons.done_all
                                                  : message.status ==
                                                          "delivered"
                                                      ? Icons.done_all
                                                      : Icons.check,
                                              size: 14,
                                              color: message.status == "seen"
                                                  ? Colors.blue
                                                  : Colors.grey,
                                            ),
                                          ],
                                          const SizedBox(width: 2.0),
                                        ],
                                      ))
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    )),
              ),

              Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 6.0, vertical: 6),
                padding: const EdgeInsets.only(
                    right: 8.0, left: 12, top: 8, bottom: 8),
                decoration: BoxDecoration(
                    color: white,
                    // border: Border.all(color: Colors.grey.shade300, width: 1),
                    borderRadius: BorderRadius.circular(28)),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: chatController.messageController,
                        cursorColor: black,
                        style: TextStyle(color: black),
                        onChanged: (value) {
                          if (value.isNotEmpty) {
                            if (chatController.conversationId.value != "") {
                              startTyping(chatController.conversationId.value);
                            }
                          } else {
                            if (chatController.conversationId.value != "") {
                              stopTyping(chatController.conversationId.value);
                            }
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
                        if (chatController.conversationId.value != "") {
                          stopTyping(chatController.conversationId.value);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6.5),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: LinearGradient(
                                colors: [appColor, appColor, appColorAccent],
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
        ),
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

  // void startTyping(String receiverId) {
  //   chatService.socket.emit('typing-start', {'receiverId': receiverId});
  // }
  //
  // void stopTyping(String receiverId) {
  //   chatService.socket.emit('typing-stop', {'receiverId': receiverId});
  // }

  void startTyping(String conversationId) {
    chatService.socket.emit('typing-start', {'conversationId': conversationId});
  }

  void stopTyping(String conversationId) {
    chatService.socket.emit('typing-stop', {'conversationId': conversationId});
  }

  // markAsSeen(String messagesId) {
  //   chatService.socket.emit('mark-as-seen', {'messageIds ': messagesId});
  // }

  void markMessagesAsSeen(List<String> messageIds) {
    chatService.socket.emit('mark-as-seen', {'messageIds': messageIds});
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

  String formatDate1(String date, {bool showTime = true}) {
    DateTime dateTime = DateTime.parse(date);
    DateTime now = DateTime.now();
    if (showTime) {
      return DateFormat('hh:mm a').format(dateTime);
    } else {
      if (dateTime.year == now.year &&
          dateTime.month == now.month &&
          dateTime.day == now.day) {
        return 'Today';
      } else {
        return DateFormat('dd MMM yyyy').format(dateTime);
      }
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        // _scrollController.animateTo(
        //   _scrollController.position.maxScrollExtent,
        //   duration: const Duration(milliseconds: 300),
        //   curve: Curves.easeOut,
        // );
        _scrollController.jumpTo(
          _scrollController.position.maxScrollExtent,
        );
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
}
