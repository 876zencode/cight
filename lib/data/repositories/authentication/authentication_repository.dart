import 'package:cight/features/authentication/screens/login/login.dart';
import 'package:get/get.dart';

class AuthenticationRepository extends GetxController {
  static AuthenticationRepository get instance => Get.find();

  /// Called from main.dart on app launch
  @override
  void onReady() {
    screenRedirect();
  }

  /// Function to Show Relevant Screen
  screenRedirect() async {
    Get.offAll(() => const LoginScreen());
  }
}
