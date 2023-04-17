import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'package:stuff_accounting_app/app/internal/hex2color.dart';
import 'package:stuff_accounting_app/app/routes/app_pages.dart';

import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('My Collection'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              controller.loadItems();
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            SizedBox(
              height: Get.height / 18,
            ),
            const Center(
              child: Text(
                "SAA Fast Panel",
                style: TextStyle(fontSize: 18),
              ),
            ),
            ListTile(
              title: const Text('Import'),
            ),
            ListTile(
              title: const Text('Export'),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Obx(() => controller.feedContent()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: Get.width / 1.7,
                    height: Get.height / 15.5,
                    decoration: const BoxDecoration(
                      color: Color.fromRGBO(255, 255, 255, 1),
                      borderRadius: BorderRadius.all(Radius.circular(9)),
                      boxShadow: [
                        BoxShadow(
                            color: Color.fromRGBO(0, 0, 0, 0.15000000596046448),
                            offset: Offset(0, 4),
                            blurRadius: 8)
                      ],
                    ),
                    child: TextField(
                        onChanged: ((value) {
                          controller.searchItems(searchQuery: value);
                        }),
                        controller: controller.searchController,
                        decoration: InputDecoration(
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              controller.searchController.clear();
                              controller.searchItems(searchQuery: "");
                            },
                          ),
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
                          labelText: "Search",
                          hintText: "The Last Of Us 2",
                        )),
                  ),
                  FloatingActionButton(
                    heroTag: 'upc_adder',
                    onPressed: controller.scanBarcode,
                    child: const Icon(Icons.qr_code_rounded),
                  ),
                  FloatingActionButton(
                    onPressed: () => controller.showAddItemDialog(context),
                    child: const Icon(Icons.add),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
