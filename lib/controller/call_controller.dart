import 'dart:async';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/cupertino.dart';
import 'package:gad_fly/controller/main_application_controller.dart';
import 'package:gad_fly/services/socket_service.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class AgoraCallService extends GetxController {
  static const String appId = "90dde3ee5fbc4fe5a6a876e972c7bb2a";
  final RxBool isJoined = false.obs;
  final RxBool isRinging = false.obs;
  final RxBool isStopRinging = false.obs;
  final RxBool isLoudspeaker = true.obs;
  final RxBool isMuted = false.obs;
  var channelName = "".obs;
  var agoraToken = "".obs;
  var remoteUserId = "".obs;
  var userIds = "".obs;
  final RxString callDuration = "00:00".obs;
  DateTime? _callStartTime;

  late RtcEngine engine;
  MainApplicationController mainApplicationController = Get.find();
  ChatService chatService = ChatService();

  @override
  void onInit() {
    super.onInit();
    initFunction();
    initializeAgora();
  }

  initFunction() async {
    if (mainApplicationController.authToken.value != "") {
      await chatService.connect(
        (_) {},
      );
    }

    chatService.socket.on('call-accepted', (data) {
      isStopRinging.value = true;
      joinCall(agoraToken.value, data['channelName'], data["callerId"]);
    });
    chatService.socket.on('call-ended', (data) {
      engine.leaveChannel();
      isJoined.value = false;
      _stopCallTimer();
      Get.back();
    });

    chatService.socket.on('call-initiated', (data) async {
      print('Incoming call from: $data');
      isRinging.value = true;
      agoraToken.value = data["token"];
      channelName.value = data["channelName"];
    });
  }

  void toggleLoudspeaker() async {
    isLoudspeaker.value = !isLoudspeaker.value;
    await engine.setEnableSpeakerphone(isLoudspeaker.value);
  }

  void initializeAgora() async {
    await [Permission.microphone].request();
    engine = createAgoraRtcEngine();
    await engine.initialize(const RtcEngineContext(
      appId: appId,
      //  channelProfile: ChannelProfileType.channelProfileCommunication,
    ));

    await engine.enableAudio();
    // await engine
    //     .setChannelProfile(ChannelProfileType.channelProfileCommunication);
    await engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
    await engine.setDefaultAudioRouteToSpeakerphone(true);

    engine.registerEventHandler(RtcEngineEventHandler(
      onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
        print("Joined channel successfully");
        isJoined.value = true;
      },
      onError: (ErrorCodeType err, String msg) {
        print("Error: $err, Message: $msg .................................");
      },
      onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
        remoteUserId.value = remoteUid.toString();
        print("Remote user joined: $remoteUid");
      },
      onUserOffline: (RtcConnection connection, int remoteUid,
          UserOfflineReasonType reason) {
        print("Remote user offline: $remoteUid");
        remoteUserId.value = '';
      },
      onTokenPrivilegeWillExpire: (RtcConnection connection, String token) {
        debugPrint("Token will expire..................");
      },
    ));
  }

  void initiateCall(String partnerId) {
    chatService.socket.emit('initiate-call', {'partnerId': partnerId});
  }

  void _startCallTimer() {
    _callStartTime = DateTime.now();
    // Update the call duration every second
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_callStartTime != null) {
        final duration = DateTime.now().difference(_callStartTime!);
        callDuration.value = _formatDuration(duration);
      } else {
        timer.cancel(); // Stop the timer if the call ends
      }
    });
  }

  // Stop the call timer
  void _stopCallTimer() {
    _callStartTime = null;
  }

  // Format duration as "mm:ss"
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  Future<void> joinCall(String token, String channelName, userId) async {
    try {
      await engine.joinChannelWithUserAccount(
        token: token,
        channelId: channelName,
        //  uid: 0,
        options: const ChannelMediaOptions(
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
          channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
        ),
        userAccount: userId,
      );
      _startCallTimer();
    } catch (e) {
      print("Join Channel Error: $e");
    }
  }

  void endCall(channelName) {
    chatService.socket.emit('end-call', {'channelName': channelName});
  }

  void toggleMute() {
    isMuted.value = !isMuted.value;
    engine.muteLocalAudioStream(isMuted.value);
  }

  @override
  void onClose() {
    engine.release();
    super.onClose();
  }
}
