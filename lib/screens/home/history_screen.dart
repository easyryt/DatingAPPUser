import 'package:flutter/material.dart';
import 'package:gad_fly/constant/color_code.dart';
import 'package:gad_fly/controller/main_application_controller.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  MainApplicationController mainApplicationController = Get.find();
  @override
  void initState() {
    mainApplicationController.getAllTransaction();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    var whiteColor = Colors.white;
    var blackColor = Colors.black;
    var appColor = const Color(0xFF8CA6DB);
    var appYellow = const Color(0xFFFFE30F);
    var appGreenColor = const Color(0xFF35D673);
    var greyMedium1Color = const Color(0xFFDBDBDB);
    var greyColor = Colors.grey;
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        backgroundColor: whiteColor,
        surfaceTintColor: whiteColor,
        // leading: IconButton(
        //     onPressed: () {
        //       Navigator.pop(context);
        //     },
        //     icon: const Icon(
        //       Icons.arrow_back_ios_new,
        //       size: 18,
        //     )),
        automaticallyImplyLeading: false,
        title: const Text(
          'History',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        // actions: const [Icon(Icons.info_outline), SizedBox(width: 16)],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: mainApplicationController.transactionList.length,
          physics: const AlwaysScrollableScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: (context, index) {
            var item = mainApplicationController.transactionList[index];

            var title = item["partner"]["avatarName"] ?? "No Title Found";
            var startDate = item["startTime"];
            var endDate = item["endTime"];
            //var imgUrl = item["thumbnailImg"]["url"];
            var duration = item["duration"] ?? "";
            var userCost = item["userCost"] ?? 0.0;

            return GestureDetector(
              onTap: () {
                // Get.to(() => BatchDetailsMainPage(
                //   batchId: batchId,
                //   // classId: clsId,
                //   batchName: title,
                //   price: double.parse("$price"),
                //   discount: discount,
                //   isFree: isFree,
                //   mrp: double.parse("$mrp"),
                // ));
              },
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
                            backgroundColor: appColor,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  child: Text("$title",
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
                                      Icons.call_received,
                                      color: Colors.green,
                                      size: 16,
                                    ),
                                    SizedBox(
                                      child: Text(
                                          mainApplicationController
                                              .formatDate(endDate),
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
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              SizedBox(
                                child: Text("${userCost.toStringAsFixed(2)}₹",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.roboto(
                                      textStyle: TextStyle(
                                        color: black,
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    )),
                              ),
                              const SizedBox(height: 3),
                              SizedBox(
                                child: Text("$duration",
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
