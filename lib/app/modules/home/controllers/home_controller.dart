import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

import 'package:stuff_accounting_app/app/internal/models/item.dart';
import 'package:stuff_accounting_app/app/routes/app_pages.dart';
import 'package:stuff_accounting_app/config.dart';

class HomeController extends GetxController {
  GetStorage storage = GetStorage();
  final searchController = TextEditingController();
  List<Item> staticItemList = <Item>[];
  RxList<Item> itemList = RxList<Item>();

  RxString scannedCode = RxString('');

  bool isUpcExist(List<Item> items, String targetUpc) {
    for (var item in items) {
      if (item.upc == targetUpc) {
        return true;
      }
    }
    return false;
  }

  scanBarcode() async {
    try {
      final result = await BarcodeScanner.scan();
      scannedCode.value = result.rawContent;
      if (scannedCode.value.isEmpty) {
        return Get.snackbar(
          "SAA",
          "Looks like your UPC Barcode are wrong ;[",
          icon: const Icon(Icons.error_outline_rounded, color: Colors.white),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.grey,
        );
      }
      if (isUpcExist(staticItemList, scannedCode.value)) {
        return Get.snackbar(
          "SAA",
          "Looks like this item already in your list!",
          icon:
              const Icon(Icons.my_library_books_outlined, color: Colors.white),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.grey,
        );
      }
      final response = await http.get(
          Uri.parse(
            'https://api.upcitemdb.com/prod/trial/lookup?upc=${scannedCode.value}',
          ),
          headers: <String, String>{
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Accept-Encoding': 'gzip,deflate',
          });

      if (response.statusCode == 200) {
        Item item = Item.fromJson(json.decode(response.body));
        refreshAll();
        return Get.snackbar(
          "SAA",
          "We added ${item.title} to your collection!",
          icon:
              const Icon(Icons.my_library_books_outlined, color: Colors.white),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.grey,
        );
      } else {
        return Get.snackbar(
          "SAA",
          "Looks like Item are not exist or we don't have it in our DataBase, you also can try look up by search!",
          icon: const Icon(Icons.error_outline_rounded, color: Colors.white),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.grey,
        );
      }
    } on Exception {
      return;
    }
  }

  logout() async {
    storage.remove("token");
    Get.offAndToNamed(Routes.AUTHORISATION);
  }

  Future<List<Item>> fetchItems() async {
    final response = await http.get(
        Uri.parse(
          '$SERVER_URI/private/items/my/',
        ),
        headers: <String, String>{
          'Authorisation': storage.read("token"),
        });

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => Item.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch items');
    }
  }

  void saveItems(List<Item> items) {
    final itemListJson = items.map((item) => item.toJson()).toList();
    storage.write('items', itemListJson);
  }

  void loadItems() {
    final box = GetStorage();
    final itemListJson = box.read<List<dynamic>>('items');
    if (itemListJson != null) {
      final items = itemListJson.map((json) => Item.fromJson(json)).toList();
      itemList.assignAll(items);
      staticItemList.assignAll(items);
    }
  }

  void searchItems({searchQuery}) {
    final query = searchQuery.toLowerCase();
    if (query == "") {
      return loadItems();
    }
    final filteredItems = staticItemList.where((item) {
      final titleLower = item.title.toLowerCase();
      final descriptionLower = item.description.toLowerCase();
      return titleLower.contains(query) || descriptionLower.contains(query);
    }).toList();

    if (filteredItems.isEmpty) {
      filteredItems.add(Item.fromJson({
        'title': "Looks like there are no items that meet your querry",
        'description': "",
        'picture': "picture",
        'upc': "upc",
        'owner': "owner",
        'tag': "tag",
        'id': "id",
      }));
    }
    itemList.assignAll(filteredItems);
  }

  deleteItem(String itemId) async {
    final response = await http.delete(
        Uri.parse(
          '$SERVER_URI/private/items/$itemId',
        ),
        headers: <String, String>{
          'Authorisation': storage.read("token"),
        });
    if (response.statusCode == 200) {
      refreshAll();
      return Get.snackbar("SAA", "Item deleted successfully!",
          icon: const Icon(Icons.delete_sweep_rounded, color: Colors.white),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.grey,
          duration: const Duration(seconds: 1));
    } else {
      return Get.snackbar(
        "SAA",
        "Looks like something went wrong..",
        icon: const Icon(Icons.error_outline_rounded, color: Colors.white),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.grey,
      );
    }
  }

  void showAddItemDialog(BuildContext context) async {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        String title = '';
        String description = '';
        return CupertinoAlertDialog(
          title: const Text('Create Item'),
          content: Column(
            children: [
              const SizedBox(height: 10),
              CupertinoTextField(
                placeholder: 'Title',
                onChanged: (value) => title = value,
              ),
              const SizedBox(height: 10),
              CupertinoTextField(
                placeholder: 'Description',
                onChanged: (value) => description = value,
              ),
            ],
          ),
          actions: [
            CupertinoDialogAction(
              child: const Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
            CupertinoDialogAction(
              child: const Text('Create'),
              onPressed: () async {
                Map payload = {"title": title, "description": description};
                final response = await http.post(
                  Uri.parse('$SERVER_URI/private/items/new'),
                  headers: <String, String>{
                    'Content-Type': 'application/json; charset=UTF-8',
                    "Authorisation": storage.read("token")
                  },
                  body: jsonEncode(payload),
                );
                if (response.statusCode == 200) {
                  refreshAll();
                  Get.snackbar(
                    "SAA",
                    "Item created!",
                    icon: const Icon(Icons.close_fullscreen_outlined,
                        color: Colors.white),
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.grey,
                  );
                } else {
                  Get.snackbar(
                    "SAA",
                    "Looks like some of your data are completely wrong or you don't have access to creation:[",
                    icon: const Icon(Icons.error_outline_outlined,
                        color: Colors.white),
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.grey,
                  );
                }

                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void refreshAll() async {
    final items = await fetchItems();

    saveItems(items);
    loadItems();
  }

  void clearSearch() {
    searchController.clear();
    loadItems();
  }

  @override
  void onInit() async {
    super.onInit();
    refreshAll();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
