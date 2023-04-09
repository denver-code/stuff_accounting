import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:crypto/crypto.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

import 'package:stuff_accounting_app/app/internal/validate_token.dart';
import 'package:stuff_accounting_app/app/routes/app_pages.dart';

import 'package:stuff_accounting_app/config.dart'; // for the utf8.encode method

// then hash the string

class AuthorisationController extends GetxController {
  TextEditingController emailTextController = TextEditingController();
  TextEditingController passwordTextController = TextEditingController();
  GetStorage storage = GetStorage();

  bool visible = false;

  processAuthorisation({isReg = false}) async {
    String email = emailTextController.text;
    String password = passwordTextController.text;
    if (!GetUtils.isEmail(email)) {
      return Get.snackbar(
        "SAA",
        "Looks like your email are completely wrong :[",
        icon: const Icon(Icons.error_outline_outlined, color: Colors.white),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.grey,
      );
    }
    var bytes = utf8.encode(password);
    var dig = sha256.convert(bytes);
    Map payload = {"email": email, "password": dig.toString()};

    Get.snackbar(
      "SAA", // Title of snackbar
      "Please wait while we process your application",
      duration: const Duration(seconds: 1),
      icon: const Icon(Icons.watch_later_outlined, color: Colors.white),
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.grey,
    );

    String route = "signin";
    if (isReg) {
      route = "signup";
    }

    final response = await http.post(
      Uri.parse('$SERVER_URI/public/authorisation/$route/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(payload),
    );
    if (response.statusCode == 200) {
      String token = jsonDecode(response.body)["token"];
      storage.write("token", token);
      Get.offAndToNamed(Routes.HOME);
    } else if (response.statusCode == 409) {
      Get.snackbar(
        "SAA",
        "Looks like user with this email already exist :[",
        icon: const Icon(Icons.error_outline_outlined, color: Colors.white),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.grey,
      );
    } else {
      Get.snackbar(
        "SAA",
        "Looks like some of your data are completely wrong :[",
        icon: const Icon(Icons.error_outline_outlined, color: Colors.white),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.grey,
      );
    }
  }

  @override
  void onInit() async {
    super.onInit(); //storage.read("token") &&
    if (await validateToken(storage.read("token"))) {
      Get.offAndToNamed(Routes.HOME);
    }
  }
}
