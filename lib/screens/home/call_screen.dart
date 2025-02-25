import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:gad_fly/constant/api_end_point.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class CallScreen extends StatefulWidget {
  final String partnerId;
  final String token;

  CallScreen({super.key, required this.partnerId, required this.token});

  @override
  _CallScreenState createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  late IO.Socket socket;
  RTCPeerConnection? _peerConnection;
  RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  MediaStream? _localStream;
  String? _callId;

  @override
  void initState() {
    super.initState();
    _initSocket();
    _initWebRTC();
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    _peerConnection?.close();
    socket.disconnect();
    super.dispose();
  }

  void _initSocket() {
    socket = IO.io(ApiEndpoints.baseUrl, <String, dynamic>{
      'transports': ['websocket'],
      'auth': {
        'token': widget.token,
        'userType': "User",
      },
      'autoConnect': true,
    });

    socket.onConnect((_) {
      print('Connected to Socket.IO server');
      // Authenticate the user
      //  socket.emit('authenticate', {'userId': widget.userId});
    });

    socket.on('incoming-call', (data) {
      print('Incoming call from: ${data['caller']}');
      _callId = data['callId'];
      _showIncomingCallDialog(data['caller']);
    });

    socket.on('call-accepted', (_) {
      print('Call accepted by partner');
      _createOffer();
    });

    socket.on('offer', (data) async {
      print('Received offer: ${data['offer']}');
      await _peerConnection?.setRemoteDescription(
        RTCSessionDescription(data['offer']['sdp'], data['offer']['type']),
      );
      _createAnswer();
    });

    socket.on('answer', (data) async {
      print('Received answer: ${data['answer']}');
      await _peerConnection?.setRemoteDescription(
        RTCSessionDescription(data['answer']['sdp'], data['answer']['type']),
      );
    });

    socket.on('ice-candidate', (data) async {
      print('Received ICE candidate: ${data['candidate']}');
      await _peerConnection?.addCandidate(
        RTCIceCandidate(
          data['candidate']['candidate'],
          data['candidate']['sdpMid'],
          data['candidate']['sdpMLineIndex'],
        ),
      );
    });

    socket.on('call-ended', (_) {
      print('Call ended by partner');
      _endCall();
    });

    socket.on('error', (error) {
      print('Socket error: $error');
    });
  }

  void _initWebRTC() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();

    // Get local media stream
    _localStream = await navigator.mediaDevices.getUserMedia({
      'audio': true,
      'video': true,
    });
    _localRenderer.srcObject = _localStream;

    // Create peer connection
    _peerConnection = await createPeerConnection({
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
      ],
    });

    // Add local stream to peer connection
    _localStream?.getTracks().forEach((track) {
      _peerConnection?.addTrack(track, _localStream!);
    });

    // Handle ICE candidates
    _peerConnection?.onIceCandidate = (RTCIceCandidate candidate) {
      print('Sending ICE candidate: ${candidate.toMap()}');
      socket.emit('ice-candidate', {
        'callId': _callId,
        'candidate': candidate.toMap(),
      });
    };

    // Handle remote stream
    _peerConnection?.onTrack = (RTCTrackEvent event) {
      _remoteRenderer.srcObject = event.streams[0];
    };
  }

  void _showIncomingCallDialog(Map<String, dynamic> caller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Incoming Call'),
        content: Text('${caller['name']} is calling you.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _acceptCall();
            },
            child: const Text('Accept'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _endCall();
            },
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  void _initiateCall() {
    print('Initiating call to partner: ${widget.partnerId}');
    socket.emit('initiate-call', {'partnerId': widget.partnerId});
  }

  void _acceptCall() {
    print('Accepting call: $_callId');
    socket.emit('accept-call', {'callId': _callId});
  }

  void _endCall() {
    print('Ending call: $_callId');
    socket.emit('end-call', {'callId': _callId});
    Navigator.pop(context);
  }

  void _createOffer() async {
    print('Creating offer...');
    final offer = await _peerConnection?.createOffer();
    await _peerConnection?.setLocalDescription(offer!);
    socket.emit('offer', {
      'callId': _callId,
      'offer': {'sdp': offer?.sdp, 'type': offer?.type},
    });
  }

  void _createAnswer() async {
    print('Creating answer...');
    final answer = await _peerConnection?.createAnswer();
    await _peerConnection?.setLocalDescription(answer!);
    socket.emit('answer', {
      'callId': _callId,
      'answer': {'sdp': answer?.sdp, 'type': answer?.type},
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Call Screen')),
      body: Column(
        children: [
          Expanded(
            child: RTCVideoView(_remoteRenderer),
          ),
          Expanded(
            child: RTCVideoView(_localRenderer),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: const Icon(Icons.call),
                onPressed: _initiateCall,
              ),
              IconButton(
                icon: const Icon(Icons.call_end),
                onPressed: _endCall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
