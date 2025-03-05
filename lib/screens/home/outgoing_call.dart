// import 'package:flutter/material.dart';
// import 'package:flutter_webrtc/flutter_webrtc.dart';
// import 'package:gad_fly/controller/main_application_controller.dart';
// import 'package:gad_fly/screens/home/home_page.dart';
// import 'package:gad_fly/services/socket_service.dart';
// import 'package:get/get.dart';
//
// class OutgoingCallScreen extends StatefulWidget {
//   final String id;
//   final String name;
//   const OutgoingCallScreen({
//     super.key,
//     required this.id,
//     required this.name,
//   });
//
//   @override
//   State<OutgoingCallScreen> createState() => _OutgoingCallScreenState();
// }
//
// class _OutgoingCallScreenState extends State<OutgoingCallScreen> {
//   ChatService chatService = ChatService();
//   MainApplicationController mainApplicationController = Get.find();
//   MediaStream? remoteStream;
//   bool isCallConnected = false;
//
//   initFunction() async {
//     if (mainApplicationController.authToken.value != "") {
//       await chatService.connect(
//         context,
//         mainApplicationController.authToken.value,
//         _onRequestAccepted,
//         (MediaStream stream) {
//           if (mounted) {
//             setState(() {
//               remoteStream = stream;
//             });
//           }
//           print("Remote stream received");
//         },
//       );
//       // await chatService.initiateCall(widget.id, context);
//     }
//   }
//
//   @override
//   void initState() {
//     initFunction();
//     super.initState();
//     chatService.socket.on('call-accepted', (_) {
//       setState(() {
//         isCallConnected = true;
//       });
//     });
//
//     chatService.socket.on('call-rejected', (_) {
//       chatService.disconnect();
//       mainApplicationController.partnerList.clear();
//       Navigator.push(
//           context, MaterialPageRoute(builder: (_) => const HomePage()));
//     });
//
//     chatService.socket.on('call-ended', (_) {
//       chatService.disconnect();
//       mainApplicationController.partnerList.clear();
//       Navigator.push(
//           context, MaterialPageRoute(builder: (_) => const HomePage()));
//     });
//   }
//
//   void _onRequestAccepted(Map<String, dynamic> data) async {
//     mainApplicationController.partnerList.clear();
//     if (data.containsKey('data')) {
//       final List<dynamic> noteData = data['data'];
//       List<Map<String, dynamic>> dataList =
//           noteData.map((data) => data as Map<String, dynamic>).toList();
//       mainApplicationController.partnerList.value = dataList;
//     } else {
//       throw Exception('Invalid response format: "data" field not found');
//     }
//   }
//
//   @override
//   void dispose() {
//     chatService.disconnect();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async {
//         await chatService.disconnect();
//         mainApplicationController.partnerList.clear();
//         Navigator.push(
//             context, MaterialPageRoute(builder: (_) => const HomePage()));
//         return false;
//       },
//       child: Scaffold(
//         backgroundColor: Colors.white,
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Text(
//                 isCallConnected ? "Connected" : "Partner Calling...",
//                 style:
//                     const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 20),
//               Text(
//                 "${widget.name} ",
//                 style: const TextStyle(fontSize: 18),
//               ),
//               const SizedBox(height: 40),
//               ElevatedButton(
//                 onPressed: () async {
//                   if (chatService.currentCallId != null) {
//                     chatService.endCall();
//                   } else {
//                     await chatService.disconnect();
//                     mainApplicationController.partnerList.clear();
//                     Navigator.push(context,
//                         MaterialPageRoute(builder: (_) => const HomePage()));
//                   }
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.red,
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
//                 ),
//                 child: const Text(
//                   "End Call",
//                   style: TextStyle(fontSize: 18, color: Colors.white),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
