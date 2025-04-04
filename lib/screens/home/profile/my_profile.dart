import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gad_fly/constant/color_code.dart';
import 'package:gad_fly/controller/profile_controller.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  final ProfileController _updateProfileController = Get.find();
  File? _selectedImage;
  bool isLoading = false;
  final List<String> _languages = [];
  String _gender = 'male';
  String _intersted = 'female';

  initFunction() async {}

  @override
  void initState() {
    initFunction();
    super.initState();
    _updateProfileController.getProfile().then((profileData) {
      if (profileData != null) {
        final data = profileData["data"];
        _updateProfileController.amount.value =
            double.parse("${data["walletAmount"]}");
        if (mounted) {
          setState(() {
            _updateProfileController.aNameController.text =
                data["avatarName"] ?? "";
            _updateProfileController.oNameController.text = data["name"] ?? "";
            _updateProfileController.phoneController.text = data["phone"] ?? "";
            if (data["languages"].length != 0) {
              // _updateProfileController.languagesController.text =
              //     data["languages"][0] ?? "";

              //_languages = data["languages"];
              _languages.addAll(data["languages"].cast<String>());
            }
            //  _updateProfileController.email.text = data["email"] ?? "";
            final gender = data["gender"] ?? "";
            _updateProfileController.gender.value = (gender == "male")
                ? 0
                : (gender == "female")
                    ? 1
                    : 2;
            _gender = (gender == "male")
                ? "male"
                : (gender == "female")
                    ? "female"
                    : "other";
            final intersted = data["intersted"] ?? "";
            _updateProfileController.intersted.value = (intersted == "male")
                ? 0
                : (intersted == "female")
                    ? 1
                    : 2;
            _intersted = (gender == "male")
                ? "male"
                : (gender == "female")
                    ? "female"
                    : "other";
          });
        }
      } else {
        Get.snackbar("Error", "Something went wrong ...Profile not found. ");
      }
    }).catchError((error) {
      Get.snackbar("Error", "An error occurred while fetching profile data.");
    });
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
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
    // var appYellow = const Color(0xFFFFE30F);
    // var appGreenColor = const Color(0xFF35D673);
    var greyMedium1Color = const Color(0xFFDBDBDB);
    return Scaffold(
      backgroundColor: whiteColor,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: SizedBox(
          height: height,
          width: width,
          child: Column(
            children: [
              SizedBox(
                height: AppBar().preferredSize.height,
                width: width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const SizedBox(width: 16),
                        InkWell(
                          onTap: () {
                            Get.back();
                          },
                          child: Icon(
                            Icons.arrow_back_ios_new_sharp,
                            size: 18,
                            color: blackColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          "Profile",
                          style: GoogleFonts.roboto(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                            color: blackColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                  child: Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Obx(() {
                          //   return Center(
                          //     child: CircleAvatar(
                          //         radius: 32,
                          //         backgroundColor: Colors.grey[400],
                          //         child: _selectedImage != null
                          //             ? Container(
                          //                 height: 58,
                          //                 width: 58,
                          //                 decoration: BoxDecoration(
                          //                   borderRadius:
                          //                       BorderRadius.circular(30),
                          //                   image: DecorationImage(
                          //                       image:
                          //                           FileImage(_selectedImage!),
                          //                       fit: BoxFit.cover),
                          //                 ),
                          //               )
                          //             : _updateProfileController.imgUrl.value !=
                          //                     ""
                          //                 ? Container(
                          //                     height: 58,
                          //                     width: 58,
                          //                     decoration: BoxDecoration(
                          //                       borderRadius:
                          //                           BorderRadius.circular(30),
                          //                       image: DecorationImage(
                          //                           image: NetworkImage(
                          //                               _updateProfileController
                          //                                   .imgUrl.value),
                          //                           fit: BoxFit.cover),
                          //                     ),
                          //                   )
                          //                 : CircleAvatar(
                          //                     radius: 30,
                          //                     backgroundColor: appColor,
                          //                   )),
                          //   );
                          // }),
                          // const SizedBox(
                          //   height: 6,
                          // ),
                          // Center(
                          //   child: InkWell(
                          //     onTap: () async {
                          //       await _pickImage();
                          //     },
                          //     child: Text(
                          //       "Edit Picture",
                          //       style: GoogleFonts.roboto(
                          //         fontWeight: FontWeight.w500,
                          //         fontSize: 15,
                          //         color: appColor,
                          //       ),
                          //     ),
                          //   ),
                          // ),
                          const SizedBox(height: 6),
                          SizedBox(
                            height: 50,
                            child: TextFormField(
                              controller:
                                  _updateProfileController.oNameController,
                              cursorColor: blackColor,
                              style: TextStyle(color: blackColor),
                              decoration: InputDecoration(
                                labelText: "Original Name",
                                labelStyle:
                                    GoogleFonts.roboto(color: blackColor),
                                floatingLabelStyle:
                                    GoogleFonts.roboto(color: blackColor),
                                enabledBorder: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.grey.shade300),
                                    borderRadius: BorderRadius.circular(5)),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: blackColor),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 50,
                            child: TextFormField(
                              controller:
                                  _updateProfileController.aNameController,
                              cursorColor: blackColor,
                              style: TextStyle(color: blackColor),
                              decoration: InputDecoration(
                                labelText: "Display Name",
                                labelStyle:
                                    GoogleFonts.roboto(color: blackColor),
                                floatingLabelStyle:
                                    GoogleFonts.roboto(color: blackColor),
                                enabledBorder: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.grey.shade300),
                                    borderRadius: BorderRadius.circular(5)),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: blackColor),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 50,
                            child: TextFormField(
                              controller:
                                  _updateProfileController.phoneController,
                              readOnly: true,
                              cursorColor: blackColor,
                              style: TextStyle(color: blackColor),
                              decoration: InputDecoration(
                                labelText: "Phone No.",
                                labelStyle:
                                    GoogleFonts.roboto(color: blackColor),
                                floatingLabelStyle:
                                    GoogleFonts.roboto(color: blackColor),
                                enabledBorder: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.grey.shade300),
                                    borderRadius: BorderRadius.circular(5)),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: blackColor),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Spoken Languages",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14)),
                              Wrap(
                                spacing: 8.0,
                                children: _languages
                                    .map((lang) => Chip(
                                          backgroundColor: white,
                                          surfaceTintColor: white,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                              side: BorderSide(
                                                  color: greyMedium1Color,
                                                  width: 1)),
                                          label: Text(lang),
                                          deleteIcon:
                                              const Icon(Icons.close, size: 18),
                                          onDeleted: () => setState(
                                              () => _languages.remove(lang)),
                                        ))
                                    .toList(),
                              ),
                              TextFormField(
                                controller: _updateProfileController
                                    .languagesController,
                                // readOnly: true,
                                decoration: InputDecoration(
                                  isDense: true,
                                  hintText: 'Add Language',
                                  hintStyle: const TextStyle(),
                                  filled: true,
                                  suffixIcon: IconButton(
                                    icon: const Icon(Icons.add),
                                    onPressed: () async {
                                      if (_updateProfileController
                                          .languagesController
                                          .text
                                          .isNotEmpty) {
                                        setState(() {
                                          _languages.add(
                                              _updateProfileController
                                                  .languagesController.text);
                                          _updateProfileController
                                              .languagesController
                                              .clear();
                                        });
                                      }
                                    },
                                  ),
                                  fillColor: greyMedium1Color.withOpacity(0.3),
                                  enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                          color:
                                              greyMedium1Color.withOpacity(0.6),
                                          width: 1)),
                                  focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                          color:
                                              greyMedium1Color.withOpacity(0.6),
                                          width: 1)),
                                ),
                                onFieldSubmitted: (value) {
                                  if (value.isNotEmpty) {
                                    setState(() {
                                      _languages.add(value);
                                      _updateProfileController
                                          .languagesController
                                          .clear();
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
                          // SizedBox(
                          //   height: 50,
                          //   child: TextFormField(
                          //     controller:
                          //         _updateProfileController.languagesController,
                          //     cursorColor: blackColor,
                          //     style: TextStyle(color: blackColor),
                          //     decoration: InputDecoration(
                          //       labelText: "Preferred Language",
                          //       labelStyle:
                          //           GoogleFonts.roboto(color: blackColor),
                          //       floatingLabelStyle:
                          //           GoogleFonts.roboto(color: blackColor),
                          //       enabledBorder: OutlineInputBorder(
                          //           borderSide:
                          //               BorderSide(color: Colors.grey.shade300),
                          //           borderRadius: BorderRadius.circular(5)),
                          //       focusedBorder: OutlineInputBorder(
                          //         borderSide: BorderSide(color: blackColor),
                          //       ),
                          //     ),
                          //   ),
                          // ),
                          // const SizedBox(height: 12),
                          // SizedBox(
                          //   height: 50,
                          //   child: TextFormField(
                          //     controller:
                          //         _updateProfileController.languagesController1,
                          //     cursorColor: blackColor,
                          //     style: TextStyle(color: blackColor),
                          //     decoration: InputDecoration(
                          //       labelText: "Additional Language",
                          //       labelStyle:
                          //           GoogleFonts.roboto(color: blackColor),
                          //       floatingLabelStyle:
                          //           GoogleFonts.roboto(color: blackColor),
                          //       enabledBorder: OutlineInputBorder(
                          //           borderSide:
                          //               BorderSide(color: Colors.grey.shade300),
                          //           borderRadius: BorderRadius.circular(5)),
                          //       focusedBorder: OutlineInputBorder(
                          //         borderSide: BorderSide(color: blackColor),
                          //       ),
                          //     ),
                          //   ),
                          // ),
                          const SizedBox(height: 12),
                          Text(
                            "Gender",
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
                                      _updateProfileController.gender.value = 0;
                                      setState(() {
                                        _gender = "male";
                                      });
                                    },
                                    overlayColor: MaterialStateProperty.all(
                                        Colors.transparent),
                                    child: Row(
                                      children: [
                                        Container(
                                          height: 15,
                                          width: 15,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(color: appColor),
                                          ),
                                          child: _updateProfileController
                                                      .gender.value ==
                                                  0
                                              ? Center(
                                                  child: Container(
                                                    height: 10,
                                                    width: 10,
                                                    decoration: BoxDecoration(
                                                      color: appColor,
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
                                      _updateProfileController.gender.value = 1;
                                      setState(() {
                                        _gender = "female";
                                      });
                                    },
                                    overlayColor: MaterialStateProperty.all(
                                        Colors.transparent),
                                    child: Row(
                                      children: [
                                        Container(
                                          height: 15,
                                          width: 15,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(color: appColor),
                                          ),
                                          child: _updateProfileController
                                                      .gender.value ==
                                                  1
                                              ? Center(
                                                  child: Container(
                                                    height: 10,
                                                    width: 10,
                                                    decoration: BoxDecoration(
                                                      color: appColor,
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
                                    overlayColor: MaterialStateProperty.all(
                                        Colors.transparent),
                                    onTap: () {
                                      _updateProfileController.gender.value = 2;
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
                                            border: Border.all(color: appColor),
                                          ),
                                          child: _updateProfileController
                                                      .gender.value ==
                                                  2
                                              ? Center(
                                                  child: Container(
                                                    height: 10,
                                                    width: 10,
                                                    decoration: BoxDecoration(
                                                      color: appColor,
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
                                      _updateProfileController.intersted.value =
                                          0;
                                      setState(() {
                                        _intersted = "male";
                                      });
                                    },
                                    overlayColor: MaterialStateProperty.all(
                                        Colors.transparent),
                                    child: Row(
                                      children: [
                                        Container(
                                          height: 15,
                                          width: 15,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(color: appColor),
                                          ),
                                          child: _updateProfileController
                                                      .intersted.value ==
                                                  0
                                              ? Center(
                                                  child: Container(
                                                    height: 10,
                                                    width: 10,
                                                    decoration: BoxDecoration(
                                                      color: appColor,
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
                                      _updateProfileController.intersted.value =
                                          1;
                                      setState(() {
                                        _intersted = "female";
                                      });
                                    },
                                    overlayColor: MaterialStateProperty.all(
                                        Colors.transparent),
                                    child: Row(
                                      children: [
                                        Container(
                                          height: 15,
                                          width: 15,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(color: appColor),
                                          ),
                                          child: _updateProfileController
                                                      .intersted.value ==
                                                  1
                                              ? Center(
                                                  child: Container(
                                                    height: 10,
                                                    width: 10,
                                                    decoration: BoxDecoration(
                                                      color: appColor,
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
                                    overlayColor: MaterialStateProperty.all(
                                        Colors.transparent),
                                    onTap: () {
                                      _updateProfileController.intersted.value =
                                          2;
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
                                            border: Border.all(color: appColor),
                                          ),
                                          child: _updateProfileController
                                                      .intersted.value ==
                                                  2
                                              ? Center(
                                                  child: Container(
                                                    height: 10,
                                                    width: 10,
                                                    decoration: BoxDecoration(
                                                      color: appColor,
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
                          const Spacer(),
                          GestureDetector(
                            onTap: () async {
                              setState(() {
                                isLoading = true;
                              });
                              final profileData = {
                                "name": _updateProfileController
                                    .oNameController.text,
                                "avatarName": _updateProfileController
                                    .aNameController.text,
                                "gender": _gender,
                                "intersted": _intersted,
                                "languages": _languages,
                                //"email": emailController.text,
                              };
                              await _updateProfileController
                                  .profileUpdate(profileData)
                                  .then((onValue) {
                                if (onValue == true) {
                                  Get.snackbar(
                                      "wow", "Profile updated successfully",
                                      snackPosition: SnackPosition.TOP,
                                      backgroundColor: Colors.grey.shade300);
                                  _updateProfileController.languagesController1
                                      .clear();
                                } else {
                                  Get.snackbar(
                                      "Alert", "Profile updated Failed",
                                      snackPosition: SnackPosition.TOP,
                                      backgroundColor: Colors.grey.shade300);
                                }
                              });
                              setState(() {
                                isLoading = false;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 9, horizontal: 12),
                              margin: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 6),
                              width: width * 0.88,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: greyMedium1Color,
                              ),
                              child: Center(
                                child: Text("Update & Save",
                                    style: TextStyle(
                                        color: blackColor,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500)),
                              ),
                            ),
                          ),
                        ]),
                  ),
                  if (isLoading)
                    Positioned(
                      top: 0,
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Center(
                          child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(blackColor),
                      )),
                    )
                ],
              ))
            ],
          ),
        ),
      ),
    );
  }
}
