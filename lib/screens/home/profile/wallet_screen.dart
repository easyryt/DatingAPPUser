import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gad_fly/constant/color_code.dart';
import 'package:gad_fly/controller/main_application_controller.dart';
import 'package:gad_fly/controller/profile_controller.dart';
import 'package:gad_fly/screens/home/profile/transaction_history_screen.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  _WalletScreenState createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  ProfileController profileController = Get.find();
  MainApplicationController mainApplicationController = Get.find();
  int selectedIndex = 0;

  Razorpay razorpay = Razorpay();
  String orderId = '';
  // final List<Map<String, dynamic>> rechargePacks = [
  //   {'amount': 84, 'benefit': 199, 'sale': false},
  //   {'amount': 199, 'benefit': 299, 'sale': true},
  //   {'amount': 499, 'benefit': 600, 'sale': false},
  // ];

  initFunction() async {
    await mainApplicationController.getRechargeOffer();
  }

  @override
  void initState() {
    initFunction();
    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, handlePaymentSuccess);
    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, handlePaymentError);
    razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, handleExternalWallet);
    super.initState();
  }

  @override
  void dispose() {
    razorpay.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // var height = MediaQuery.of(context).size.height;
    // var width = MediaQuery.of(context).size.width;
    var whiteColor = Colors.white;
    var blackColor = Colors.black;
    var appColor = const Color(0xFF8CA6DB);
    // var appYellow = const Color(0xFFFFE30F);
    // var appGreenColor = const Color(0xFF35D673);
    var greyMedium1Color = const Color(0xFFDBDBDB);
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        backgroundColor: whiteColor,
        surfaceTintColor: whiteColor,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back_ios_new,
              size: 18,
            )),
        title: const Text(
          'My Wallet',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        actions: const [Icon(Icons.info_outline), SizedBox(width: 16)],
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              //color: Colors.white,
              gradient: LinearGradient(colors: [
                whiteColor,
                whiteColor,
                appColor,
              ], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade300,
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Wallet Balance",
                    style: TextStyle(
                        color: blackColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 5),
                Obx(() {
                  return Text(
                    "₹${profileController.amount}",
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.w600),
                  );
                }),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () {
                      Get.to(() => const TransactionHistoryScreen());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: whiteColor,
                      foregroundColor: appColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text("Transaction"),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          const Text("Select Recharge Pack",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Obx(() {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                  mainApplicationController.rechargeOfferList.length > 3
                      ? 3
                      : mainApplicationController.rechargeOfferList.length,
                  (index) {
                return GestureDetector(
                  onTap: () async {
                    setState(() {
                      selectedIndex = index;
                    });
                    String? razorpayKey;
                    String? rechargeId;
                    rechargeId = mainApplicationController
                        .rechargeOfferList[index]["_id"];
                    Map<String, Object> paymentMethod;

                    await mainApplicationController
                        .fetchRazorpayKey()
                        .then((onValue) async {
                      if (onValue != null) {
                        razorpayKey = onValue;
                        // if (promoCode ==
                        //         "no promo" ||
                        //     promoCode ==
                        //         "")
                        // {
                        paymentMethod = {
                          //  "paymentMethod": {"cod": false, "online": true}
                        };
                        // } else {
                        //   paymentMethod =
                        //       {
                        //     "paymentMethod":
                        //         {
                        //       "cod":
                        //           false,
                        //       "online":
                        //           true
                        //     },
                        //     "couponCode":
                        //         promoCode
                        //   };
                        // }
                        await mainApplicationController
                            .transactionCreate(paymentMethod, rechargeId)
                            .then((onValue) async {
                          if (onValue != null) {
                            orderId = onValue["transaction"]["_id"];
                            openCheckOut(
                              "${onValue["transaction"]["amount"]}",
                              razorpayKey!,
                              onValue["razorpayOrder"]["id"],
                            );
                          } else {
                            Get.snackbar("Alert",
                                "Something went wrong Order Not Created");
                          }
                        });
                      } else {
                        Get.snackbar("Warning",
                            "Something went wrong with Online Method ");
                        Navigator.of(context).pop();
                      }
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 16),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: selectedIndex == index
                              ? appColor
                              : Colors.grey.shade300,
                          width: 2),
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(color: Colors.grey.shade200, blurRadius: 2),
                      ],
                    ),
                    child: Column(
                      children: [
                        // if (mainApplicationController.rechargeOfferList[index]
                        //     ['sale'])
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text("Sale 30%",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 10)),
                        ),
                        const SizedBox(height: 5),
                        Text(
                            "₹${mainApplicationController.rechargeOfferList[index]['rechargeAmount']}",
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 5),
                        Text(
                            "Get ₹${mainApplicationController.rechargeOfferList[index]['offer']}",
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ),
                );
              }),
            );
          }),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            color: greyMedium1Color,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildBottomOption(Icons.verified_user, "Secure Checkout"),
                _buildBottomOption(Icons.emoji_events, "Secure Checkout"),
                _buildBottomOption(Icons.lock, "Secure Checkout"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void openCheckOut(grandTotal, razorpayKey, razorPayOrderId) async {
    var amount = double.parse(grandTotal) * 100;
    var name = profileController.aNameS.value;
    var phoneNumber = profileController.phoneNumberS.value;
    var email = profileController.emailS.value;
    var options = {
      "key": razorpayKey,
      "amount": amount,
      "name": "Pulse Advi",
      "description": "Payment add in wallet for call and message ",
      "order_id": razorPayOrderId,
      "currency": "INR",
      "Prefill": {
        "name": name,
        "contact": phoneNumber,
        "email": email,
      },
      "theme": {"color": "#3399cc"},
    };
    try {
      razorpay.open(options);
    } catch (e) {
      debugPrint('Error : $e');
    }
  }

  void handlePaymentSuccess(PaymentSuccessResponse response) async {
    await mainApplicationController
        .verifyPayment(orderId, response)
        .then((onValue) async {
      Navigator.pop(context);
      if (onValue != "") {
        profileController.amount.value =
            double.parse("${onValue["walletAmount"]}");
        await showDialog(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) {
            return Dialog(
              insetPadding: const EdgeInsets.symmetric(horizontal: 16),
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Container(
                padding: const EdgeInsets.all(8),
                height: 190,
                width: MediaQuery.of(context).size.width,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Image.asset(
                      //   "assets/images/thnku.png",
                      //   height: 180,
                      //   fit: BoxFit.contain,
                      // ),
                      const SizedBox(height: 6),
                      Text(
                        'Thank you for Add Money!',
                        style: GoogleFonts.roboto(
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12.0),
                        child: Text(
                          ' We’re thrilled to refresh you with Your Callie!',
                          style: GoogleFonts.roboto(
                            textStyle: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Colors.black45,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // ElevatedButton(
                          //   style: ElevatedButton.styleFrom(
                          //     backgroundColor: Colors.white,
                          //     padding:
                          //         const EdgeInsets.symmetric(horizontal: 16),
                          //     shape: RoundedRectangleBorder(
                          //       side: const BorderSide(
                          //           color: Colors.grey, width: 0.8),
                          //       borderRadius: BorderRadius.circular(6),
                          //     ),
                          //   ),
                          //   onPressed: () async {
                          //     // Get.to(() => OrderSummaryScreen(
                          //     //       id: onValue["_id"],
                          //     //       isFromOrderScreen: false,
                          //     //     ));
                          //     Navigator.of(context).pop();
                          //   },
                          //   child: Text(
                          //     'VIEW ',
                          //     style: GoogleFonts.roboto(
                          //       textStyle: const TextStyle(
                          //         fontWeight: FontWeight.w600,
                          //         color: Colors.black,
                          //       ),
                          //     ),
                          //   ),
                          // ),
                          const SizedBox(width: 4),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: appColor,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            onPressed: () async {
                              Navigator.of(context).pop();
                              // mainApplicationController.pageIdx.value = 0;
                              // Get.to(() => const MainHomeScreen());
                            },
                            child: Text(
                              'OK',
                              style: GoogleFonts.roboto(
                                textStyle: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      } else {
        Get.snackbar("Alert", "Payment verification Failed");
      }
    });
    // Fluttertoast.showToast(
    //     msg: "Payment Success ${response.paymentId!}",
    //     toastLength: Toast.LENGTH_SHORT);
  }

  void handlePaymentError(PaymentFailureResponse response) {
    Fluttertoast.showToast(
        msg: "Payment Fail ${response.message!}",
        toastLength: Toast.LENGTH_SHORT);
  }

  void handleExternalWallet(ExternalWalletResponse response) {
    Fluttertoast.showToast(
        msg: "External Wallet ${response.walletName!}",
        toastLength: Toast.LENGTH_SHORT);
  }

  Widget _buildBottomOption(IconData icon, String text) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.black54),
        const SizedBox(height: 5),
        Text(text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, color: Colors.black54)),
      ],
    );
  }
}
