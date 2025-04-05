import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:gad_fly/controller/call_controller.dart';
import 'package:get/get.dart';

class UserCallScreen extends StatefulWidget {
  final String partnerId;
  final String name;

  const UserCallScreen(
      {super.key, required this.partnerId, required this.name});

  @override
  State<UserCallScreen> createState() => _UserCallScreenState();
}

class _UserCallScreenState extends State<UserCallScreen> {
  final AgoraCallService controller = Get.put(AgoraCallService());
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    controller.initiateCall(widget.partnerId);
    _audioPlayer.onPlayerComplete.listen((event) {
      controller.isRinging.value = false;
    });
    super.initState();

    controller.isRinging.listen((isRinging) {
      if (isRinging) {
        _playRingingSound();
      } else {
        _stopRingingSound();
      }
    });

    controller.isStopRinging.listen((isStopRinging) {
      if (isStopRinging) {
        _stopRingingSound();
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.stop();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      //  appBar: AppBar(title: const Text('User Call Screen')),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 30),
              Obx(() => Text(
                    controller.isJoined.value
                        ? "Connected"
                        : "Outgoing call...",
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  )),
              const SizedBox(height: 12),
              Text(
                widget.name,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 12),
              Obx(() => Text(
                    controller.isJoined.value
                        ? controller.callDuration.value
                        : "",
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w500),
                  )),
              const Spacer(),
              Obx(() {
                return (controller.isJoined.value)
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Obx(() => Icon(
                                  controller.isMuted.value
                                      ? Icons.mic_off
                                      : Icons.mic,
                                  size: 30,
                                  color: Colors.blue,
                                )),
                            onPressed: () {
                              controller.toggleMute();
                            },
                          ),
                          const SizedBox(width: 20),
                          // Loudspeaker/Earpiece Button
                          IconButton(
                            icon: Obx(() => Icon(
                                  controller.isLoudspeaker.value
                                      ? Icons.volume_up
                                      : Icons.volume_off,
                                  size: 30,
                                  color: Colors.blue,
                                )),
                            onPressed: () {
                              controller.toggleLoudspeaker();
                            },
                          ),
                        ],
                      )
                    : const SizedBox();
              }),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  await controller.endCall(controller.channelName.value);
                  if (controller.isJoined.value == false) {
                    controller.engine.leaveChannel();
                    controller.isJoined.value = false;
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

  void _playRingingSound() async {
    try {
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.play(AssetSource("sound/call_ring.mp4"));
    } catch (e) {
      print("Error playing sound: $e");
    }
  }

  void _stopRingingSound() async {
    try {
      await _audioPlayer.stop();
      controller.isRinging.value = false;
    } catch (e) {
      print("Error stopping sound: $e");
    }
  }
}
