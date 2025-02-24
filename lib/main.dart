import 'package:flutter/material.dart';
import 'package:gad_fly/screens/auth/main_login.dart';
import 'package:get/get.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GadFly',
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const MainLogInScreen(),
    );
  }
}
