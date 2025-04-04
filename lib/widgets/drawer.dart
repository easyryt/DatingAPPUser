import 'package:flutter/material.dart';
import 'package:gad_fly/constant/color_code.dart';
import 'package:gad_fly/controller/profile_controller.dart';
import 'package:gad_fly/screens/auth/registration_page.dart';
import 'package:gad_fly/screens/home/profile/my_profile.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

Drawer buildDrawer(double width, double height) {
  final ProfileController updateProfileController =
      Get.put(ProfileController());
  return Drawer(
    child: Container(
      clipBehavior: Clip.antiAlias,
      // padding: const EdgeInsets.only(top: 40, left: 16),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.only(top: 36, left: 16, bottom: 24),
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [appColor, appColor.withOpacity(0.4)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    Get.to(() => const MyProfileScreen());
                  },
                  child: Row(
                    children: [
                      Center(
                        child: CircleAvatar(
                          radius: 24,
                          backgroundColor: Colors.grey[400],
                          child:
                              // updateProfileController.imgUrl.value != ""
                              //     ? Container(
                              //         height: 58,
                              //         width: 58,
                              //         decoration: BoxDecoration(
                              //           borderRadius: BorderRadius.circular(30),
                              //           image: DecorationImage(
                              //               image: NetworkImage(
                              //                   updateProfileController.imgUrl.value),
                              //               fit: BoxFit.cover),
                              //         ),
                              //       )
                              //     :
                              const Icon(Icons.person),
                        ),
                      ),
                      const SizedBox(
                        width: 6,
                      ),
                      Obx(() {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                (updateProfileController.aNameS.value != "")
                                    ? updateProfileController.aNameS.value
                                    : "your name",
                                style: GoogleFonts.roboto(
                                  textStyle: TextStyle(
                                    color: white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                )),
                            Text(
                                (updateProfileController.phoneNumberS.value !=
                                        "")
                                    ? updateProfileController.phoneNumberS.value
                                    : "Your Number",
                                style: GoogleFonts.roboto(
                                  textStyle: TextStyle(
                                    color: Colors.grey.shade400,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                  ),
                                )),
                          ],
                        );
                      }),
                    ],
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16.0, left: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Settings',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                // GestureDetector(
                //   onTap: () {
                //     // Navigator.push(
                //     //     context,
                //     //     MaterialPageRoute(
                //     //         builder: (_) => const WalletScreen()));
                //   },
                //   child: _buildSettingsOption(
                //       Icons.account_balance_wallet_outlined, 'Wallet'),
                // ),
                _buildSettingsOption(
                    Icons.language, 'Choose App Language', 'English'),
                _buildSettingsOption(Icons.translate, 'My Language'),
                _buildSettingsOption(Icons.lock, 'Privacy & Security'),
                _buildSettingsOption(Icons.info, 'Our About Us'),
                _buildSettingsOption(Icons.card_giftcard, 'Refer & Earn'),
                _buildSettingsOption(Icons.contact_mail, 'Contact Us'),
                GestureDetector(
                    onTap: () async {
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      await prefs.clear();
                      Get.to(() => const RegisterScreen());
                    },
                    child: _buildSettingsOption(Icons.logout, 'Logout')),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildSettingsOption(IconData icon, String title, [String? subtitle]) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6),
    child: Row(
      children: [
        Icon(icon, color: Colors.black54),
        const SizedBox(width: 10),
        Expanded(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 16)),
            if (subtitle != null)
              Text(subtitle, style: const TextStyle(color: Colors.grey))
          ],
        ))
      ],
    ),
  );
  // ListTile(
  //   leading: Icon(icon, color: Colors.black54),
  //   title: Text(title, style: const TextStyle(fontSize: 16)),
  //   subtitle: subtitle != null
  //       ? Text(subtitle, style: const TextStyle(color: Colors.grey))
  //       : null,
  //   onTap: () {},
  // );
}
