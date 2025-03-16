import 'package:cight/features/authentication/screens/login/login.dart';
import 'package:cight/utils/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: TAppTheme.lightTheme,
      // home: const Scaffold(
      //   backgroundColor: Colors.blue,
      //   body: Center(child: CircularProgressIndicator(color: Colors.white)),
      // ),
      home: LoginScreen(),
    );
  }
}
