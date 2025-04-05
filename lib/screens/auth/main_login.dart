import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gad_fly/controller/main_application_controller.dart';
import 'package:gad_fly/screens/auth/email_sign_up.dart';
import 'package:gad_fly/screens/auth/log_in_screen.dart';
import 'package:gad_fly/screens/bottom_navigation.dart';
import 'package:gad_fly/widgets/elevated_button.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainLogInScreen extends StatefulWidget {
  const MainLogInScreen({super.key});

  @override
  State<MainLogInScreen> createState() => _MainLogInScreenState();
}

class _MainLogInScreenState extends State<MainLogInScreen> {
  MainApplicationController mainApplicationController =
      Get.put(MainApplicationController());
  bool isLoading = false;
  String? fcmToken;

  bool isLoggedIn = false;

  Future<void> loadJwtToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? authToken = prefs.getString('token');
    setState(() {
      isLoggedIn = authToken != null;
      if (authToken != null) {
        mainApplicationController.authToken.value = authToken;
      }
    });
    print(authToken);
  }

  @override
  void initState() {
    loadJwtToken();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    var whiteColor = Colors.white;
    var blackColor = Colors.black;
    var appColor = const Color(0xFF8CA6DB);
    // var appGreenColor = const Color(0xFF35D673);
    // var greyMedium1Color = const Color(0xFFDBDBDB);
    return isLoggedIn
        ? const MainHomeScreen()
        : Scaffold(
            backgroundColor: whiteColor,
            resizeToAvoidBottomInset: false,
            body: Stack(
              children: [
                Container(
                  height: height,
                  width: width,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          colors: [appColor, whiteColor, whiteColor],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter)),
                  child: Column(
                    children: [
                      SizedBox(height: height * 0.32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
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
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(height: 28),
                            // Padding(
                            //   padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            //   child: elevatedButton(
                            //     onPressed: () async {
                            //       setState(() {
                            //         isLoading = true;
                            //       });
                            //       await GoogleServices()
                            //           .googleAuthentication(context, fcmToken);
                            //       setState(() {
                            //         isLoading = false;
                            //       });
                            //       //  snackBar("Please SignUp With Email", context);
                            //     },
                            //     color: whiteColor,
                            //     imageLink: "assets/images/google.png",
                            //     imageColor: null,
                            //     title: 'Continue with Google',
                            //     textColor: blackColor,
                            //     borderColor: whiteColor,
                            //     height: 48.0,
                            //     borderRadius: 8,
                            //     borderWidth: 1,
                            //   ),
                            // ),
                            ///
                            SizedBox(height: height * 0.02),
                            Card(
                              child: elevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            const EmailSignUpScreen()),
                                  );
                                },
                                color: whiteColor,
                                imageLink: null,
                                imageColor: null,
                                title: 'Registered with Gmail',
                                textColor: blackColor,
                                borderColor: whiteColor,
                                height: 44.0,
                                borderRadius: 8,
                                borderWidth: 1,
                              ),
                            ),
                            SizedBox(height: height * 0.02),
                            Card(
                              child: elevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => LogInScreen()));
                                },
                                color: whiteColor,
                                imageLink: null,
                                imageColor: null,
                                title: 'Log in',
                                textColor: blackColor,
                                borderColor: whiteColor,
                                height: 44.0,
                                borderRadius: 8,
                                borderWidth: 1,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Align(
                              alignment: Alignment.center,
                              child: RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  style: Theme.of(context).textTheme.bodyLarge,
                                  children: [
                                    TextSpan(
                                      text: 'By continuing, you agree to our ',
                                      style: TextStyle(
                                          color: blackColor.withOpacity(0.3),
                                          fontSize: 13),
                                    ),
                                    TextSpan(
                                      text: 'terms ',
                                      style: TextStyle(
                                          color: blackColor,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          // Get.to(() => const TermCondition());
                                        },
                                    ),
                                    TextSpan(
                                      text: 'and acknowledge our ',
                                      style: TextStyle(
                                          color: blackColor.withOpacity(0.3),
                                          fontSize: 13),
                                    ),
                                    TextSpan(
                                      text: 'Privacy Policy',
                                      style: TextStyle(
                                          color: blackColor,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          //  Get.to(() => const PrivacyPolicy());
                                        },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ))
                    : const SizedBox()
              ],
            ),
          );
  }

  // _requestNotificationPermissions() async {
  //   PermissionStatus status = await Permission.notification.request();
  //   if (status.isGranted) {
  //     if (kDebugMode) {
  //       print('Notification permissions granted');
  //     }
  //   } else {
  //     if (kDebugMode) {
  //       print('Notification permissions denied');
  //     }
  //   }
  // }
}
