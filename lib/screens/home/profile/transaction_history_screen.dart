import 'package:flutter/material.dart';
import 'package:gad_fly/controller/main_application_controller.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  MainApplicationController mainApplicationController = Get.find();
  @override
  void initState() {
    mainApplicationController.getTransaction();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // var size = MediaQuery.of(context).size;

    var whiteColor = Colors.white;
    // var blackColor = Colors.black;
    var appColor = const Color(0xFF8CA6DB);
    // var appYellow = const Color(0xFFFFE30F);
    // var appGreenColor = const Color(0xFF35D673);
    // var greyMedium1Color = const Color(0xFFDBDBDB);
    var greyColor = Colors.grey;
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
        automaticallyImplyLeading: false,
        title: const Text(
          'Payment History',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        // actions: const [Icon(Icons.info_outline), SizedBox(width: 16)],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: mainApplicationController.getTransactionList.length,
          physics: const AlwaysScrollableScrollPhysics(),
          reverse: true,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            var item = mainApplicationController.getTransactionList[index];

            var amount = item["amount"] ?? "0";
            var offer = item["offer"] ?? "0";
            var transactionDate = item["transactionDate"];
            var razorpayPaymentStatus =
                item["paymentInfo"]["razorpay_paymentStatus"];

            return GestureDetector(
              onTap: () {},
              child: Container(
                margin: const EdgeInsets.only(bottom: 12, top: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey[300]!,
                      blurRadius: 1,
                      spreadRadius: 0,
                      offset: const Offset(0, 0),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 10, right: 8, left: 8, bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: appColor.withOpacity(0.2),
                            child: const Center(
                              child: Icon(
                                Icons.history,
                                size: 20,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  child: Text("$amount",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.roboto(
                                        textStyle: const TextStyle(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      )),
                                ),
                                const SizedBox(height: 3),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.calendar_month_sharp,
                                      color: Colors.green,
                                      size: 16,
                                    ),
                                    SizedBox(
                                      child: Text(
                                          mainApplicationController
                                              .formatDate(transactionDate),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: GoogleFonts.roboto(
                                            textStyle: TextStyle(
                                              color: greyColor.shade600,
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          )),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            child: Text("$razorpayPaymentStatus",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.roboto(
                                  textStyle: const TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w500,
                                  ),
                                )),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
