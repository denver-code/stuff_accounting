import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'package:stuff_accounting_app/app/internal/hex2color.dart';

import '../../../routes/app_pages.dart';
import '../controllers/authorisation_controller.dart';

class RegistrationView extends GetView<AuthorisationController> {
  const RegistrationView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    AuthorisationController controller = Get.put(AuthorisationController());
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: Get.height / 14,
          shadowColor: Colors.transparent,
          shape: const Border(
              bottom: BorderSide(
                  color: Color.fromRGBO(221, 221, 221, 1), width: 1)),
          backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
          title: const Text("SAA Registrate",
              style: TextStyle(fontSize: 15, color: Colors.black)),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: Get.height / 5,
                  ),
                  const Text(
                    "Registration",
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(
                    height: Get.height / 18,
                  ),
                  Container(
                    width: Get.width / 1.2,
                    height: Get.height / 15.5,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(9)),
                      boxShadow: [
                        BoxShadow(
                            color: Color.fromRGBO(0, 0, 0, 0.15000000596046448),
                            offset: Offset(0, 4),
                            blurRadius: 8)
                      ],
                      color: Color.fromRGBO(255, 255, 255, 1),
                    ),
                    child: TextFormField(
                        controller: controller.emailTextController,
                        cursorColor: Colors.black,
                        style: TextStyle(
                            color: HexColor.fromHex("#343237"), fontSize: 14),
                        decoration: InputDecoration(
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                          disabledBorder: const OutlineInputBorder(
                              borderSide: BorderSide(
                            color: Colors.transparent,
                          )),
                          enabledBorder: const OutlineInputBorder(
                              borderSide: BorderSide(
                            color: Colors.transparent,
                          )),
                          border: const OutlineInputBorder(
                              borderSide: BorderSide(
                            color: Colors.transparent,
                          )),
                          focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(
                            color: Colors.transparent,
                          )),
                          labelStyle: TextStyle(
                              color: HexColor.fromHex("#343237"),
                              fontSize: 14,
                              fontWeight: FontWeight.w400),
                          hintStyle: TextStyle(
                              color: HexColor.fromHex("#828282"),
                              fontSize: 14,
                              fontWeight: FontWeight.w400),
                          filled: false,
                          fillColor: Colors.transparent,
                          labelText: "Tell us your email",
                          hintText: "rickydickydoodahgrimes@example.com",
                        )),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                    width: Get.width / 1.2,
                    height: Get.height / 15.5,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(9)),
                      boxShadow: [
                        BoxShadow(
                            color: Color.fromRGBO(0, 0, 0, 0.15000000596046448),
                            offset: Offset(0, 4),
                            blurRadius: 8)
                      ],
                      color: Color.fromRGBO(255, 255, 255, 1),
                    ),
                    child: TextFormField(
                        controller: controller.passwordTextController,
                        cursorColor: Colors.black,
                        obscureText: true,
                        style: TextStyle(
                            color: HexColor.fromHex("#343237"), fontSize: 14),
                        decoration: InputDecoration(
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                          disabledBorder: const OutlineInputBorder(
                              borderSide: BorderSide(
                            color: Colors.transparent,
                          )),
                          enabledBorder: const OutlineInputBorder(
                              borderSide: BorderSide(
                            color: Colors.transparent,
                          )),
                          border: const OutlineInputBorder(
                              borderSide: BorderSide(
                            color: Colors.transparent,
                          )),
                          focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(
                            color: Colors.transparent,
                          )),
                          labelStyle: TextStyle(
                              color: HexColor.fromHex("#343237"),
                              fontSize: 14,
                              fontWeight: FontWeight.w400),
                          hintStyle: TextStyle(
                              color: HexColor.fromHex("#828282"),
                              fontSize: 14,
                              fontWeight: FontWeight.w400),
                          filled: false,
                          fillColor: Colors.transparent,
                          labelText: "Tell us your password",
                          hintText: "*your super secret password*",
                        )),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  GestureDetector(
                    onTap: () {
                      controller.processAuthorisation(isReg: true);
                    },
                    child: Container(
                      width: Get.width / 1.2,
                      height: Get.height / 15.5,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(9)),
                        color: HexColor.fromHex("#008CFF"),
                      ),
                      child: const Text("Sign up",
                          style: TextStyle(color: Colors.white, fontSize: 13)),
                    ),
                  ),
                  SizedBox(
                    height: Get.height / 30,
                  ),
                  GestureDetector(
                    onTap: () {
                      Get.toNamed(Routes.AUTHORISATION);
                    },
                    child: Container(
                      width: Get.width / 1.2,
                      height: Get.height / 15.5,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(9)),
                        color: Colors.transparent,
                      ),
                      child: const Text("Already have have account? Use One!",
                          style: TextStyle(color: Colors.black, fontSize: 13)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
