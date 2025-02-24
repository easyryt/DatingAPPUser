import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gad_fly/constant/api_end_point.dart';
import 'package:gad_fly/screens/auth/log_in_screen.dart';
import 'package:gad_fly/widgets/elevated_button.dart';
import 'package:gad_fly/widgets/snackbar.dart';
import 'package:gad_fly/widgets/text_form_field.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

class EmailSignUpScreen extends StatefulWidget {
  const EmailSignUpScreen({super.key});

  @override
  State<EmailSignUpScreen> createState() => _EmailSignUpScreenState();
}

class _EmailSignUpScreenState extends State<EmailSignUpScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    var whiteColor = Colors.white;
    var blackColor = Colors.black;
    var appColor = const Color(0xFF8CA6DB);
    var appGreenColor = const Color(0xFF35D673);
    var greyMedium1Color = const Color(0xFFDBDBDB);
    return Scaffold(
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
                          'Create your',
                          style: TextStyle(
                              color: blackColor,
                              fontSize: height * 0.035,
                              fontWeight: FontWeight.w400),
                        ),
                        Text(
                          'Account',
                          style: TextStyle(
                              color: blackColor,
                              fontSize: height * 0.06,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: height * 0.08,
                        ),
                        textFormFieldWidget(
                          isDense: true,
                          controller: nameController,
                          textStyleColor: blackColor,
                          cursorColor: blackColor,
                          focusedBorderColor: blackColor,
                          labelColor: blackColor,
                          labelText: "Full Name",
                        ),
                        SizedBox(
                          height: height * 0.04,
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
                            await createAccountOfUser();
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
                              'Already Have an Account?',
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
                                        builder: (_) => const LogInScreen()));
                              },
                              child: Text(
                                'Log in',
                                style: TextStyle(
                                    color: blackColor,
                                    fontSize: width * 0.04,
                                    fontWeight: FontWeight.w400),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: height * 0.05,
                    //color: Colors.red,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        InkWell(
                          onTap: () {
                            // Navigator.push(
                            //     context,
                            //     MaterialPageRoute(
                            //         builder: (_) => const TermCondition()));
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
                            //         builder: (_) => const PrivacyPolicy()));
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

  Future<void> createAccountOfUser() async {
    Uri uri = Uri.parse('${ApiEndpoints.baseUrl}/user/authAndWallet/register');

    try {
      Response response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          "name": nameController.text.toString(),
          "email": emailController.text.toString(),
          "password": passwordController.text.toString(),
        }),
      );

      if (response.statusCode == 200 && response.statusCode == 201) {
        final responseData = json.decode(response.body);

        if (kDebugMode) {
          //  print(responseData['message']);
        }
        if (mounted) {
          // Navigator.pushReplacement(
          //     context,
          //     MaterialPageRoute(
          //         builder: (_) => OtpVerificationScreen(
          //               email: emailController.text,
          //               name: nameController.text,
          //               password: passwordController.text.toString(),
          //               fcmToken: widget.fcmToken,
          //             )));
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
}
