import 'package:flutter/material.dart';
import 'package:gad_fly/constant/color_code.dart';
import 'package:gad_fly/controller/main_application_controller.dart';
import 'package:gad_fly/controller/profile_controller.dart';
import 'package:gad_fly/screens/bottom_navigation.dart';
import 'package:gad_fly/widgets/gradient_color_widget.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class YourProfileCreate extends StatefulWidget {
  const YourProfileCreate({super.key});

  @override
  State<YourProfileCreate> createState() => _YourProfileCreateState();
}

class _YourProfileCreateState extends State<YourProfileCreate> {
  int _currentIndex = 0;
  MainApplicationController mainApplicationController =
      Get.put(MainApplicationController());
  ProfileController profileController = Get.put(ProfileController());
  final PageController _pageController = PageController(initialPage: 0);
  final formKey = GlobalKey<FormState>();
  TextEditingController realNameController = TextEditingController();
  TextEditingController displayNameController = TextEditingController();
  String _gender = 'male';
  String _intersted = 'female';
  TextEditingController languagesController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  final List<String> _languages = [];

  bool isLoading = false;

  @override
  void initState() {
    profileController.getProfile().then((onValue) {
      if (onValue != null) {
        profileController.amount.value =
            double.parse("${onValue["data"]["walletAmount"]}");
        if (onValue["data"]["avatarName"] != null &&
            onValue["data"]["gender"] != null) {
          Get.offAll(() => const MainHomeScreen());
        }
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: white,
      // resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14.0),
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              "Finish your profile : ",
                              style: TextStyle(
                                  color: black,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 22),
                            ),
                            // Row(
                            //   children: [
                            //     Text(
                            //       "Start ",
                            //       style: TextStyle(
                            //           color: black,
                            //           fontWeight: FontWeight.w500,
                            //           fontSize: 22),
                            //     ),
                            //     Text(
                            //       "Earning ",
                            //       style: TextStyle(
                            //           color: appColorR,
                            //           fontWeight: FontWeight.w500,
                            //           fontSize: 22),
                            //     ),
                            //     Icon(
                            //       CupertinoIcons.money_dollar_circle,
                            //       size: 24,
                            //       color: appColorR,
                            //     )
                            //   ],
                            // ),
                          ],
                        ),
                        // if (_currentIndex < 1)
                        GestureDetector(
                          onTap: () {
                            Get.to(() => const MainHomeScreen());
                          },
                          child: Container(
                              margin: const EdgeInsets.only(top: 8),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 3),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: GradientBorder(
                                  borderGradient: LinearGradient(
                                    colors: [
                                      appColorR,
                                      appColorP,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Text(
                                    "SKIP  ",
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  Container(
                                      padding: const EdgeInsets.all(3),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        border: GradientBorder(
                                          borderGradient: LinearGradient(
                                            colors: [
                                              appColorR,
                                              appColorP,
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          width: 1,
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.arrow_forward_ios,
                                        size: 10,
                                        color: appColorR,
                                      )),
                                ],
                              )),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Expanded(
                      child: PageView.builder(
                        itemCount: 1,
                        controller: _pageController,
                        // physics: const NeverScrollableScrollPhysics(),
                        // pageSnapping: true,
                        onPageChanged: (index) {
                          setState(() {
                            _currentIndex = index;
                          });
                        },
                        itemBuilder: (context, index) {
                          return buildPage(context, index);
                        },
                      ),
                    ),
                    Container(
                      width: width,
                      height: 60,
                      // color: Colors.red,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () async {
                              // if (_currentIndex < 2) {
                              //   if (formKey.currentState!.validate()) {
                              //     _pageController.nextPage(
                              //       duration: const Duration(milliseconds: 500),
                              //       curve: Curves.easeInOut,
                              //     );
                              //   }
                              // } else {

                              if (formKey.currentState!.validate()) {
                                final profileData = {
                                  "name": realNameController.text,
                                  "avatarName": displayNameController.text,
                                  "gender": _gender,
                                  "intersted": _intersted,
                                  "languages": _languages,
                                  //   "email": emailController.text,
                                };
                                setState(() {
                                  isLoading = true;
                                });
                                await profileController
                                    .profileUpdate(profileData)
                                    .then((onValue) {
                                  if (onValue == true) {
                                    Get.snackbar(
                                        "wow", "profile create successfully");
                                    // if (widget.isRegistration) {
                                    Get.to(() => const MainHomeScreen());
                                    // }
                                  } else {
                                    Get.snackbar(
                                        "Alert", "profile create failed");
                                  }
                                });
                                setState(() {
                                  isLoading = false;
                                });
                              }
                              // }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 12),
                              margin: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 4),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  // color: grey.withOpacity(0.2),
                                  gradient: LinearGradient(
                                    colors: [
                                      appColorR,
                                      appColorR,
                                      appColorP,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  )),
                              child: Center(
                                child: Text(
                                    // _currentIndex < 2 ? "Next" :
                                    "Submit",
                                    style: TextStyle(
                                        color: white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500)),
                              ),
                            ),
                          ),
                          // Row(
                          //   mainAxisAlignment: MainAxisAlignment.start,
                          //   children: <Widget>[
                          //     const SizedBox(width: 8),
                          //     sliderContainerDot(0),
                          //     //  const SizedBox(width: 8),
                          //     // sliderContainerDot(1),
                          //     //  const SizedBox(width: 8),
                          //     // sliderContainerDot(2),
                          //     //  const SizedBox(width: 8),
                          //     // sliderContainerDot(3),
                          //   ],
                          // ),
                          // const Spacer(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (isLoading)
              const Positioned(
                  top: 0,
                  bottom: 0,
                  right: 0,
                  left: 0,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ))
          ],
        ),
      ),
    );
  }

  Widget buildPage(BuildContext context, int index) {
    switch (index) {
      case 0:
        return Card(
          color: white,
          surfaceTintColor: white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  const Text(
                    "Original Name",
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                  ),
                  TextFormField(
                    controller: realNameController,
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: 'Original Name',
                      hintStyle: const TextStyle(),
                      filled: true,
                      fillColor: greyMedium1Color.withOpacity(0.3),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                              color: greyMedium1Color.withOpacity(0.6),
                              width: 1)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                              color: greyMedium1Color.withOpacity(0.6),
                              width: 1)),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter Original name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Display Name",
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                  ),
                  TextFormField(
                    controller: displayNameController,
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: 'Display Name',
                      hintStyle: const TextStyle(),
                      filled: true,
                      fillColor: greyMedium1Color.withOpacity(0.3),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                              color: greyMedium1Color.withOpacity(0.6),
                              width: 1)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                              color: greyMedium1Color.withOpacity(0.6),
                              width: 1)),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter Display Name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Spoken Languages",
                          style: TextStyle(
                              fontWeight: FontWeight.w500, fontSize: 14)),
                      Wrap(
                        spacing: 8.0,
                        children: _languages
                            .map((lang) => Chip(
                                  backgroundColor: white,
                                  surfaceTintColor: white,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                      side: BorderSide(
                                          color: greyMedium1Color, width: 1)),
                                  label: Text(lang),
                                  deleteIcon: const Icon(Icons.close, size: 18),
                                  onDeleted: () =>
                                      setState(() => _languages.remove(lang)),
                                ))
                            .toList(),
                      ),
                      TextFormField(
                        controller: languagesController,
                        // readOnly: true,
                        decoration: InputDecoration(
                          isDense: true,
                          hintText: 'Add Language',
                          hintStyle: const TextStyle(),
                          filled: true,
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () async {
                              if (languagesController.text.isNotEmpty) {
                                setState(() {
                                  _languages.add(languagesController.text);
                                  languagesController.clear();
                                });
                              }
                            },
                          ),
                          fillColor: greyMedium1Color.withOpacity(0.3),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                  color: greyMedium1Color.withOpacity(0.6),
                                  width: 1)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                  color: greyMedium1Color.withOpacity(0.6),
                                  width: 1)),
                        ),
                        onFieldSubmitted: (value) {
                          if (value.isNotEmpty) {
                            setState(() {
                              _languages.add(value);
                              languagesController.clear();
                            });
                          }
                        },
                      ),
                      // const SizedBox(height: 6),
                      // const Text(
                      //   "Email",
                      //   style: TextStyle(
                      //       fontWeight: FontWeight.w500, fontSize: 14),
                      // ),
                      // TextFormField(
                      //   controller: emailController,
                      //   // readOnly: true,
                      //   keyboardType: TextInputType.emailAddress,
                      //   decoration: InputDecoration(
                      //     isDense: true,
                      //     hintText: 'Email',
                      //     hintStyle: const TextStyle(),
                      //     filled: true,
                      //     fillColor: greyMedium1Color.withOpacity(0.3),
                      //     enabledBorder: OutlineInputBorder(
                      //         borderRadius: BorderRadius.circular(10),
                      //         borderSide: BorderSide(
                      //             color: greyMedium1Color.withOpacity(0.6),
                      //             width: 1)),
                      //     focusedBorder: OutlineInputBorder(
                      //         borderRadius: BorderRadius.circular(10),
                      //         borderSide: BorderSide(
                      //             color: greyMedium1Color.withOpacity(0.6),
                      //             width: 1)),
                      //   ),
                      //   validator: (value) {
                      //     if (value == null || value.isEmpty) {
                      //       return 'Please enter email';
                      //     }
                      //     if (!value.contains('@')) {
                      //       return 'Please enter a valid email';
                      //     }
                      //     return null;
                      //   },
                      // ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Gender",
                    style: GoogleFonts.roboto(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Expanded(
                        child: Obx(() {
                          return InkWell(
                            onTap: () {
                              profileController.gender.value = 0;
                              setState(() {
                                _gender = "male";
                              });
                            },
                            overlayColor:
                                MaterialStateProperty.all(Colors.transparent),
                            child: Row(
                              children: [
                                Container(
                                  height: 15,
                                  width: 15,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: appColorP),
                                  ),
                                  child: profileController.gender.value == 0
                                      ? Center(
                                          child: Container(
                                            height: 10,
                                            width: 10,
                                            decoration: BoxDecoration(
                                              color: appColorR,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        )
                                      : const SizedBox(),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  "Male",
                                  style: GoogleFonts.roboto(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              ],
                            ),
                          );
                        }),
                      ),
                      Expanded(
                        child: Obx(() {
                          return InkWell(
                            onTap: () {
                              profileController.gender.value = 1;
                              setState(() {
                                _gender = "female";
                              });
                            },
                            overlayColor:
                                MaterialStateProperty.all(Colors.transparent),
                            child: Row(
                              children: [
                                Container(
                                  height: 15,
                                  width: 15,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: appColorP),
                                  ),
                                  child: profileController.gender.value == 1
                                      ? Center(
                                          child: Container(
                                            height: 10,
                                            width: 10,
                                            decoration: BoxDecoration(
                                              color: appColorR,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        )
                                      : const SizedBox(),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  "Female",
                                  style: GoogleFonts.roboto(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              ],
                            ),
                          );
                        }),
                      ),
                      Expanded(
                        child: Obx(() {
                          return InkWell(
                            overlayColor:
                                MaterialStateProperty.all(Colors.transparent),
                            onTap: () {
                              profileController.gender.value = 2;
                              setState(() {
                                _gender = "other";
                              });
                            },
                            child: Row(
                              children: [
                                Container(
                                  height: 15,
                                  width: 15,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: appColorP),
                                  ),
                                  child: profileController.gender.value == 2
                                      ? Center(
                                          child: Container(
                                            height: 10,
                                            width: 10,
                                            decoration: BoxDecoration(
                                              color: appColorR,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        )
                                      : const SizedBox(),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  "Other",
                                  style: GoogleFonts.roboto(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              ],
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Intersted In",
                    style: GoogleFonts.roboto(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Expanded(
                        child: Obx(() {
                          return InkWell(
                            onTap: () {
                              profileController.intersted.value = 0;
                              setState(() {
                                _intersted = "male";
                              });
                            },
                            overlayColor:
                                MaterialStateProperty.all(Colors.transparent),
                            child: Row(
                              children: [
                                Container(
                                  height: 15,
                                  width: 15,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: appColorP),
                                  ),
                                  child: profileController.intersted.value == 0
                                      ? Center(
                                          child: Container(
                                            height: 10,
                                            width: 10,
                                            decoration: BoxDecoration(
                                              color: appColorR,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        )
                                      : const SizedBox(),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  "Male",
                                  style: GoogleFonts.roboto(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              ],
                            ),
                          );
                        }),
                      ),
                      Expanded(
                        child: Obx(() {
                          return InkWell(
                            onTap: () {
                              profileController.intersted.value = 1;
                              setState(() {
                                _intersted = "female";
                              });
                            },
                            overlayColor:
                                MaterialStateProperty.all(Colors.transparent),
                            child: Row(
                              children: [
                                Container(
                                  height: 15,
                                  width: 15,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: appColorP),
                                  ),
                                  child: profileController.intersted.value == 1
                                      ? Center(
                                          child: Container(
                                            height: 10,
                                            width: 10,
                                            decoration: BoxDecoration(
                                              color: appColorR,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        )
                                      : const SizedBox(),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  "Female",
                                  style: GoogleFonts.roboto(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              ],
                            ),
                          );
                        }),
                      ),
                      Expanded(
                        child: Obx(() {
                          return InkWell(
                            overlayColor:
                                MaterialStateProperty.all(Colors.transparent),
                            onTap: () {
                              profileController.intersted.value = 2;
                              setState(() {
                                _intersted = "other";
                              });
                            },
                            child: Row(
                              children: [
                                Container(
                                  height: 15,
                                  width: 15,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: appColorP),
                                  ),
                                  child: profileController.intersted.value == 2
                                      ? Center(
                                          child: Container(
                                            height: 10,
                                            width: 10,
                                            decoration: BoxDecoration(
                                              color: appColorR,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        )
                                      : const SizedBox(),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  "Other",
                                  style: GoogleFonts.roboto(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              ],
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      // case 1:
      //   return Card(
      //     color: white,
      //     surfaceTintColor: white,
      //     shape:
      //         RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      //     child: Padding(
      //       padding: const EdgeInsets.all(8.0),
      //       child: SingleChildScrollView(
      //         child: Column(
      //           crossAxisAlignment: CrossAxisAlignment.start,
      //           children: [
      //             const SizedBox(height: 6),
      //             const Text(
      //               "Bio",
      //               style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
      //             ),
      //             TextFormField(
      //               controller: bioController,
      //               maxLines: 3,
      //               maxLength: 200,
      //               decoration: InputDecoration(
      //                 isDense: true,
      //                 hintText: 'Bio',
      //                 hintStyle: const TextStyle(),
      //                 filled: true,
      //                 fillColor: greyMedium1Color.withOpacity(0.3),
      //                 enabledBorder: OutlineInputBorder(
      //                     borderRadius: BorderRadius.circular(10),
      //                     borderSide: BorderSide(
      //                         color: greyMedium1Color.withOpacity(0.6),
      //                         width: 1)),
      //                 focusedBorder: OutlineInputBorder(
      //                     borderRadius: BorderRadius.circular(10),
      //                     borderSide: BorderSide(
      //                         color: greyMedium1Color.withOpacity(0.6),
      //                         width: 1)),
      //               ),
      //               validator: (value) {
      //                 if (value == null || value.isEmpty) {
      //                   return 'Please enter Bio';
      //                 }
      //                 return null;
      //               },
      //             ),
      //             const SizedBox(height: 2),
      //             const Text(
      //               "Your Age",
      //               style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
      //             ),
      //             TextFormField(
      //               controller: dobController,
      //               // readOnly: true,
      //               keyboardType: TextInputType.number,
      //               decoration: InputDecoration(
      //                 isDense: true,
      //                 hintText: 'Age',
      //                 hintStyle: const TextStyle(),
      //                 // suffixIcon: const Icon(
      //                 //   Icons.arrow_drop_down,
      //                 //   size: 24,
      //                 // ),
      //                 filled: true,
      //                 fillColor: greyMedium1Color.withOpacity(0.3),
      //                 enabledBorder: OutlineInputBorder(
      //                     borderRadius: BorderRadius.circular(10),
      //                     borderSide: BorderSide(
      //                         color: greyMedium1Color.withOpacity(0.6),
      //                         width: 1)),
      //                 focusedBorder: OutlineInputBorder(
      //                     borderRadius: BorderRadius.circular(10),
      //                     borderSide: BorderSide(
      //                         color: greyMedium1Color.withOpacity(0.6),
      //                         width: 1)),
      //               ),
      //               validator: (value) {
      //                 if (value == null || value.isEmpty) {
      //                   return 'Please enter age';
      //                 }
      //                 if (int.tryParse(value) == null) {
      //                   return 'Please enter a valid number';
      //                 }
      //                 if (int.tryParse(dobController.text)! < 18 ||
      //                     int.tryParse(dobController.text)! > 99) {
      //                   return 'Age is Required Between 18 To 99';
      //                 }
      //                 return null;
      //               },
      //             ),
      //             const SizedBox(height: 6),
      //             Column(
      //               crossAxisAlignment: CrossAxisAlignment.start,
      //               children: [
      //                 const Text("Spoken Languages",
      //                     style: TextStyle(
      //                         fontWeight: FontWeight.w500, fontSize: 14)),
      //                 Wrap(
      //                   spacing: 8.0,
      //                   children: _languages
      //                       .map((lang) => Chip(
      //                             backgroundColor: white,
      //                             surfaceTintColor: white,
      //                             shape: RoundedRectangleBorder(
      //                                 borderRadius: BorderRadius.circular(4),
      //                                 side: BorderSide(
      //                                     color: greyMedium1Color, width: 1)),
      //                             label: Text(lang),
      //                             deleteIcon: const Icon(Icons.close, size: 18),
      //                             onDeleted: () =>
      //                                 setState(() => _languages.remove(lang)),
      //                           ))
      //                       .toList(),
      //                 ),
      //                 TextFormField(
      //                   controller: languagesController,
      //                   // readOnly: true,
      //                   decoration: InputDecoration(
      //                     isDense: true,
      //                     hintText: 'Add Language',
      //                     hintStyle: const TextStyle(),
      //                     filled: true,
      //                     suffixIcon: IconButton(
      //                       icon: const Icon(Icons.add),
      //                       onPressed: () async {
      //                         if (languagesController.text.isNotEmpty) {
      //                           setState(() {
      //                             _languages.add(languagesController.text);
      //                             languagesController.clear();
      //                           });
      //                         }
      //                       },
      //                     ),
      //                     fillColor: greyMedium1Color.withOpacity(0.3),
      //                     enabledBorder: OutlineInputBorder(
      //                         borderRadius: BorderRadius.circular(10),
      //                         borderSide: BorderSide(
      //                             color: greyMedium1Color.withOpacity(0.6),
      //                             width: 1)),
      //                     focusedBorder: OutlineInputBorder(
      //                         borderRadius: BorderRadius.circular(10),
      //                         borderSide: BorderSide(
      //                             color: greyMedium1Color.withOpacity(0.6),
      //                             width: 1)),
      //                   ),
      //                   onFieldSubmitted: (value) {
      //                     if (value.isNotEmpty) {
      //                       setState(() {
      //                         _languages.add(value);
      //                         languagesController.clear();
      //                       });
      //                     }
      //                   },
      //                 ),
      //                 const SizedBox(height: 6),
      //                 const Text(
      //                   "Email",
      //                   style: TextStyle(
      //                       fontWeight: FontWeight.w500, fontSize: 14),
      //                 ),
      //                 TextFormField(
      //                   controller: emailController,
      //                   // readOnly: true,
      //                   keyboardType: TextInputType.emailAddress,
      //                   decoration: InputDecoration(
      //                     isDense: true,
      //                     hintText: 'Email',
      //                     hintStyle: const TextStyle(),
      //                     filled: true,
      //                     fillColor: greyMedium1Color.withOpacity(0.3),
      //                     enabledBorder: OutlineInputBorder(
      //                         borderRadius: BorderRadius.circular(10),
      //                         borderSide: BorderSide(
      //                             color: greyMedium1Color.withOpacity(0.6),
      //                             width: 1)),
      //                     focusedBorder: OutlineInputBorder(
      //                         borderRadius: BorderRadius.circular(10),
      //                         borderSide: BorderSide(
      //                             color: greyMedium1Color.withOpacity(0.6),
      //                             width: 1)),
      //                   ),
      //                   validator: (value) {
      //                     if (value == null || value.isEmpty) {
      //                       return 'Please enter email';
      //                     }
      //                     if (!value.contains('@')) {
      //                       return 'Please enter a valid email';
      //                     }
      //                     return null;
      //                   },
      //                 ),
      //               ],
      //             ),
      //           ],
      //         ),
      //       ),
      //     ),
      //   );
      // case 2:
      //   return Card(
      //     color: white,
      //     surfaceTintColor: white,
      //     shape:
      //         RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      //     child: Padding(
      //       padding: const EdgeInsets.all(8.0),
      //       child: SingleChildScrollView(
      //         child: Column(
      //           crossAxisAlignment: CrossAxisAlignment.start,
      //           children: [
      //             const SizedBox(height: 6),
      //             const Text(
      //               "Address",
      //               style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
      //             ),
      //             TextFormField(
      //               controller: addressController,
      //               decoration: InputDecoration(
      //                 isDense: true,
      //                 hintText: 'Your Address',
      //                 hintStyle: const TextStyle(),
      //                 filled: true,
      //                 fillColor: greyMedium1Color.withOpacity(0.3),
      //                 enabledBorder: OutlineInputBorder(
      //                     borderRadius: BorderRadius.circular(10),
      //                     borderSide: BorderSide(
      //                         color: greyMedium1Color.withOpacity(0.6),
      //                         width: 1)),
      //                 focusedBorder: OutlineInputBorder(
      //                     borderRadius: BorderRadius.circular(10),
      //                     borderSide: BorderSide(
      //                         color: greyMedium1Color.withOpacity(0.6),
      //                         width: 1)),
      //               ),
      //               validator: (value) {
      //                 if (value == null || value.isEmpty) {
      //                   return 'Please enter Address';
      //                 }
      //                 return null;
      //               },
      //             ),
      //             const SizedBox(height: 6),
      //             const Text(
      //               "Voice Introducing",
      //               style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
      //             ),
      //             TextFormField(
      //               controller: voiceController,
      //               readOnly: true,
      //               // enabled: false,
      //               decoration: InputDecoration(
      //                 isDense: true,
      //                 hintText: recordedVoicePath != null
      //                     ? 'Recorded'
      //                     : 'Record your voice',
      //                 hintStyle: const TextStyle(),
      //                 suffixIcon: GestureDetector(
      //                   onTap: () {
      //                     // _showVoiceRecordingPopup(context);
      //                   },
      //                   child: const Icon(
      //                     Icons.mic,
      //                     size: 24,
      //                   ),
      //                 ),
      //                 filled: true,
      //                 fillColor: greyMedium1Color.withOpacity(0.3),
      //                 enabledBorder: OutlineInputBorder(
      //                     borderRadius: BorderRadius.circular(10),
      //                     borderSide: BorderSide(
      //                         color: greyMedium1Color.withOpacity(0.6),
      //                         width: 1)),
      //                 focusedBorder: OutlineInputBorder(
      //                     borderRadius: BorderRadius.circular(10),
      //                     borderSide: BorderSide(
      //                         color: greyMedium1Color.withOpacity(0.6),
      //                         width: 1)),
      //               ),
      //               validator: (value) {
      //                 if (recordedVoicePath == null) {
      //                   return 'Please record your voice';
      //                 }
      //                 return null;
      //               },
      //             ),
      //             const SizedBox(height: 6),
      //             const Text(
      //               "Query/Expertise",
      //               style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
      //             ),
      //             Wrap(
      //               spacing: 8.0,
      //               children: _expertise
      //                   .map((expertise) => Chip(
      //                         backgroundColor: white,
      //                         surfaceTintColor: white,
      //                         shape: RoundedRectangleBorder(
      //                             borderRadius: BorderRadius.circular(4),
      //                             side: BorderSide(
      //                                 color: greyMedium1Color, width: 1)),
      //                         label: Text(expertise),
      //                         deleteIcon: const Icon(Icons.close, size: 18),
      //                         onDeleted: () =>
      //                             setState(() => _expertise.remove(expertise)),
      //                       ))
      //                   .toList(),
      //             ),
      //             TextFormField(
      //               controller: expertController,
      //               // readOnly: true,
      //               decoration: InputDecoration(
      //                 isDense: true,
      //                 hintText: 'Expertise ',
      //                 hintStyle: const TextStyle(),
      //                 filled: true,
      //                 fillColor: greyMedium1Color.withOpacity(0.3),
      //                 suffixIcon: IconButton(
      //                   icon: const Icon(Icons.add),
      //                   onPressed: () {
      //                     if (expertController.text.isNotEmpty) {
      //                       if (_expertise.length < 4) {
      //                         setState(() {
      //                           _expertise.add(expertController.text);
      //                           expertController.clear();
      //                         });
      //                       } else {
      //                         Get.snackbar("Alert",
      //                             "Expertise/Query is Not more then 4.",
      //                             snackPosition: SnackPosition.TOP);
      //                       }
      //                     }
      //                   },
      //                 ),
      //                 enabledBorder: OutlineInputBorder(
      //                     borderRadius: BorderRadius.circular(10),
      //                     borderSide: BorderSide(
      //                         color: greyMedium1Color.withOpacity(0.6),
      //                         width: 1)),
      //                 focusedBorder: OutlineInputBorder(
      //                     borderRadius: BorderRadius.circular(10),
      //                     borderSide: BorderSide(
      //                         color: greyMedium1Color.withOpacity(0.6),
      //                         width: 1)),
      //               ),
      //               onFieldSubmitted: (value) {
      //                 if (value.isNotEmpty) {
      //                   if (_expertise.length < 4) {
      //                     setState(() {
      //                       _expertise.add(value);
      //                       expertController.clear();
      //                     });
      //                   } else {
      //                     Get.snackbar(
      //                         "Alert", "Expertise/Query is Not more then 4.",
      //                         snackPosition: SnackPosition.TOP);
      //                   }
      //                 }
      //               },
      //             ),
      //           ],
      //         ),
      //       ),
      //     ),
      //   );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget sliderContainerDot(int index) {
    return Container(
      width: 24, //_currentIndex == index ? 24.0 : 4,
      height: 4.0,
      decoration: ShapeDecoration(
        color: index <= _currentIndex ? appColorR : grey.withOpacity(0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0),
        ),
      ),
    );
  }
}
