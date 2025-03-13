import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gad_fly/constant/color_code.dart';
import 'package:gad_fly/controller/main_application_controller.dart';
import 'package:gad_fly/controller/profile_controller.dart';
import 'package:gad_fly/screens/home/outgoing_call.dart';
import 'package:gad_fly/screens/messages_screen.dart';
import 'package:gad_fly/services/socket_service.dart';
import 'package:gad_fly/widgets/drawer.dart';
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
  // MediaStream? remoteStream;
  Duration _callDuration = Duration.zero;
  Timer? _timer;
  bool _isTimerRunning = false;

  ChatService chatService = ChatService();

  // void _startTimer() {
  //   _callDuration = Duration.zero;
  //   _isTimerRunning = true;
  //   _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
  //     setState(() {
  //       _callDuration += const Duration(seconds: 1);
  //     });
  //   });
  // }
  //
  // void _stopTimer() {
  //   _timer?.cancel();
  //   _timer = null;
  //   _isTimerRunning = false;
  //   _callDuration = Duration.zero;
  // }
  //
  // String _formatDuration(Duration duration) {
  //   String twoDigits(int n) => n.toString().padLeft(2, '0');
  //   final hours = twoDigits(duration.inHours);
  //   final minutes = twoDigits(duration.inMinutes.remainder(60));
  //   final seconds = twoDigits(duration.inSeconds.remainder(60));
  //   return "$hours:$minutes:$seconds";
  // }

  // bool _isMuted = false;

  // void _toggleMute() {
  //   setState(() {
  //     _isMuted = !_isMuted;
  //   });
  //   chatService.toggleMicrophone(_isMuted);
  // }
  //
  // bool _isLoudspeakerOn = false;
  //
  // void _toggleLoudspeaker() async {
  //   setState(() {
  //     _isLoudspeakerOn = !_isLoudspeakerOn;
  //   });
  //   await chatService.toggleLoudspeaker(_isLoudspeakerOn);
  // }

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isRinging = false;
  String? _currentlyPlayingUrl;

  // void _playRingingSound() async {
  //   await _audioPlayer.setReleaseMode(ReleaseMode.loop);
  //   await _audioPlayer.play(AssetSource("sound/call_ring.mp4"));
  //
  //   setState(() {
  //     _isRinging = true;
  //   });
  // }
  //
  // void _stopRingingSound() async {
  //   await _audioPlayer.stop();
  //   setState(() {
  //     _isRinging = false;
  //   });
  // }

  void _toggleAudio(String url) async {
    if (_currentlyPlayingUrl == url) {
      await _audioPlayer.stop();
      setState(() {
        _currentlyPlayingUrl = null;
      });
    } else {
      if (_currentlyPlayingUrl != null) {
        await _audioPlayer.stop();
      }
      await _audioPlayer.play(UrlSource(url));
      setState(() {
        _currentlyPlayingUrl = url;
      });
    }
  }

  initFunction() async {
    if (mainApplicationController.authToken.value != "") {
      await chatService.connect(
        // (MediaStream stream) {
        //   // setState(() {
        //   //   remoteStream = stream;
        //   // });
        // },
        (_) {},
      );
      await chatService.requestPartnerList();
    }
  }

  @override
  void initState() {
    mainApplicationController.checkMicrophonePermission();

    initFunction();
    profileController.getProfile();
    mainApplicationController.getAllChat();
    mainApplicationController.getTransaction();
    mainApplicationController.getAllTransaction();
    // chatService.socket.on('call-initiated', (data) async {
    //   chatService.currentCallId = data['callId'];
    //   print('Call initiated with ID: ${data['callId']}');
    //   _playRingingSound();
    // });
    //
    // chatService.socket.on('call-accepted', (_) async {
    //   await chatService.createAndSendOffer();
    //   setState(() {
    //     isCallConnected = true;
    //   });
    //   _stopRingingSound();
    //   _startTimer();
    // });
    //
    // chatService.socket.on('call-rejected', (_) {
    //   setState(() {
    //     isCalling = false;
    //     isCallConnected = false;
    //   });
    //   _stopRingingSound();
    //   _stopTimer();
    // });
    //
    // chatService.socket.on('call-ended', (_) {
    //   if(mounted){
    //     setState(() {
    //       isCalling = false;
    //       isCallConnected = false;
    //       remoteStream = null;
    //     });
    //   }
    //   _stopRingingSound();
    //   chatService.endCalls();
    //   _stopTimer();
    // });
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
    //  _audioPlayer.dispose();
    // remoteStream?.dispose();
    // chatService.disconnect();
    // _stopTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    var appYellow = const Color(0xFFFFE30F);
    var appGreenColor = const Color(0xFF35D673);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: white,
      appBar: AppBar(
        backgroundColor: white,
        surfaceTintColor: white,
        leadingWidth: 0,
        automaticallyImplyLeading: false,
        title: GestureDetector(
          onTap: () async {
            await chatService.requestPartnerList();
          },
          child: Row(
            children: [
              Text(
                "Gad",
                style: TextStyle(
                    color: black, fontWeight: FontWeight.w700, fontSize: 20),
              ),
              Text(
                "Fly",
                style: TextStyle(
                    color: appColor, fontWeight: FontWeight.w700, fontSize: 20),
              ),
            ],
          ),
        ),
        actions: [
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
                padding: const EdgeInsets.symmetric(horizontal: 8),
                margin: const EdgeInsets.only(right: 4),
                decoration: BoxDecoration(
                    color: appGreenColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: appGreenColor, width: 1.1)),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Obx(() {
                        return Text(
                          "₹${profileController.amount}",
                          style: TextStyle(
                              color: white,
                              fontSize: 11,
                              fontWeight: FontWeight.w500),
                        );
                      }),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.add_circle,
                        color: white,
                        size: 15,
                      )
                    ],
                  ),
                ),
              ),
            ),
          if (!isCalling)
            Builder(
              builder: (context) => IconButton(
                icon: Image.asset(
                  "assets/drawerIcon.png",
                  width: 24,
                  fit: BoxFit.fitWidth,
                ),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            )
        ],
      ),
      drawer: buildDrawer(width, height),
      body: Stack(
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
                    Container(
                      height: 46,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: white,
                        //  color: greyMedium1Color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: black.withOpacity(0.8), width: 1.1),
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "search...",
                              style: TextStyle(
                                  color: black.withOpacity(0.5),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400),
                            ),
                            Icon(
                              CupertinoIcons.search,
                              color: black.withOpacity(0.5),
                            )
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Obx(() {
                      return ListView.builder(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          itemCount:
                              mainApplicationController.partnerList.length,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            var item =
                                mainApplicationController.partnerList[index];
                            return GestureDetector(
                              onTap: () {
                                // Navigator.push(
                                //     context,
                                //     MaterialPageRoute(
                                //         builder: (_) => const IntroScreen()));
                              },
                              child: Container(
                                margin: const EdgeInsets.symmetric(vertical: 6),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 10,
                                ),
                                clipBehavior: Clip.antiAlias,
                                decoration: ShapeDecoration(
                                  color: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                              backgroundColor:
                                                  appColor.withOpacity(0.8),
                                              backgroundImage: AssetImage((item[
                                                              "personalInfo"]
                                                          ["gender"] ==
                                                      "female")
                                                  ? "assets/womenAvatart.jpeg"
                                                  : "assets/menAvatar.jpeg"),
                                            ),
                                            const SizedBox(height: 4),
                                            const Text(
                                              "10k Minutes",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 8),
                                            ),
                                            const SizedBox(height: 2),
                                            Row(
                                              children:
                                                  List.generate(5, (index) {
                                                double rating =
                                                    (item["personalInfo"]
                                                                ["rating"] ??
                                                            0.0)
                                                        .toDouble();
                                                if (rating > 5) {
                                                  rating = 5;
                                                }

                                                if (index < rating.floor()) {
                                                  return const Icon(Icons.star,
                                                      color: Colors.amber,
                                                      size: 12.5);
                                                } else if (index < rating) {
                                                  return const Icon(
                                                      Icons.star_half,
                                                      color: Colors.amber,
                                                      size: 12.5);
                                                } else {
                                                  return const Icon(
                                                      Icons.star_border,
                                                      color: Colors.grey,
                                                      size: 12.5);
                                                }
                                              }),
                                            )
                                          ],
                                        ),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
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
                                                            FontWeight.w500,
                                                        fontSize: 14),
                                                  ),
                                                  GestureDetector(
                                                    onTap: () {
                                                      _toggleAudio(
                                                          item["personalInfo"]
                                                                  ["voiceNote"]
                                                              ["url"]
                                                          //  "https://res.cloudinary.com/ddy5sbdtr/video/upload/v1741608489/voiceNote_Partners/zvog1phhudaixzyfpglf.mp3",
                                                          );
                                                    },
                                                    child: Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              4),
                                                      decoration: BoxDecoration(
                                                          color: _currentlyPlayingUrl ==
                                                                  item["personalInfo"]
                                                                          ["voiceNote"]
                                                                      ["url"]
                                                              ? appGreenColor
                                                              : white,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(20),
                                                          border: Border.all(
                                                              color: black
                                                                  .withOpacity(
                                                                      0.4),
                                                              width: 1)),
                                                      child: Center(
                                                        child: Icon(
                                                          _currentlyPlayingUrl ==
                                                                  item["personalInfo"]
                                                                          [
                                                                          "voiceNote"]
                                                                      ["url"]
                                                              ? Icons.volume_off
                                                              : Icons.volume_up,
                                                          size: 18,
                                                          color: _currentlyPlayingUrl ==
                                                                  item["personalInfo"]
                                                                          [
                                                                          "voiceNote"]
                                                                      ["url"]
                                                              ? white
                                                              : black,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Text(
                                                "${item["personalInfo"]["im"]}",
                                                style: TextStyle(
                                                    color:
                                                        black.withOpacity(0.3),
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 12),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                "🎓 ${List<String>.from(item["personalInfo"]["tag"]).join(", ")} ",
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1, //
                                                style: TextStyle(
                                                    color:
                                                        black.withOpacity(0.5),
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 12),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                "🌐 ${List<String>.from(item["personalInfo"]["languages"]).join(", ")} ",
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                                style: TextStyle(
                                                    color:
                                                        black.withOpacity(0.5),
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 12),
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            Get.to(() => MessagesScreen(
                                                  receiverId: item["_id"],
                                                  name: item["personalInfo"]
                                                      ["avatarName"],
                                                ));
                                          },
                                          child: Container(
                                            height: 36,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16),
                                            decoration: BoxDecoration(
                                              color: white,
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              border: Border.all(
                                                  color: appColor, width: 1.2),
                                            ),
                                            child: Center(
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    CupertinoIcons
                                                        .chat_bubble_2,
                                                    color: appColor,
                                                  ),
                                                  Text(
                                                    " Chat ₹5/M",
                                                    style: TextStyle(
                                                        color: black,
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w500),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: GestureDetector(
                                            onTap: () async {
                                              // setState(() {
                                              //   avtarName =
                                              //       item["personalInfo"]
                                              //           ["avatarName"];
                                              // });
                                              // await chatService
                                              //     .setupWebRTC();
                                              // await chatService
                                              //     .initiateCall(
                                              //         item["_id"]);
                                              // setState(() {
                                              //   isCalling = true;
                                              // });
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (_) =>
                                                          OutgoingCallScreen(
                                                            id: item["_id"],
                                                            name: item[
                                                                    "personalInfo"]
                                                                ["avatarName"],
                                                          )));
                                            },
                                            child: Container(
                                              height: 36,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 4),
                                              decoration: BoxDecoration(
                                                color: appColor,
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                                // border: Border.all(
                                                //     color: blackColor, width: 1.1),
                                              ),
                                              child: Center(
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Icon(
                                                      Icons.call,
                                                      color: white,
                                                      size: 20,
                                                    ),
                                                    Text(
                                                      " Call ₹2/min",
                                                      style: TextStyle(
                                                          color: white,
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.w600),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
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
    );
  }
}
