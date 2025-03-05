import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:gad_fly/controller/main_application_controller.dart';
import 'package:gad_fly/controller/profile_controller.dart';
import 'package:gad_fly/screens/home/history_screen.dart';
import 'package:gad_fly/screens/home/profile/profile.dart';
import 'package:gad_fly/services/socket_service.dart';
import 'package:get/get.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  MainApplicationController mainApplicationController = Get.find();
  ProfileController profileController = Get.put(ProfileController());
  bool isLoading = false;
  bool isCallConnected = false;
  bool isCalling = false;
  String avtarName = '';
  MediaStream? remoteStream;
  Duration _callDuration = Duration.zero;
  Timer? _timer;
  bool _isTimerRunning = false;

  ChatService chatService = ChatService();

  void _startTimer() {
    _callDuration = Duration.zero;
    _isTimerRunning = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _callDuration += const Duration(seconds: 1);
      });
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

  bool _isMuted = false;

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
    });
    chatService.toggleMicrophone(_isMuted);
  }

  bool _isLoudspeakerOn = false;

  void _toggleLoudspeaker() async {
    setState(() {
      _isLoudspeakerOn = !_isLoudspeakerOn;
    });
    await chatService.toggleLoudspeaker(_isLoudspeakerOn);
  }

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isRinging = false;

  void _playRingingSound() async {
    await _audioPlayer.setReleaseMode(ReleaseMode.loop);
    await _audioPlayer.play(AssetSource("sound/call_ring.mp4"));

    setState(() {
      _isRinging = true;
    });
  }

  void _stopRingingSound() async {
    await _audioPlayer.stop();
    setState(() {
      _isRinging = false;
    });
  }

  initFunction() async {
    if (mainApplicationController.authToken.value != "") {
      await chatService.connect(
        context,
        mainApplicationController.authToken.value,
        _onRequestAccepted,
        (MediaStream stream) {
          setState(() {
            remoteStream = stream;
          });
        },
      );
    }
  }

  @override
  void initState() {
    mainApplicationController.checkMicrophonePermission();

    initFunction();
    profileController.getProfile();
    mainApplicationController.getAllTransaction();
    chatService.socket.on('call-initiated', (data) async {
      chatService.currentCallId = data['callId'];
      print('Call initiated with ID: ${data['callId']}');
      _playRingingSound();
    });

    chatService.socket.on('call-accepted', (_) async {
      await chatService.createAndSendOffer();
      setState(() {
        isCallConnected = true;
      });
      _stopRingingSound();
      _startTimer();
    });

    chatService.socket.on('call-rejected', (_) {
      setState(() {
        isCalling = false;
        isCallConnected = false;
      });
      _stopRingingSound();
      _stopTimer();
    });

    chatService.socket.on('call-ended', (_) {
      setState(() {
        isCalling = false;
        isCallConnected = false;
        remoteStream = null;
      });
      _stopRingingSound();
      chatService.endCalls();
      _stopTimer();
    });
    super.initState();
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

  @override
  void dispose() {
    _audioPlayer.stop();
    _audioPlayer.dispose();
    remoteStream?.dispose();
    chatService.disconnect();
    _stopTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    var whiteColor = Colors.white;
    var blackColor = Colors.black;
    var appColor = const Color(0xFF8CA6DB);
    var appYellow = const Color(0xFFFFE30F);
    var appGreenColor = const Color(0xFF35D673);
    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop();
        return false;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: whiteColor,
        appBar: AppBar(
          backgroundColor: whiteColor,
          surfaceTintColor: whiteColor,
          leadingWidth: 0,
          automaticallyImplyLeading: false,
          title: GestureDetector(
            onTap: () async {
              await chatService.disconnect();
              if (mainApplicationController.authToken.value != "") {
                chatService.connect(
                  context,
                  mainApplicationController.authToken.value,
                  _onRequestAccepted,
                  (MediaStream stream) {
                    setState(() {
                      remoteStream = stream;
                    });
                  },
                );
              }
            },
            child: Row(
              children: [
                Text(
                  "Gad",
                  style: TextStyle(
                      color: blackColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 20),
                ),
                Text(
                  "Fly",
                  style: TextStyle(
                      color: appColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 20),
                ),
              ],
            ),
          ),
          actions: [
            if (!isCalling)
              IconButton(
                  onPressed: () {
                    Get.to(() => const HistoryScreen());
                  },
                  icon: const Icon(Icons.history)),
            if (!isCalling)
              GestureDetector(
                onTap: () async {
                  final profileData = {
                    "amount": 100,
                  };
                  setState(() {
                    isLoading = true;
                  });
                  await mainApplicationController
                      .transactionCreate(profileData)
                      .then((onValue) {
                    if (onValue != null) {
                      Get.snackbar("wow", "payment 100 successfully");
                    } else {
                      Get.snackbar("Alert", "payment  failed");
                    }
                  });
                  setState(() {
                    isLoading = false;
                  });
                },
                child: Container(
                  height: 28,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  margin: const EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                      color: appYellow.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: appYellow, width: 1.1)),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Obx(() {
                          return Text(
                            "₹${profileController.amount}",
                            style: TextStyle(
                                color: blackColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w500),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              )
          ],
        ),
        body: isCalling
            ? Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 30),
                    Text(
                      isCallConnected ? "Connected" : "Partner Calling...",
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
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
                      "$avtarName ",
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
                                backgroundColor: _isLoudspeakerOn
                                    ? Colors.white
                                    : Colors.grey,
                                padding: const EdgeInsets.all(10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50),
                                )),
                            icon: Icon(
                              Icons.volume_up,
                              size: 28,
                              color: _isLoudspeakerOn ? blackColor : whiteColor,
                            ),
                          ),
                        if (isCallConnected) const SizedBox(width: 10),
                        if (isCallConnected)
                          IconButton(
                            icon: Icon(
                              _isMuted ? Icons.mic_off : Icons.mic,
                              size: 32,
                              color: Colors.white,
                            ),
                            onPressed: _toggleMute,
                            style: IconButton.styleFrom(
                                backgroundColor:
                                    _isMuted ? Colors.red : Colors.grey,
                                padding: const EdgeInsets.all(10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50),
                                )),
                          ),
                        if (isCallConnected) const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () async {
                            if (chatService.currentCallId != null) {
                              await chatService.endCall();
                              setState(() {
                                isCalling = false;
                              });
                              _stopTimer();
                            } else {
                              setState(() {
                                isCalling = false;
                              });
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 28, vertical: 12),
                          ),
                          child: const Text(
                            "End Call",
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              )
            : Stack(
                children: [
                  SizedBox(
                    height: height,
                    width: width,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            const SizedBox(height: 6),
                            // Container(
                            //   height: 46,
                            //   padding: const EdgeInsets.symmetric(horizontal: 16),
                            //   decoration: BoxDecoration(
                            //     color: greyMedium1Color.withOpacity(0.2),
                            //     borderRadius: BorderRadius.circular(10),
                            //     // border: Border.all(
                            //     //     color: blackColor.withOpacity(0.15), width: 1.1),
                            //   ),
                            //   child: Center(
                            //     child: Row(
                            //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            //       children: [
                            //         Text(
                            //           "search...",
                            //           style: TextStyle(
                            //               color: blackColor.withOpacity(0.5),
                            //               fontSize: 15,
                            //               fontWeight: FontWeight.w400),
                            //         ),
                            //         Icon(
                            //           CupertinoIcons.search,
                            //           color: blackColor.withOpacity(0.5),
                            //         )
                            //       ],
                            //     ),
                            //   ),
                            // ),
                            const SizedBox(height: 6),
                            Obx(() {
                              return ListView.builder(
                                  padding: EdgeInsets.zero,
                                  shrinkWrap: true,
                                  itemCount: mainApplicationController
                                      .partnerList.length,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    var item = mainApplicationController
                                        .partnerList[index];
                                    return GestureDetector(
                                      onTap: () {
                                        // Navigator.push(
                                        //     context,
                                        //     MaterialPageRoute(
                                        //         builder: (_) => const IntroScreen()));
                                      },
                                      child: Container(
                                        margin: const EdgeInsets.symmetric(
                                            vertical: 6),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 10,
                                        ),
                                        clipBehavior: Clip.antiAlias,
                                        decoration: ShapeDecoration(
                                          color: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          shadows: const [
                                            BoxShadow(
                                              color: Color(0x16000000),
                                              blurRadius: 2,
                                              offset: Offset(0, 2),
                                              spreadRadius: 0,
                                            )
                                          ],
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Column(
                                                  children: [
                                                    CircleAvatar(
                                                      radius: 28,
                                                      backgroundColor: appColor,
                                                    ),
                                                    const SizedBox(height: 6),
                                                    const Text(
                                                      "0 Minutes",
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize: 8),
                                                    )
                                                  ],
                                                ),
                                                const SizedBox(width: 6),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Text(
                                                            item["personalInfo"]
                                                                ["avatarName"],
                                                            style: const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                fontSize: 14),
                                                          ),
                                                          Text(
                                                            "ONLINE",
                                                            style: TextStyle(
                                                                color:
                                                                    appGreenColor,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                fontSize: 12),
                                                          ),
                                                        ],
                                                      ),
                                                      Text(
                                                        "Professional Listener",
                                                        style: TextStyle(
                                                            color: blackColor
                                                                .withOpacity(
                                                                    0.3),
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            fontSize: 12),
                                                      ),
                                                      Text(
                                                        "Empathy, Compassion, Lonliness, ....",
                                                        style: TextStyle(
                                                            color: blackColor
                                                                .withOpacity(
                                                                    0.5),
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            fontSize: 12),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Text(
                                                            "${item["personalInfo"]["languages"][0]},${item["personalInfo"]["languages"][1]}",
                                                            style: TextStyle(
                                                                color: blackColor
                                                                    .withOpacity(
                                                                        0.5),
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                fontSize: 12),
                                                          ),
                                                          Container(
                                                            height: 24,
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        12),
                                                            decoration: BoxDecoration(
                                                                color:
                                                                    whiteColor,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            16),
                                                                border: Border.all(
                                                                    color:
                                                                        appGreenColor,
                                                                    width:
                                                                        1.1)),
                                                            child: Center(
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Text(
                                                                    "★ 4.5",
                                                                    style: TextStyle(
                                                                        color:
                                                                            appGreenColor,
                                                                        fontSize:
                                                                            11,
                                                                        fontWeight:
                                                                            FontWeight.w500),
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Container(
                                                  height: 32,
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 16),
                                                  decoration: BoxDecoration(
                                                      color: whiteColor,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              16),
                                                      border: Border.all(
                                                          color: blackColor,
                                                          width: 1.1)),
                                                  child: Center(
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Text(
                                                          "🔊 Play",
                                                          style: TextStyle(
                                                              color: blackColor,
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: GestureDetector(
                                                    onTap: () async {
                                                      setState(() {
                                                        avtarName =
                                                            item["personalInfo"]
                                                                ["avatarName"];
                                                      });
                                                      await chatService
                                                          .setupWebRTC();
                                                      await chatService
                                                          .initiateCall(
                                                              item["_id"]);
                                                      setState(() {
                                                        isCalling = true;
                                                      });
                                                      // Navigator.push(
                                                      //     context,
                                                      //     MaterialPageRoute(
                                                      //         builder: (_) =>
                                                      //             OutgoingCallScreen(
                                                      //               id: item["_id"],
                                                      //               name: item[
                                                      //                       "personalInfo"]
                                                      //                   [
                                                      //                   "avatarName"],
                                                      //             )));
                                                    },
                                                    child: Container(
                                                      height: 36,
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 16),
                                                      decoration: BoxDecoration(
                                                        color: appColor,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                        // border: Border.all(
                                                        //     color: blackColor, width: 1.1),
                                                      ),
                                                      child: Center(
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Icon(
                                                              Icons.call,
                                                              color: whiteColor,
                                                            ),
                                                            Text(
                                                              " Call ₹2/min",
                                                              style: TextStyle(
                                                                  color:
                                                                      whiteColor,
                                                                  fontSize: 12,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                    );
                                  });
                            }),
                            const SizedBox(height: 60),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                      bottom: 24,
                      left: width * 0.16,
                      right: width * 0.16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        clipBehavior: Clip.antiAlias,
                        decoration: ShapeDecoration(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(60),
                          ),
                          shadows: const [
                            BoxShadow(
                              color: Color(0x16000000),
                              blurRadius: 9,
                              offset: Offset(0, 7),
                              spreadRadius: 0,
                            )
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 8, horizontal: width * 0.11),
                              decoration: BoxDecoration(
                                color: appColor,
                                borderRadius: BorderRadius.circular(28),
                              ),
                              child: Icon(
                                Icons.call,
                                color: whiteColor,
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const Profile()),
                                );
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: 6, horizontal: width * 0.11),
                                decoration: BoxDecoration(
                                  color: whiteColor,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Icon(
                                  Icons.person,
                                  color: blackColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                  if (isLoading)
                    const Positioned(
                        top: 0,
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: CircularProgressIndicator(),
                        ))
                ],
              ),
      ),
    );
  }
}
