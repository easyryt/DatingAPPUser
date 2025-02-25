import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:gad_fly/constant/api_end_point.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatService {
  late IO.Socket socket;
  RTCPeerConnection? peerConnection;
  MediaStream? localStream;
  Function(MediaStream)? onRemoteStream;
  String? currentCallId;
  final Map<String, dynamic> configuration = {
    "iceServers": [
      {"urls": "stun:stun.l.google.com:19302"},
      {"urls": "stun:stun1.l.google.com:19302"}
    ]
  };

  void connect(
      context,
      String? token,
      Function(Map<String, dynamic>)? onMessageReceived,
      Function(MediaStream) onRemoteStream,
      Function(Map<String, dynamic>)? onOfferReceived) {
    this.onRemoteStream = onRemoteStream;
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

    socket.on('call-initiated', (data) async {
      currentCallId = data['callId'];
      print('Call initiated with ID: ${data['callId']}');
      // onOfferReceived!(data);

      await setupWebRTC(isCaller: true);
      await createAndSendOffer();
    });

    // socket.on('offer', (data) async {
    //   print('Received offer');
    //   await _handleOffer(data['offer']);
    // });

    socket.on('answer', (data) async {
      print('Received answer');
      // print("received Answer: ${data.sdp}");
      await peerConnection
          ?.setRemoteDescription(RTCSessionDescription(data, 'answer'));
    });

    socket.on('ice-candidate', (data) async {
      print('Received ICE candidate');
      await peerConnection?.addCandidate(
        RTCIceCandidate(
            data['candidate'], data['sdpMid'], data['sdpMLineIndex']),
      );
      // await peerConnection?.addCandidate(candidate);
    });

    socket.on('call-ended', (_) {
      print('Call ended');
      endCalls();
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

  Future<void> initiateCall(String partnerId, context) async {
    socket.emit('initiate-call', {'partnerId': partnerId});
    // Navigator.push(
    //     context, MaterialPageRoute(builder: (_) => OutgoingCallScreen()));
  }

  // Future<void> acceptCall(String callId) async {
  //   socket.emit('accept-call', {'callId': callId});
  //   //  await _setupWebRTC();
  // }

  Future<void> setupWebRTC({required bool isCaller}) async {
    peerConnection = await createPeerConnection(configuration);
    // localStream = await navigator.mediaDevices.getUserMedia({
    //   'audio': true,
    //   'video': false,
    // });
    // localStream?.getAudioTracks().forEach((track) {
    //   peerConnection?.addTrack(track, localStream!);
    // });
    try {
      localStream = await navigator.mediaDevices.getUserMedia({
        'audio': true,
        'video': false,
      });

      localStream?.getAudioTracks().forEach((track) {
        //  print("Remote track: ${track.id}, enabled: ${track.enabled}");
        peerConnection?.addTrack(track, localStream!);
      });
    } catch (e) {
      print("Error getting user media: $e");
      return; // Stop setup if media access fails
    }

    peerConnection?.onIceCandidate = (candidate) {
      socket.emit('ice-candidate',
          {'callId': currentCallId, 'candidate': candidate.toMap()});
    };

    peerConnection?.onTrack = (event) {
      if (event.track.kind == 'audio' && event.streams.isNotEmpty) {
        onRemoteStream?.call(event.streams[0]);
      }
    };
  }

  Future<void> createAndSendOffer() async {
    RTCSessionDescription offer = await peerConnection!.createOffer();
    await peerConnection!.setLocalDescription(offer);
    socket.emit('offer', {'callId': currentCallId, 'offer': offer.sdp});
    //  print("Sending Offer: ${offer.sdp}");
  }

  // Future<void> _handleOffer(String offer) async {
  //   await peerConnection!
  //       .setRemoteDescription(RTCSessionDescription(offer, 'offer'));
  //   RTCSessionDescription answer = await peerConnection!.createAnswer();
  //   await peerConnection!.setLocalDescription(answer);
  //   socket.emit('answer', {'callId': currentCallId, 'answer': answer.sdp});
  // }

  void endCall() {
    socket.emit('end-call', {'callId': currentCallId});
  }

  void endCalls() {
    peerConnection?.close();
    localStream?.dispose();
    peerConnection = null;
    localStream = null;
  }
}
