import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:get/get.dart';

import 'package:stuff_accounting_app/app/internal/hex2color.dart';

import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HexColor.fromHex("#f5f5f5"),
      key: controller.scaffoldKey,
      resizeToAvoidBottomInset: true,
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
              title: const Text('Import Json'),
              onTap: () => controller.loadJson(),
            ),
            ListTile(
              title: const Text('Export Json'),
              onTap: () => controller.exportJson(),
            ),
            ListTile(
              title: const Text(
                'Clear Collection',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () => controller.showDeletionDialog(context),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    iconSize: 35,
                    color: HexColor.fromHex("#262626"),
                    icon: const Icon(Icons.menu_open_rounded),
                    onPressed: () {
                      controller.scaffoldKey.currentState?.openDrawer();
                    },
                  ),
                  IconButton(
                    iconSize: 35,
                    color: HexColor.fromHex("#262626"),
                    icon: const Icon(Icons.refresh_rounded),
                    onPressed: () {
                      controller.loadItems();
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20.0, bottom: 15, top: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Welcome, mate!",
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: HexColor.fromHex("#262626")),
                  ),
                  Text(
                    "Here's your collection:",
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: HexColor.fromHex("#262626")),
                  ),
                ],
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 15),
              child: Container(
                width: Get.width,
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
                      hintText: "Death Stranding",
                    )),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: Container(
                decoration: BoxDecoration(color: HexColor.fromHex("#262626")),
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Obx(() => Text(
                      "Total amount of items in your collection: ${controller.staticItemList.length}",
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12))),
                ),
              ),
            ),
            Obx(() => controller.feedContent()),
          ],
        ),
      ),
      floatingActionButtonLocation: ExpandableFab.location,
      floatingActionButton: ExpandableFab(
        type: ExpandableFabType.up,
        distance: 70,
        closeButtonStyle: ExpandableFabCloseButtonStyle(
            backgroundColor: HexColor.fromHex("#3d3d3d")),
        backgroundColor: HexColor.fromHex("#3d3d3d"),
        children: [
          FloatingActionButton(
            onPressed: () => controller.showAddItemDialog(context),
            backgroundColor: HexColor.fromHex("#3d3d3d"),
            child: const Icon(Icons.add),
          ),
          // const SizedBox(
          //   height: 15,
          // ),
          FloatingActionButton(
            heroTag: 'upc_adder',
            backgroundColor: HexColor.fromHex("3d3d3d"),
            onPressed: controller.scanBarcode,
            child: const Icon(Icons.qr_code_rounded),
          ),
        ],
      ),
      // floatingActionButton: Column(
      //     crossAxisAlignment: CrossAxisAlignment.end,
      //     mainAxisAlignment: MainAxisAlignment.end,
      //     children: [

      //     ]),
    );
  }
}
