// import 'package:flutter/material.dart';
// import 'package:gad_fly/controller/main_application_controller.dart';
// import 'package:gad_fly/services/web_rtc_services.dart';
// import 'package:get/get.dart';
//
// class CallDialog extends StatelessWidget {
//   final dynamic caller;
//   final VoidCallback onAccept;
//   final VoidCallback onReject;
//
//   const CallDialog({
//     super.key,
//     required this.caller,
//     required this.onAccept,
//     required this.onReject,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       title: const Text('Incoming Call'),
//       content:
//           Text('Incoming call from ${caller['name']}'), // Access caller info
//       actions: <Widget>[
//         TextButton(
//           onPressed: onReject,
//           child: const Text('Reject'),
//         ),
//         TextButton(
//           onPressed: onAccept,
//           child: const Text('Accept'),
//         ),
//       ],
//     );
//   }
// }
//
// // Example usage in your UI widget
// class MyCallScreen extends StatefulWidget {
//   const MyCallScreen({super.key});
//
//   @override
//   State<MyCallScreen> createState() => _MyCallScreenState();
// }
//
// class _MyCallScreenState extends State<MyCallScreen> {
//   MainApplicationController mainApplicationController = Get.find();
//   final CallManager _callManager = CallManager();
//
//   @override
//   void initState() {
//     super.initState();
//     // Initialize the call manager
//     _callManager.initialize(mainApplicationController.authToken.value);
//     _callManager.onIncomingCall = (data) {
//       showDialog(
//         context: context, // Now we have context!
//         builder: (context) => CallDialog(
//           caller: data['caller'], // Access caller info from data
//           onAccept: () {
//             Navigator.of(context).pop(); // Close the dialog
//             _callManager.acceptCall(data['callId']);
//           },
//           onReject: () {
//             Navigator.of(context).pop(); // Close the dialog
//             _callManager.endCall();
//           },
//         ),
//       );
//     };
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(),
//         body: Center(
//           child: ElevatedButton(
//             onPressed: () {
//               _callManager.initiateCall("partnerId");
//             },
//             child: const Text("Call"),
//           ),
//         ));
//   }
// }
//
// // import 'package:flutter/material.dart';
// // import 'package:gad_fly/services/socket_service.dart';
// //
// // class CallScreen extends StatefulWidget {
// //   final ChatService callService;
// //   const CallScreen({super.key, required this.callService});
// //
// //   @override
// //   _CallScreenState createState() => _CallScreenState();
// // }
// //
// // class _CallScreenState extends State<CallScreen> {
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(title: const Text("Audio Call")),
// //       body: Center(
// //         child: Column(
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           children: [
// //             const Icon(Icons.call, size: 100, color: Colors.green),
// //             const SizedBox(height: 20),
// //             ElevatedButton(
// //               onPressed: widget.callService.endCall,
// //               child: const Text("End Call"),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }
