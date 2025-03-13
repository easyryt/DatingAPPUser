import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:gad_fly/constant/color_code.dart';
import 'package:gad_fly/controller/main_application_controller.dart';
import 'package:gad_fly/services/socket_service.dart';
import 'package:get/get.dart';

class OutgoingCallScreen extends StatefulWidget {
  final String id;
  final String name;
  const OutgoingCallScreen({
    super.key,
    required this.id,
    required this.name,
  });

  @override
  State<OutgoingCallScreen> createState() => _OutgoingCallScreenState();
}

class _OutgoingCallScreenState extends State<OutgoingCallScreen> {
  ChatService chatService = ChatService();
  MainApplicationController mainApplicationController = Get.find();
  MediaStream? remoteStream;
  bool isCallConnected = false;

  Duration _callDuration = Duration.zero;
  Timer? _timer;
  bool _isTimerRunning = false;
  bool _isMuted = false;
  bool _isLoudspeakerOn = false;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isRinging = false;

  initFunction() async {
    if (mainApplicationController.authToken.value != "") {
      await chatService.connect(
        (MediaStream stream) {
          if (mounted) {
            setState(() {
              remoteStream = stream;
            });
          }
          print("Remote stream received");
        },
      );
      await chatService.setupWebRTC();
      await chatService.initiateCall(widget.id);
    }
  }

  @override
  void initState() {
    initFunction();
    _audioPlayer.onPlayerComplete.listen((event) {
      setState(() {
        _isRinging = false;
      });
    });
    super.initState();

    chatService.socket.on('call-initiated', (data) async {
      chatService.currentCallId = data['callId'];
      print('Call initiated with ID: ${data['callId']}');
      _playRingingSound();
    });

    chatService.socket.on('call-accepted', (_) async {
      print("call .............accept.....................");
      await chatService.createAndSendOffer();
      if (mounted) {
        setState(() {
          isCallConnected = true;
        });
      }
      _stopRingingSound();
      _startTimer();
    });

    chatService.socket.on('call-rejected', (_) {
      setState(() {
        isCallConnected = false;
      });
      _stopRingingSound();
      _stopTimer();
      Get.back();
    });

    chatService.socket.on('call-ended', (_) {
      if (mounted) {
        setState(() {
          isCallConnected = false;
        });
      }
      _stopRingingSound();
      chatService.endCalls();
      _stopTimer();
      Get.back();
    });
  }

  @override
  void dispose() {
    _stopRingingSound();
    _audioPlayer.stop();
    _audioPlayer.dispose();
    remoteStream?.dispose();
    // chatService.disconnect();
    _stopTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 30),
              Text(
                isCallConnected ? "Connected" : "Outgoing call...",
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (isCallConnected)
                Text(
                  _formatDuration(_callDuration),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w400),
                ),
              const SizedBox(height: 8),
              Text(
                widget.name,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isCallConnected)
                    IconButton(
                      onPressed: _toggleLoudspeaker,
                      style: IconButton.styleFrom(
                          backgroundColor:
                              _isLoudspeakerOn ? Colors.white : Colors.grey,
                          padding: const EdgeInsets.all(10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          )),
                      icon: Icon(
                        Icons.volume_up,
                        size: 28,
                        color: _isLoudspeakerOn ? black : white,
                      ),
                    ),
                  if (isCallConnected) const SizedBox(width: 20),
                  if (isCallConnected)
                    IconButton(
                      icon: Icon(
                        _isMuted ? Icons.mic_off : Icons.mic,
                        size: 32,
                        color: Colors.white,
                      ),
                      onPressed: _toggleMute,
                      style: IconButton.styleFrom(
                          backgroundColor: _isMuted ? Colors.red : Colors.grey,
                          padding: const EdgeInsets.all(10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          )),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (chatService.currentCallId != null) {
                    await chatService.endCall();
                    _stopTimer();
                  } else {
                    Get.back();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                ),
                child: const Text(
                  "End Call",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  void _startTimer() {
    _callDuration = Duration.zero;
    _isTimerRunning = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _callDuration += const Duration(seconds: 1);
        });
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
    _isTimerRunning = false;
    _callDuration = Duration.zero;
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
    });
    chatService.toggleMicrophone(_isMuted);
  }

  void _toggleLoudspeaker() async {
    setState(() {
      _isLoudspeakerOn = !_isLoudspeakerOn;
    });
    await chatService.toggleLoudspeaker(_isLoudspeakerOn);
  }

  void _playRingingSound() async {
    // await _audioPlayer.setReleaseMode(ReleaseMode.loop);
    // await _audioPlayer.play(AssetSource("sound/call_ring.mp4"));
    //
    // setState(() {
    //   _isRinging = true;
    // });
    try {
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.play(AssetSource("sound/call_ring.mp4"));
      setState(() {
        _isRinging = true;
      });
    } catch (e) {
      print("Error playing sound: $e");
    }
  }

  void _stopRingingSound() async {
    // await _audioPlayer.stop();
    // setState(() {
    //   _isRinging = false;
    // });
    try {
      if (_isRinging) {
        await _audioPlayer.stop();
        setState(() {
          _isRinging = false;
        });
      }
    } catch (e) {
      print("Error stopping sound: $e");
    }
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
}
