import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import 'package:stuff_accounting_app/app/internal/models/item.dart';

import '../controllers/detail_controller.dart';

class DetailView extends GetView<DetailController> {
  const DetailView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final Item item = Get.arguments;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Detail of Item"),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  FutureBuilder(
                    future: http.get(Uri.parse(item.picture)),
                    builder: (context, snapshot) {
                      if (snapshot.hasData &&
                          (snapshot.data as http.Response).statusCode == 200) {
                        return Column(
                          children: [
                            const SizedBox(
                              height: 20,
                            ),
                            Image.network(
                              item.picture,
                              scale: 2.5,
                            ),
                            SizedBox(
                              height: Get.height / 45,
                            ),
                          ],
                        );
                      } else {
                        return Column(
                          children: [
                            SizedBox(
                              height: Get.height / 13,
                            ),
                            const Text(
                              "No picture",
                              style: TextStyle(fontSize: 17),
                            ),
                            SizedBox(
                              height: Get.height / 13,
                            ),
                          ],
                        );
                      }
                    },
                  ),
                  Text(
                    item.title,
                    style: const TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Text(
                    "Description: ${item.description}",
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 15),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Text("Tag: ${item.tag}"),
                  const SizedBox(
                    height: 15,
                  ),
                  Text("UPC: ${item.upc}"),
                  Text("ID: ${item.id}"),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
