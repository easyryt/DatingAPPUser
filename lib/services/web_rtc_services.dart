import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:gad_fly/constant/api_end_point.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class WebRTCService {
  RTCPeerConnection? peerConnection;
  MediaStream? localStream;
  MediaStream? remoteStream;
  IO.Socket? socket;

  final Map<String, dynamic> configuration = {
    "iceServers": [
      {"urls": "stun:stun.l.google.com:19302"},
      {"urls": "stun:stun1.l.google.com:19302"}
    ]
  };

  Future<void> initWebRTC() async {
    peerConnection = await createPeerConnection(configuration);

    localStream = await navigator.mediaDevices.getUserMedia({
      'audio': true,
      'video': false,
    });

    peerConnection!.onIceCandidate = (RTCIceCandidate candidate) {
      socket!.emit('ice-candidate', {
        'candidate': candidate.toMap(),
      });
    };

    peerConnection!.onAddStream = (MediaStream stream) {
      remoteStream = stream;
    };

    peerConnection!.addStream(localStream!);
  }

  Future<void> connectSocket(String token) async {
    socket = IO.io(ApiEndpoints.baseUrl, <String, dynamic>{
      'transports': ['websocket'],
      'auth': {
        'token': token,
        'userType': "User",
      },
      'autoConnect': false,
    });

    socket!.connect();

    socket!.onConnect((_) {
      print('Connected to socket.io server');
    });

    socket!.on('incoming-call', (data) async {
      print(data);
    });

    socket!.on('call-accepted', (data) async {
      print(data);
    });

    socket!.on('ice-candidate', (data) async {
      final candidate = RTCIceCandidate(
        data['candidate']['candidate'],
        data['candidate']['sdpMid'],
        data['candidate']['sdpMLineIndex'],
      );
      await peerConnection!.addCandidate(candidate);
    });
  }

  Future<void> initiateCall(String partnerId) async {
    final offer = await peerConnection!.createOffer();
    await peerConnection!.setLocalDescription(offer);
    socket!.emit('initiate-call', {
      'partnerId': partnerId,
      'offer': offer.toMap(),
    });
  }

  Future<void> acceptCall(String callId, RTCSessionDescription offer) async {
    await peerConnection!.setRemoteDescription(offer);
    final answer = await peerConnection!.createAnswer();
    await peerConnection!.setLocalDescription(answer);
    socket!.emit('accept-call', {
      'callId': callId,
      'answer': answer.toMap(),
    });
  }

  Future<void> disconnect() async {
    await peerConnection!.close();
    socket!.disconnect();
  }
}

// import 'package:flutter_webrtc/flutter_webrtc.dart';
// import 'package:gad_fly/constant/api_end_point.dart';
// import 'package:socket_io_client/socket_io_client.dart' as IO;
//
// class CallManager {
//   late RTCPeerConnection _peerConnection;
//   late IO.Socket _socket;
//   String? _currentCallId;
//   Function(dynamic)? onIncomingCall;
//
//   Future<void> initialize(String authToken) async {
//     _socket = IO.io(ApiEndpoints.baseUrl, {
//       'transports': ['websocket'],
//       'autoConnect': false,
//       'auth': {'token': authToken, 'userType': "User"}
//     });
//
//     _socket.connect();
//     _setupSocketListeners();
//   }
//
//   void _setupSocketListeners() {
//     _socket.on('offer', (data) => _handleOffer(data));
//     _socket.on('answer', (data) => _handleAnswer(data));
//     _socket.on('ice-candidate', (data) => _handleIceCandidate(data));
//     _socket.on('incoming-call', (data) => _handleIncomingCall(data));
//   }
//
//   Future<void> _createPeerConnection() async {
//     final configuration = {
//       'iceServers': [
//         {'urls': 'stun:stun.l.google.com:19302'},
//       ]
//     };
//
//     _peerConnection = await createPeerConnection(configuration);
//
//     _peerConnection.onIceCandidate = (candidate) {
//       if (candidate != null) {
//         _socket.emit('ice-candidate', {
//           'callId': _currentCallId,
//           'candidate': {
//             'candidate': candidate.candidate,
//             'sdpMid': candidate.sdpMid,
//             'sdpMLineIndex': candidate.sdpMLineIndex,
//           }
//         });
//       }
//     };
//
//     _peerConnection.onAddStream = (stream) {
//       // Handle remote stream
//     };
//   }
//
//   Future<void> initiateCall(String partnerId) async {
//     await _createPeerConnection();
//
//     // Get call ID from your existing call initiation flow
//     _socket.emit('initiate-call', {'partnerId': partnerId});
//   }
//
//   Future<void> _handleOffer(dynamic data) async {
//     final offer = RTCSessionDescription(data['sdp'], data['type']);
//     await _peerConnection.setRemoteDescription(offer);
//
//     final answer = await _peerConnection.createAnswer();
//     await _peerConnection.setLocalDescription(answer);
//
//     _socket
//         .emit('answer', {'callId': _currentCallId, 'answer': answer.toMap()});
//   }
//
//   Future<void> _handleAnswer(dynamic data) async {
//     final answer = RTCSessionDescription(data['sdp'], data['type']);
//     await _peerConnection.setRemoteDescription(answer);
//   }
//
//   Future<void> _handleIceCandidate(dynamic data) async {
//     final candidate = RTCIceCandidate(
//       data['candidate'],
//       data['sdpMid'],
//       data['sdpMLineIndex'],
//     );
//     await _peerConnection.addCandidate(candidate);
//   }
//
//   Future<void> acceptCall(String callId) async {
//     _currentCallId = callId;
//     await _createPeerConnection();
//     _socket.emit('accept-call', {'callId': callId});
//   }
//
//   Future<void> endCall() async {
//     await _peerConnection.close();
//     _socket.emit('end-call', {'callId': _currentCallId});
//     _currentCallId = null;
//   }
//
//   void _handleIncomingCall(dynamic data) {
//     if (onIncomingCall != null) {
//       onIncomingCall!(data);
//     }
//   }
//
// // Add media stream handling and UI integration as needed
// }
//
// // // import 'package:flutter_webrtc/flutter_webrtc.dart';
// // // import 'package:gad_fly/constant/api_end_point.dart';
// // // import 'package:socket_io_client/socket_io_client.dart' as IO;
// // //
// // // class CallService {
// // //   late IO.Socket socket;
// // //   RTCPeerConnection? peerConnection;
// // //   MediaStream? localStream;
// // //
// // //   final Map<String, dynamic> configuration = {
// // //     "iceServers": [
// // //       {"urls": "stun:stun.l.google.com:19302"},
// // //       {"urls": "stun:stun1.l.google.com:19302"}
// // //     ]
// // //   };
// // //
// // //   void connectSocket(String token) {
// // //     socket = IO.io(ApiEndpoints.baseUrl, <String, dynamic>{
// // //       'transports': ['websocket'],
// // //       'auth': {
// // //         'token': token,
// // //         'userType': "User",
// // //       },
// // //     });
// // //
// // //     socket.connect();
// // //     socket.onConnect((_) {
// // //       print("Connected to socket server");
// // //     });
// // //
// // //     socket.on("call-initiated", (data) {
// // //       print("You have an incoming call!");
// // //     });
// // //
// // //     socket.on("call-accepted", (_) {
// // //       print("Call Accepted, Starting WebRTC");
// // //       startCall();
// // //     });
// // //
// // //     socket.on("offer", (data) async {
// // //       print("Received Offer");
// // //       await peerConnection?.setRemoteDescription(
// // //         RTCSessionDescription(data["sdp"], data["type"]),
// // //       );
// // //       answerCall();
// // //     });
// // //
// // //     socket.on("answer", (data) async {
// // //       print("Received Answer");
// // //       await peerConnection?.setRemoteDescription(
// // //         RTCSessionDescription(data["sdp"], data["type"]),
// // //       );
// // //     });
// // //
// // //     socket.on("ice-candidate", (data) async {
// // //       print("Received ICE Candidate");
// // //       await peerConnection?.addCandidate(
// // //         RTCIceCandidate(
// // //             data["candidate"], data["sdpMid"], data["sdpMLineIndex"]),
// // //       );
// // //     });
// // //
// // //     socket.onDisconnect((_) {
// // //       print("Disconnected from socket server");
// // //     });
// // //   }
// // //
// // //   void initiateCall(String partnerId) {
// // //     socket.emit("initiate-call", {"partnerId": partnerId});
// // //   }
// // //
// // //   Future<void> startCall() async {
// // //     peerConnection = await createPeerConnection(configuration);
// // //     localStream = await navigator.mediaDevices
// // //         .getUserMedia({"video": false, "audio": true});
// // //     peerConnection!.addStream(localStream!);
// // //
// // //     peerConnection!.onIceCandidate = (candidate) {
// // //       socket.emit("ice-candidate", {
// // //         "candidate": candidate.candidate,
// // //         "sdpMid": candidate.sdpMid,
// // //         "sdpMLineIndex": candidate.sdpMLineIndex,
// // //       });
// // //     };
// // //
// // //     final offer = await peerConnection!.createOffer();
// // //     await peerConnection!.setLocalDescription(offer);
// // //     socket.emit("offer", {"sdp": offer.sdp, "type": offer.type});
// // //   }
// // //
// // //   Future<void> answerCall() async {
// // //     peerConnection = await createPeerConnection(configuration);
// // //     localStream = await navigator.mediaDevices
// // //         .getUserMedia({"video": false, "audio": true});
// // //     peerConnection!.addStream(localStream!);
// // //
// // //     peerConnection!.onIceCandidate = (candidate) {
// // //       socket.emit("ice-candidate", {
// // //         "candidate": candidate.candidate,
// // //         "sdpMid": candidate.sdpMid,
// // //         "sdpMLineIndex": candidate.sdpMLineIndex,
// // //       });
// // //     };
// // //
// // //     final answer = await peerConnection!.createAnswer();
// // //     await peerConnection!.setLocalDescription(answer);
// // //     socket.emit("answer", {"sdp": answer.sdp, "type": answer.type});
// // //   }
// // //
// // //   void endCall() {
// // //     peerConnection?.close();
// // //     peerConnection = null;
// // //     localStream?.dispose();
// // //     socket.emit("end-call");
// // //   }
// // // }
// // ///
// // import 'package:flutter/foundation.dart';
// // import 'package:flutter_webrtc/flutter_webrtc.dart';
// // import 'package:gad_fly/constant/api_end_point.dart';
// // import 'package:socket_io_client/socket_io_client.dart' as IO;
// //
// // class ChatService {
// //   late IO.Socket socket;
// //   RTCPeerConnection? peerConnection;
// //   MediaStream? localStream;
// //   final Map<String, dynamic> configuration = {
// //     "iceServers": [
// //       {"urls": "stun:stun.l.google.com:19302"},
// //       {"urls": "stun:stun1.l.google.com:19302"}
// //     ]
// //   };
// //
// //   void connect(context, String? token, String? rideId,
// //       Function(Map<String, dynamic>)? onMessageReceived, isUpdateLocation) {
// //     socket =
// //     //  IO.io('https://rapidoappbackenduser.onrender.com', <String, dynamic>{
// //     IO.io(ApiEndpoints.baseUrl, <String, dynamic>{
// //       'transports': ['websocket'],
// //       'auth': {
// //         'token': token,
// //         'userType': "User",
// //       },
// //       'autoConnect': false,
// //     });
// //
// //     socket.connect();
// //
// //     socket.onConnect((_) {
// //       if (kDebugMode) {
// //         print('Connected to socket.io server');
// //       }
// //       requestPartnerList();
// //     });
// //
// //     // socket.onReconnect((_) {
// //     //   if (kDebugMode) {
// //     //     print('Re Connected to socket.io server');
// //     //   }
// //     // });
// //
// //     socket.on('error', (data) async {
// //       // if (kDebugMode) {
// //       //   print(data);
// //       //   Get.snackbar("Error", data["message"].toString());
// //       // }
// //       if (kDebugMode) {
// //         try {
// //           print(data);
// //           //  Get.snackbar("Error", data["message"].toString());
// //         } catch (error) {
// //           print("Error accessing driverId: $error");
// //           //  Get.snackbar("An error occurred", "Please try again later.");
// //         }
// //       }
// //     });
// //
// //     socket.on('getListOfPartnerResponse', (data) async {
// //       if (kDebugMode) {
// //         print(data);
// //       }
// //       onMessageReceived!(data);
// //     });
// //
// //     socket.on("call-initiated", (data) {
// //       print("You have an incoming call!");
// //     });
// //
// //     socket.on("call-accepted", (_) {
// //       print("Call Accepted, Starting WebRTC");
// //       startCall();
// //     });
// //
// //     socket.on("offer", (data) async {
// //       print("Received Offer");
// //       await peerConnection?.setRemoteDescription(
// //         RTCSessionDescription(data["sdp"], data["type"]),
// //       );
// //       answerCall();
// //     });
// //
// //     socket.on("answer", (data) async {
// //       print("Received Answer");
// //       await peerConnection?.setRemoteDescription(
// //         RTCSessionDescription(data["sdp"], data["type"]),
// //       );
// //     });
// //
// //     socket.on("ice-candidate", (data) async {
// //       print("Received ICE Candidate");
// //       await peerConnection?.addCandidate(
// //         RTCIceCandidate(
// //             data["candidate"], data["sdpMid"], data["sdpMLineIndex"]),
// //       );
// //     });
// //
// //     socket.onDisconnect((_) {
// //       if (kDebugMode) {
// //         print('Disconnected from socket.io server');
// //       }
// //     });
// //   }
// //
// //   void disconnect() {
// //     socket.disconnect();
// //   }
// //
// //   void requestPartnerList() {
// //     socket.emit('getListOfPartner');
// //   }
// //
// //   void initiateCall(String partnerId) {
// //     socket.emit("initiate-call", {"partnerId": partnerId});
// //   }
// //
// //   Future startCall() async {
// //     peerConnection = await createPeerConnection(configuration);
// //     localStream = await navigator.mediaDevices
// //         .getUserMedia({"video": false, "audio": true});
// //     peerConnection!.addStream(localStream!);
// //
// //     peerConnection!.onIceCandidate = (candidate) {
// //       socket.emit("ice-candidate", {
// //         "candidate": candidate.candidate,
// //         "sdpMid": candidate.sdpMid,
// //         "sdpMLineIndex": candidate.sdpMLineIndex,
// //       });
// //     };
// //
// //     final offer = await peerConnection!.createOffer();
// //     await peerConnection!.setLocalDescription(offer);
// //     socket.emit("offer", {"sdp": offer.sdp, "type": offer.type});
// //   }
// //
// //   Future<void> answerCall() async {
// //     peerConnection = await createPeerConnection(configuration);
// //     localStream = await navigator.mediaDevices
// //         .getUserMedia({"video": false, "audio": true});
// //     peerConnection!.addStream(localStream!);
// //
// //     peerConnection!.onIceCandidate = (candidate) {
// //       socket.emit("ice-candidate", {
// //         "candidate": candidate.candidate,
// //         "sdpMid": candidate.sdpMid,
// //         "sdpMLineIndex": candidate.sdpMLineIndex,
// //       });
// //     };
// //
// //     final answer = await peerConnection!.createAnswer();
// //     await peerConnection!.setLocalDescription(answer);
// //     socket.emit("answer", {"sdp": answer.sdp, "type": answer.type});
// //   }
// //
// //   void endCall() {
// //     peerConnection?.close();
// //     peerConnection = null;
// //     localStream?.dispose();
// //     socket.emit("end-call");
// //   }
// // }
