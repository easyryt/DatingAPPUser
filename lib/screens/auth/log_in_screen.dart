import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gad_fly/constant/api_end_point.dart';
import 'package:gad_fly/controller/main_application_controller.dart';
import 'package:gad_fly/screens/auth/email_sign_up.dart';
import 'package:gad_fly/screens/bottom_navigation.dart';
import 'package:gad_fly/widgets/elevated_button.dart';
import 'package:gad_fly/widgets/snackbar.dart';
import 'package:gad_fly/widgets/text_form_field.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LogInScreen extends StatefulWidget {
  const LogInScreen({super.key});

  @override
  State<LogInScreen> createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
  MainApplicationController mainApplicationController = Get.find();
  bool isLoading = false;

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    var whiteColor = Colors.white;
    var blackColor = Colors.black;
    var appColor = const Color(0xFF8CA6DB);
    // var appGreenColor = const Color(0xFF35D673);
    return
        // isLoggedIn
        //   ? const MainHomeScreen()
        //   :
        Scaffold(
      backgroundColor: whiteColor,
      body: Container(
        height: height,
        width: width,
        padding: EdgeInsets.symmetric(horizontal: width * 0.05),
        // decoration: const BoxDecoration(
        //   image: DecorationImage(
        //       image: AssetImage("assets/new_version/register_back.png"),
        //       fit: BoxFit.cover),
        // ),
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: height * 0.95,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: height * 0.15,
                        ),
                        Text(
                          'Welcome',
                          style: TextStyle(
                              color: blackColor,
                              fontSize: height * 0.06,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Back',
                          style: TextStyle(
                              color: blackColor,
                              fontSize: height * 0.035,
                              fontWeight: FontWeight.w400),
                        ),
                        SizedBox(
                          height: height * 0.08,
                        ),
                        textFormFieldWidget(
                          isDense: true,
                          controller: emailController,
                          cursorColor: blackColor,
                          textStyleColor: blackColor,
                          focusedBorderColor: blackColor,
                          labelColor: blackColor,
                          labelText: "Email Address",
                        ),
                        SizedBox(
                          height: height * 0.04,
                        ),
                        textFormFieldWidget(
                          isDense: true,
                          controller: passwordController,
                          cursorColor: blackColor,
                          textStyleColor: blackColor,
                          focusedBorderColor: blackColor,
                          labelColor: blackColor,
                          labelText: "Password",
                        ),
                        SizedBox(
                          height: height * 0.04,
                        ),
                        elevatedButton(
                          onPressed: () async {
                            setState(() {
                              isLoading = true;
                            });
                            await loginAccount();
                            setState(() {
                              isLoading = false;
                            });
                          },
                          color: appColor,
                          imageLink: null,
                          imageColor: null,
                          title: 'Continue',
                          textColor: whiteColor,
                          borderColor: appColor,
                          height: height * 0.065,
                          borderRadius: 10,
                          borderWidth: 2,
                        ),
                        SizedBox(
                          height: height * 0.03,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'You Have\'t an Account?',
                              style: TextStyle(
                                  color: blackColor.withOpacity(0.3),
                                  fontSize: width * 0.035,
                                  fontWeight: FontWeight.w400),
                            ),
                            const SizedBox(
                              width: 4,
                            ),
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            const EmailSignUpScreen()));
                              },
                              child: Text(
                                'Sign Up',
                                style: TextStyle(
                                    color: blackColor,
                                    fontSize: width * 0.04,
                                    fontWeight: FontWeight.w400),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: height * 0.03,
                        ),
                        Row(
                          children: [
                            Container(
                              color: const Color(0xFF323232),
                              height: 1,
                              width: width * 0.27,
                            ),
                            SizedBox(
                              width: width * 0.01,
                            ),
                            InkWell(
                              onTap: () {
                                // Navigator.push(
                                //     context,
                                //     MaterialPageRoute(
                                //         builder: (_) => ResetPassword(
                                //             fcmToken: widget.fcmToken)));
                              },
                              child: Text(
                                'Forgot Password',
                                style: TextStyle(
                                    color: blackColor,
                                    fontSize: height * 0.02,
                                    fontWeight: FontWeight.w400),
                              ),
                            ),
                            SizedBox(
                              width: width * 0.01,
                            ),
                            Container(
                              color: const Color(0xFF323232),
                              height: 1,
                              width: width * 0.27,
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: height * 0.05,
                    // color: Colors.red,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        InkWell(
                          onTap: () {
                            // Navigator.push(
                            //     context,
                            //     MaterialPageRoute(
                            //         builder: (_) =>
                            //             const TermCondition()));
                          },
                          child: Text(
                            'Terms Of Use',
                            style: TextStyle(
                                color: blackColor,
                                fontSize: height * 0.02,
                                fontWeight: FontWeight.w400),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            // Navigator.push(
                            //     context,
                            //     MaterialPageRoute(
                            //         builder: (_) =>
                            //             const PrivacyPolicy()));
                          },
                          child: Text(
                            'Privacy Policy',
                            style: TextStyle(
                                color: blackColor,
                                fontSize: height * 0.02,
                                fontWeight: FontWeight.w400),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            Positioned(
                child: isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(blackColor),
                      ))
                    : Container())
          ],
        ),
      ),
    );
  }

  Future<void> loginAccount() async {
    Uri uri = Uri.parse('${ApiEndpoints.baseUrl}/user/authAndWallet/logIn');

    try {
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          "email": emailController.text.toString(),
          "password": passwordController.text.toString(),
          // "fcmToken": widget.fcmToken,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final authToken = responseData['token'];
        await saveTokenToSharedPreferences(authToken);
        mainApplicationController.authToken.value = authToken;
        // if (kDebugMode) {
        //     print(responseData['message']);
        // }
        // LocalNotification.showNotification(
        //   id: 0,
        //   title: 'Welcome To NotaAi ♥',
        //   body: 'You Have Successfully Login',
        //   payload: 'this is Notification',
        // );
        if (mounted) {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (_) => const MainHomeScreen()));
          snackBar(responseData['message'], context);
        }
      } else {
        final responseData = json.decode(response.body);
        if (mounted) {
          snackBar(responseData['message'], context);
        }
      }
    } catch (error) {
      if (kDebugMode) {
        print('Error occurred: $error');
      }
    }
  }

  Future<void> saveTokenToSharedPreferences(String authToken) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', authToken);
  }
}
