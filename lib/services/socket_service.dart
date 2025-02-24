import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:gad_fly/constant/api_end_point.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatService {
  late IO.Socket socket;
  RTCPeerConnection? peerConnection;
  MediaStream? localStream;
  final Map<String, dynamic> configuration = {
    "iceServers": [
      {"urls": "stun:stun.l.google.com:19302"},
      //  {"urls": "stun:stun1.l.google.com:19302"}
    ]
  };

  void connect(context, String? token,
      Function(Map<String, dynamic>)? onMessageReceived) {
    socket = IO.io(ApiEndpoints.baseUrl, <String, dynamic>{
      'transports': ['websocket'],
      'auth': {
        'token': token,
        'userType': "User",
      },
      'autoConnect': false,
    });

    socket.connect();

    socket.onConnect((_) {
      if (kDebugMode) {
        print('Connected to socket.io server');
      }
      requestPartnerList();
    });

    // socket.onReconnect((_) {
    //   if (kDebugMode) {
    //     print('Re Connected to socket.io server');
    //   }
    // });

    socket.on('error', (data) async {
      // if (kDebugMode) {
      //   print(data);
      //   Get.snackbar("Error", data["message"].toString());
      // }
      if (kDebugMode) {
        try {
          print(data);
          //  Get.snackbar("Error", data["message"].toString());
        } catch (error) {
          print("Error accessing driverId: $error");
          //  Get.snackbar("An error occurred", "Please try again later.");
        }
      }
    });

    socket.on('getListOfPartnerResponse', (data) async {
      if (kDebugMode) {
        print(data);
      }
      onMessageReceived!(data);
    });

    // socket.on('incoming-call', (data) {
    //   print('Incoming call from: ${data['caller']}');
    // });

    socket.on('call-initiated', (data) {
      print('Call initiated with ID: ${data['callId']}');
    });

    socket.on('offer', (data) async {
      print('Received offer');
      await _handleOffer(data['offer']);
    });

    socket.on('answer', (data) async {
      print('Received answer');
      await peerConnection?.setRemoteDescription(
          RTCSessionDescription(data['answer'], 'answer'));
    });

    socket.on('ice-candidate', (data) async {
      print('Received ICE candidate');
      await peerConnection?.addCandidate(
        RTCIceCandidate(data['candidate']['candidate'],
            data['candidate']['sdpMid'], data['candidate']['sdpMLineIndex']),
      );
    });

    socket.on('call-ended', (_) {
      print('Call ended');
      _endCall();
    });

    socket.onDisconnect((_) {
      if (kDebugMode) {
        print('Disconnected from socket.io server');
      }
    });
  }

  void disconnect() {
    socket.disconnect();
  }

  void requestPartnerList() {
    socket.emit('getListOfPartner');
  }

  Future<void> initiateCall(String partnerId) async {
    socket.emit('initiate-call', {'partnerId': partnerId});
  }

  Future<void> acceptCall(String callId) async {
    socket.emit('accept-call', {'callId': callId});
    await _setupWebRTC();
  }

  Future<void> _setupWebRTC() async {
    peerConnection = await createPeerConnection(configuration);
    localStream = await navigator.mediaDevices.getUserMedia({
      'audio': true,
      'video': true,
    });
    localStream?.getTracks().forEach((track) {
      peerConnection?.addTrack(track, localStream!);
    });

    peerConnection?.onIceCandidate = (candidate) {
      socket.emit('ice-candidate', {'candidate': candidate.toMap()});
    };

    peerConnection?.onTrack = (event) {
      // TODO: Attach remote video stream to UI
    };
  }

  Future<void> _handleOffer(String offer) async {
    await _setupWebRTC();
    await peerConnection
        ?.setRemoteDescription(RTCSessionDescription(offer, 'offer'));
    RTCSessionDescription answer = await peerConnection!.createAnswer();
    await peerConnection!.setLocalDescription(answer);
    socket.emit('answer', {'answer': answer.sdp});
  }

  void endCall(String callId) {
    socket.emit('end-call', {'callId': callId});
    _endCall();
  }

  void _endCall() {
    peerConnection?.close();
    localStream?.dispose();
    peerConnection = null;
    localStream = null;
  }
}
