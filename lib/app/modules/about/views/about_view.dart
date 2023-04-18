import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:stuff_accounting_app/app/internal/hex2color.dart';

import '../controllers/about_controller.dart';

class AboutView extends GetView<AboutController> {
  const AboutView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    AboutController controller = Get.put(AboutController());
    return Scaffold(
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.all(35),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 20,
            ),
            Expanded(
                child: Center(
              child: Column(
                children: [
                  const Text(
                    "CREDITS",
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 35,
                    ),
                  ),
                  Expanded(
                      child: SingleChildScrollView(
                    child: Column(
                      children:
                          List.generate(controller.credits.length, (index) {
                        return Column(
                          children: [
                            Text(
                              controller.credits[index][0],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: HexColor.fromHex("#9C9C9C"),
                                fontWeight: FontWeight.w800,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Column(
                              children: List.generate(
                                  controller.credits[index][1].length,
                                  (indexText) {
                                return Column(
                                  children: [
                                    Text(
                                      controller.credits[index][1][indexText],
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w300,
                                        fontSize: 20,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 7,
                                    )
                                  ],
                                );
                              }),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                          ],
                        );
                      }),
                    ),
                  ))
                ],
              ),
            )),
            const Center(
              child: Text(
                "Made in UK🇬🇧 from Ukraine🇺🇦",
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
          ],
        ),
      )),
    );
  }
}
