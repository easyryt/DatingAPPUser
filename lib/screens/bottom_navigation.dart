import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gad_fly/constant/color_code.dart';
import 'package:gad_fly/controller/main_application_controller.dart';
import 'package:gad_fly/widgets/exit_dialog.dart';
import 'package:get/get.dart';

class MainHomeScreen extends StatefulWidget {
  const MainHomeScreen({super.key});

  @override
  State<MainHomeScreen> createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen> {
  final MainApplicationController _mainApplicationController = Get.find();
  // HomeController homeController = Get.put(HomeController());
  // final _advancedDrawerController = AdvancedDrawerController();
  @override
  Widget build(BuildContext context) {
    // Size size = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: () async {
        showDialog(
            barrierDismissible: false,
            context: context,
            builder: (context) => exitDialog(context));
        return false;
      },
      child: Scaffold(
        backgroundColor: white,
        // appBar: PreferredSize(
        //   preferredSize: const Size.fromHeight(kToolbarHeight),
        //   child: Obx(() {
        //     final pageIndex = _mainApplicationController.pageIdx.value;
        //     return
        //         // (pageIndex != 3 && pageIndex != 4)
        //         //   ?
        //         AppBar(
        //       backgroundColor: white,
        //       surfaceTintColor: white,
        //       leading: Builder(
        //         builder: (context) => IconButton(
        //             // icon: Image.asset(
        //             //   "assets/images/drawerIcon.png",
        //             //   width: 24,
        //             //   fit: BoxFit.fitWidth,
        //             // ),
        //             icon: const Icon(Icons.menu),
        //             onPressed: () {} //=> _advancedDrawerController.showDrawer(),
        //             ),
        //       ),
        //       actions: const [
        //         // Obx(() {
        //         //   return InkWell(
        //         //     onTap: () {
        //         //       // Get.to(() => const ClassesScreen());
        //         //     },
        //         //     child: Container(
        //         //       height: 32,
        //         //       padding: const EdgeInsets.symmetric(horizontal: 10),
        //         //       decoration: BoxDecoration(
        //         //           border:
        //         //               Border.all(color: black.withOpacity(0.1), width: 1),
        //         //           borderRadius: BorderRadius.circular(20)),
        //         //       child: Center(
        //         //         child: Row(
        //         //           children: [
        //         //             // SizedBox(
        //         //             //   width: size.width * 0.45,
        //         //             //   child: Text(
        //         //             //     (_mainApplicationController.className.value !=
        //         //             //             "")
        //         //             //         ? _mainApplicationController.className.value
        //         //             //         : "Select Your Class",
        //         //             //     maxLines: 1,
        //         //             //     overflow: TextOverflow.ellipsis,
        //         //             //     style: GoogleFonts.roboto(
        //         //             //         textStyle: const TextStyle(
        //         //             //             fontWeight: FontWeight.w500,
        //         //             //             fontSize: 13)),
        //         //             //   ),
        //         //             // ),
        //         //             const SizedBox(
        //         //               width: 2,
        //         //             ),
        //         //             Icon(
        //         //               Icons.arrow_forward_ios,
        //         //               size: 12,
        //         //               color: black.withOpacity(0.4),
        //         //             )
        //         //           ],
        //         //         ),
        //         //       ),
        //         //     ),
        //         //   );
        //         // }),
        //         SizedBox(
        //           width: 16,
        //         )
        //       ],
        //     );
        //     // : const SizedBox();
        //   }),
        // ),
        // drawer: buildDrawer(size.width, size.height),
        body: Obx(() {
          return _mainApplicationController
              .homeWidgets[_mainApplicationController.pageIdx.value];
        }),
        bottomNavigationBar: Obx(() {
          // if (_mainApplicationController.pageIdx.value == 3) {
          //   return const SizedBox.shrink();
          // }
          return Container(
            decoration: BoxDecoration(
              // image: DecorationImage(
              //   image: AssetImage('assets/images/bottom_navigation.png'),
              //   fit: BoxFit.cover,
              // ),
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16), topRight: Radius.circular(16)),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey[300]!,
                  blurRadius: 2,
                  spreadRadius: 3,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
            child: BottomNavigationBar(
              elevation: 0,
              backgroundColor: Colors.transparent,
              type: BottomNavigationBarType.fixed,
              onTap: (index) {
                _mainApplicationController.pageIdx.value = index;
              },
              selectedItemColor: appColor,
              unselectedItemColor: grey.withOpacity(0.7),
              currentIndex: _mainApplicationController.pageIdx.value,
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
                //  BottomNavigationBarItem(icon: Icon(Icons.call), label: "Call"),
                BottomNavigationBarItem(
                    icon: Icon(CupertinoIcons.chat_bubble_2), label: "Chat"),
                BottomNavigationBarItem(
                    icon: Icon(Icons.history), label: "History"),
              ],
            ),
          );
        }),
      ),
    );
  }
}
