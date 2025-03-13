import 'package:flutter/material.dart';
import 'package:gad_fly/controller/profile_controller.dart';
import 'package:gad_fly/screens/auth/main_login.dart';
import 'package:gad_fly/screens/home/profile/my_profile.dart';
import 'package:gad_fly/screens/home/profile/wallet_screen.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  ProfileController updateProfileController = Get.put(ProfileController());
  bool isLoading = false;

  @override
  void initState() {
    updateProfileController.getProfile();
    super.initState();
  }

  @override
  void dispose() {
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
    var greyMedium1Color = const Color(0xFFDBDBDB);
    return WillPopScope(
      onWillPop: () async {
        // SystemNavigator.pop();
        Navigator.pop(context);
        return false;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: whiteColor,
        body: SafeArea(
          child: Stack(
            children: [
              SizedBox(
                height: height,
                width: width,
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () {
                        Get.to(() => const MyProfileScreen());
                      },
                      child: Obx(() {
                        return Column(
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundColor: appColor,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              (updateProfileController.aNameS.value != "")
                                  ? updateProfileController.aNameS.value
                                  : "your name",
                              style: const TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w500),
                            ),
                            Text(
                              (updateProfileController.emailS.value != "")
                                  ? updateProfileController.emailS.value
                                  : "your email",
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
                    const SizedBox(height: 12),
                    // Settings Section
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade300,
                              blurRadius: 3,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 10),
                            const Text(
                              'Settings',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 6),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => const WalletScreen()));
                              },
                              child: _buildSettingsOption(
                                  Icons.account_balance_wallet_outlined,
                                  'Wallet'),
                            ),
                            _buildSettingsOption(Icons.language,
                                'Choose App Language', 'English'),
                            _buildSettingsOption(
                                Icons.translate, 'My Language'),
                            _buildSettingsOption(
                                Icons.lock, 'Privacy & Security'),
                            _buildSettingsOption(Icons.info, 'Our About Us'),
                            _buildSettingsOption(
                                Icons.card_giftcard, 'Refer & Earn'),
                            _buildSettingsOption(
                                Icons.contact_mail, 'Contact Us'),
                            GestureDetector(
                                onTap: () async {
                                  SharedPreferences prefs =
                                      await SharedPreferences.getInstance();
                                  await prefs.clear();
                                  Get.to(() => const MainLogInScreen());
                                },
                                child: _buildSettingsOption(
                                    Icons.logout, 'Logout')),
                          ],
                        ),
                      ),
                    ),
                  ],
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
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          // Navigator.pushReplacement(
                          //   context,
                          //   MaterialPageRoute(
                          //       builder: (context) => const HomePage()),
                          // );
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 8, horizontal: width * 0.11),
                          decoration: BoxDecoration(
                            color: whiteColor,
                            borderRadius: BorderRadius.circular(28),
                          ),
                          child: Icon(
                            Icons.call,
                            color: blackColor,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                            vertical: 8, horizontal: width * 0.11),
                        decoration: BoxDecoration(
                          color: appColor,
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: Icon(
                          Icons.person,
                          color: whiteColor,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
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
    ListTile(
      leading: Icon(icon, color: Colors.black54),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      subtitle: subtitle != null
          ? Text(subtitle, style: const TextStyle(color: Colors.grey))
          : null,
      onTap: () {},
    );
  }
}
