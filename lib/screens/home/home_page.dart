import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gad_fly/constant/color_code.dart';
import 'package:gad_fly/controller/main_application_controller.dart';
import 'package:gad_fly/controller/profile_controller.dart';
import 'package:gad_fly/screens/agora_call_screen.dart';
import 'package:gad_fly/screens/home/profile/wallet_screen.dart';
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

  ChatService chatService = ChatService();

  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _currentlyPlayingUrl;

  initFunction() async {
    if (mainApplicationController.authToken.value != "") {
      await chatService.connect(
        (_) {},
      );
      await chatService.requestPartnerList();
      await profileController.getProfile();
      await mainApplicationController.getAllChat();
      await mainApplicationController.getAllCallHistory();
      await mainApplicationController.getRechargeOffer();
      await mainApplicationController.getTransaction();
    }
  }

  @override
  void initState() {
    mainApplicationController.checkMicrophonePermission();
    initFunction();
    super.initState();
  }

  @override
  void dispose() {
    _audioPlayer.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    // var appYellow = const Color(0xFFFFE30F);
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
          // onTap: () async {
          //   await chatService.requestPartnerList();
          // },
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
                // final profileData = {
                //   "amount": 100,
                // };
                // setState(() {
                //   isLoading = true;
                // });
                // await mainApplicationController
                //     .transactionCreate(profileData)
                //     .then((onValue) {
                //   if (onValue != null) {
                //     Get.snackbar("wow", "payment 100 successfully");
                //   } else {
                //     Get.snackbar("Alert", "payment  failed");
                //   }
                // });
                // setState(() {
                //   isLoading = false;
                // });
                ///
                // String? razorpayKey;
                // Map<String, Object> paymentMethod;
                // await mainApplicationController
                //     .fetchRazorpayKey()
                //     .then((onValue) async {
                //   if (onValue != null) {
                //     razorpayKey = onValue;
                //     // if (promoCode ==
                //     //         "no promo" ||
                //     //     promoCode ==
                //     //         "")
                //     // {
                //     paymentMethod = {
                //       "paymentMethod": {"cod": false, "online": true}
                //     };
                //     // } else {
                //     //   paymentMethod =
                //     //       {
                //     //     "paymentMethod":
                //     //         {
                //     //       "cod":
                //     //           false,
                //     //       "online":
                //     //           true
                //     //     },
                //     //     "couponCode":
                //     //         promoCode
                //     //   };
                //     // }
                //     await mainApplicationController
                //         .transactionCreate(paymentMethod, razorpayKey)
                //         .then((onValue) async {
                //       if (onValue != null) {
                //         orderId = onValue["_id"];
                //         openCheckOut(
                //           "${onValue["productData"]["grandTotal"]}",
                //           razorpayKey!,
                //           onValue["paymentInfo"]["razorpay_order_id"],
                //         );
                //         // Get.to(() =>
                //         //     RazorpayPaymentScreen(
                //         //       razorpayKey: razorpayKey!,
                //         //       orderId: onValue["_id"],
                //         //       razorPayOrderId: onValue["paymentInfo"]["razorpay_order_id"],
                //         //       grandTotal: "${onValue["productData"]["grandTotal"]}",
                //         //     ));
                //       } else {
                //         Get.snackbar(
                //             "Alert", "Something went wrong Order Not Created");
                //       }
                //     });
                //   } else {
                //     Get.snackbar(
                //         "Warning", "Something went wrong with Online Method ");
                //     Navigator.of(context).pop();
                //   }
                // });
                ///
                Get.to(() => const WalletScreen());
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
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 2),
                            decoration: BoxDecoration(
                              color: white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: black.withOpacity(0.8), width: 1.1),
                            ),
                            child: TextFormField(
                              //  controller: realNameController,
                              decoration: InputDecoration(
                                  isDense: true,
                                  hintText: 'search....',
                                  hintStyle: TextStyle(
                                      color: black.withOpacity(0.5),
                                      fontSize: 15,
                                      fontWeight: FontWeight.w400),
                                  border: InputBorder.none),
                              onChanged: (value) {
                                mainApplicationController.searchText.value =
                                    value;
                              },
                            ),
                            // child: Center(
                            //   child: Row(
                            //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            //     children: [
                            //       Text(
                            //         "search...",
                            //         style: TextStyle(
                            //             color: black.withOpacity(0.5),
                            //             fontSize: 15,
                            //             fontWeight: FontWeight.w400),
                            //       ),
                            //       Icon(
                            //         CupertinoIcons.search,
                            //         color: black.withOpacity(0.5),
                            //       )
                            //     ],
                            //   ),
                            // ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: () async {
                            await chatService.requestPartnerList();
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade500,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Center(
                                child: Icon(
                              Icons.refresh,
                              color: Colors.white,
                              size: 22,
                            )),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Obx(() {
                      var filteredList =
                          mainApplicationController.filteredPartners;
                      if (filteredList.isEmpty) {
                        return SizedBox(
                          height: height * 0.65,
                          child:
                              const Center(child: Text("Partners Not Found.")),
                        );
                      }

                      // if (mainApplicationController.partnerList.isEmpty) {
                      //   return SizedBox(
                      //     // color: Colors.green,
                      //     height: height * 0.65,
                      //     child: Center(
                      //       child: GestureDetector(
                      //         onTap: () async {
                      //           await chatService.requestPartnerList();
                      //         },
                      //         child: Container(
                      //           width: width * 0.5,
                      //           height: 46,
                      //           decoration: BoxDecoration(
                      //               color: appColor.withOpacity(0.5),
                      //               borderRadius: BorderRadius.circular(8)),
                      //           child: const Center(
                      //             child: Text(
                      //               "Re-Load",
                      //               style: TextStyle(
                      //                   color: Colors.white,
                      //                   fontSize: 16,
                      //                   fontWeight: FontWeight.w500),
                      //             ),
                      //           ),
                      //         ),
                      //       ),
                      //     ),
                      //   );
                      // }
                      return ListView.builder(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          itemCount: filteredList.length,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            var item = filteredList[index];
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
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (_) =>
                                                          UserCallScreen(
                                                            partnerId:
                                                                item["_id"],
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
}
