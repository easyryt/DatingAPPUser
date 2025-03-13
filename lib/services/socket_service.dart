import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart' as webrtc;
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:gad_fly/constant/api_end_point.dart';
import 'package:gad_fly/controller/main_application_controller.dart';
import 'package:gad_fly/controller/profile_controller.dart';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatService {
  late IO.Socket socket;
  RTCPeerConnection? peerConnection;
  MediaStream? localStream;
  MediaStreamTrack? localAudioTrack;
  Function(MediaStream)? onRemoteStream;
  MainApplicationController mainApplicationController = Get.find();
  ProfileController profileController = Get.find();
  String? currentCallId;
  final Map<String, dynamic> configuration = {
    "iceServers": [
      {'urls': 'stun:stun.l.google.com:19302'},
      {'urls': 'stun:stun1.l.google.com:19302'},
      {'urls': 'stun:stun2.l.google.com:19302'},
      {
        "url": "stun:global.stun.twilio.com:3478",
        "urls": "stun:global.stun.twilio.com:3478"
      },
      {
        'urls': 'turn:relay1.expressturn.com:3478',
        'username': 'ef8M6WFNY9LISR2PA9',
        'credential': 'GOKTdvE3sYZQ6NRm',
      },
      {
        'urls': 'turn:relay1.expressturn.com:3478',
        'username': 'efR4AAMWMYPFT40U65',
        'credential': 'bLSEHxZk2rbABCG8',
      },
    ]
  };

  connect(
    Function(MediaStream) onRemoteStream,
  ) {
    this.onRemoteStream = onRemoteStream;
    socket = IO.io(ApiEndpoints.baseUrl, <String, dynamic>{
      'transports': ['websocket'],
      'auth': {
        'token': mainApplicationController.authToken.value,
        'userType': "User",
      },
      'autoConnect': false,
    });

    socket.connect();

    socket.onConnect((_) {
      if (kDebugMode) {
        print('Connected to socket.io server');
      }
      // requestPartnerList();
    });

    socket.on('error', (data) async {
      if (kDebugMode) {
        try {
          print(data);
          Get.snackbar("Error", data["message"].toString());
        } catch (error) {
          print("Error accessing driverId: $error");
          Get.snackbar("An error occurred", "Please try again later.");
        }
      }
    });

    socket.on('getListOfPartnerResponse', (data) async {
      if (kDebugMode) {
        print(data);
      }
      //  onMessageReceived!(data);
      mainApplicationController.partnerList.clear();
      if (data.containsKey('data')) {
        final List<dynamic> noteData = data['data'];
        List<Map<String, dynamic>> dataList =
            noteData.map((data) => data as Map<String, dynamic>).toList();
        mainApplicationController.partnerList.value = dataList;
      } else {
        throw Exception('Invalid response format: "data" field not found');
      }
    });

    socket.on("toggleResponse", (data) async {
      print(data);
    });

    socket.on('wallet-update', (data) async {
      if (kDebugMode) {
        print(data);
      }
      if (data.containsKey("walletAmount")) {
        profileController.amount.value =
            double.parse("${data["walletAmount"]}");
      }
    });
    socket.on('join-room', (data) async {
      if (kDebugMode) {
        print(data);
      }
    });
    socket.on('chat-list-update', (data) async {
      if (kDebugMode) {
        print(data);
      }
    });

    socket.on('answer', (data) async {
      print('Received........... answer...............');
      await peerConnection?.setRemoteDescription(
          RTCSessionDescription(data["answer"]['sdp'], data["answer"]['type']));
      // if (peerConnection?.signalingState ==
      //     RTCSignalingState.RTCSignalingStateHaveLocalOffer) {
      //   print('Received answer');
      //   await peerConnection?.setRemoteDescription(RTCSessionDescription(
      //       data["answer"]['sdp'], data["answer"]['type']));
      // } else {
      //   print(
      //       'Ignoring answer as peerConnection is not in HaveLocalOffer state.');
      // }
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
      endCalls();
    });

    socket.onDisconnect((_) {
      if (kDebugMode) {
        print('Disconnected from socket.io server');
      }
    });
  }

  disconnect() {
    socket.disconnect();
  }

  requestPartnerList() {
    socket.emit('getListOfPartner');
  }

  Future<void> initiateCall(String partnerId) async {
    socket.emit('initiate-call', {'partnerId': partnerId});
  }

  bool _isLoudspeakerOn = false;
  Future<void> toggleLoudspeaker(bool isLoudspeakerOn) async {
    try {
      await webrtc.Helper.setSpeakerphoneOn(isLoudspeakerOn);
      _isLoudspeakerOn = isLoudspeakerOn;
      print('Loudspeaker is ${isLoudspeakerOn ? 'ON' : 'OFF'}');
    } catch (e) {
      print('Error toggling loudspeaker: $e');
    }
  }

  void toggleMicrophone(bool isMuted) {
    if (localAudioTrack != null) {
      localAudioTrack!.enabled = !isMuted;
    }
  }

  Future<void> setupWebRTC() async {
    try {
      await endCalls();
      peerConnection = await createPeerConnection(configuration);

      await peerConnection!.setConfiguration({
        'iceTransportPolicy': 'all',
        'bundlePolicy': 'max-bundle',
        'rtcpMuxPolicy': 'require',
        'audioJitterBufferMaxPackets': 100,
        'audioJitterBufferFastAccelerate': true,
      });

      final mediaConstraints = {
        'audio': true,
        'video': false,
      };

      localStream =
          await webrtc.navigator.mediaDevices.getUserMedia(mediaConstraints);
      if (localStream == null) {
        print('⚠️ Failed to get local ........... stream................');
        return;
      }
      localAudioTrack = localStream!.getAudioTracks().first;

      //  peerConnection = await createPeerConnection(configuration);

      // peerConnection!.addStream(localStream!);

      localStream?.getAudioTracks().forEach((track) {
        peerConnection?.addTrack(track, localStream!);
      });

      peerConnection?.onTrack = (event) {
        if (event.track.kind == 'audio' && event.streams.isNotEmpty) {
          onRemoteStream?.call(event.streams.first);
        }
      };

      peerConnection?.onIceCandidate = (candidate) {
        socket.emit('ice-candidate',
            {'callId': currentCallId, 'candidate': candidate.toMap()});
      };
    } catch (e) {
      print("Error getting user media: $e");
      return;
    }
    // try {
    //   await endCalls();
    //   localStream = await webrtc.navigator.mediaDevices.getUserMedia({
    //     'audio': true, // Request audio only
    //     'video': false,
    //   });
    //
    //   localAudioTrack = localStream!.getAudioTracks().first;
    //
    //   peerConnection = await createPeerConnection(configuration);
    //
    //   localStream?.getAudioTracks().forEach((track) {
    //     peerConnection?.addTrack(track, localStream!);
    //   });
    //
    //   peerConnection?.onTrack = (event) {
    //     if (event.track.kind == 'audio' && event.streams.isNotEmpty) {
    //       onRemoteStream?.call(event.streams.first);
    //     }
    //   };
    //
    //   peerConnection?.onIceCandidate = (candidate) {
    //     socket.emit('ice-candidate',
    //         {'callId': currentCallId, 'candidate': candidate.toMap()});
    //   };
    // } catch (e) {
    //   print("Error getting user media: $e");
    //   return;
    // }
  }

  Future<void> createAndSendOffer() async {
    if (peerConnection == null) {
      await setupWebRTC();
    }

    RTCSessionDescription offer = await peerConnection!.createOffer();
    await peerConnection!.setLocalDescription(offer);

    // while (peerConnection?.signalingState !=
    //     RTCSignalingState.RTCSignalingStateHaveLocalOffer) {
    //   await Future.delayed(const Duration(milliseconds: 100));
    // }

    socket.emit('offer', {
      'callId': currentCallId,
      'offer': {'sdp': offer.sdp, 'type': offer.type},
    });
    print(
        "Offer sent successfully...............|||||||||||......................");
  }

  fetchChatList() {
    socket.emit('fetch-chat-list');
  }

  endCall() {
    socket.emit('end-call', {'callId': currentCallId});
    endCalls();
  }

  endCalls() {
    peerConnection?.close();
    localStream?.dispose();
    peerConnection = null;
    localStream = null;
    localAudioTrack = null;
  }
}
