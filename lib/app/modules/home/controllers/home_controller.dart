import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:path_provider/path_provider.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:stuff_accounting_app/app/internal/hex2color.dart';

import 'package:stuff_accounting_app/app/internal/models/item.dart';
import 'package:stuff_accounting_app/app/routes/app_pages.dart';
import 'package:uuid/uuid.dart';
import 'package:share/share.dart';

class HomeController extends GetxController {
  // Variables
  GetStorage storage = GetStorage();
  final searchController = TextEditingController();
  List<Item> staticItemList = <Item>[].obs;
  RxList<Item> itemList = RxList<Item>();
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  RxString scannedCode = RxString('');

  bool isUpcExist(List<Item> items, targetUpc) {
    for (var item in items) {
      if (item.upc == targetUpc) {
        return true;
      }
    }
    return false;
  }

  String generateID() {
    final uuid = Uuid();

    String newId;
    bool isUniqueId;

    do {
      newId = uuid.v4();
      isUniqueId = staticItemList.every((item) => item.id != newId);
    } while (!isUniqueId);

    return newId;
  }

  Future getItem(String ucp) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Accept-Encoding': 'gzip,deflate',
    };

    final response = await http.get(
        Uri.parse('https://api.upcitemdb.com/prod/trial/lookup?upc=$ucp'),
        headers: headers);
    final data = jsonDecode(response.body);
    if (data['items'].isEmpty) {
      return false;
    }
    data['items'][0].remove('offers');

    return data['items'][0];
  }

  //  Items operation

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

  deleteItem(String itemId) async {
    loadItems();
    itemList.removeWhere((item) => item.id == itemId);
    saveItems(itemList);
    loadItems();

    if (searchController.text != "") {
      searchItems(searchQuery: searchController.text);
    }
    return Get.snackbar("SAA", "Item deleted successfully!",
        icon: const Icon(Icons.delete_sweep_rounded, color: Colors.white),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.grey,
        duration: const Duration(milliseconds: 1000));
  }

  loadJson() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null) {
      final file = File(result.files.single.path!);
      final contents = await file.readAsString();
      final data = json.decode(contents) as List;
      List itemsJson = [];
      for (var item in data) {
        if (!isUpcExist(staticItemList, item["upc"]) || item["upc"] == "") {
          item["id"] = generateID();
          if (!item.containsKey("tag") || item["tag"] == "") {
            item["tag"] = "Others";
          }
          itemsJson.add(item);
        }
      }

      List items = itemsJson.map((json) => Item.fromJson(json)).toList();
      for (var item in items) {
        itemList.add(item);
      }
      saveItems(itemList);
      loadItems();
      Get.snackbar(
        "SAA",
        "All items imported successfully!",
        icon: const Icon(Icons.close_fullscreen_outlined, color: Colors.white),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.grey,
      );
    }
  }

  void clearItems() {
    itemList.clear();
    saveItems(itemList);
    loadItems();
  }

  exportJson() async {
    if (staticItemList.isEmpty) {
      return Get.snackbar(
        "SAA",
        "You don't have any items to export.",
        icon: const Icon(Icons.error_outline_rounded, color: Colors.red),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.grey,
      );
    }
    // Convert staticItemList to JSON string
    String jsonString = jsonEncode(staticItemList);

    // Create export file in app's document directory
    Directory path = (await getApplicationDocumentsDirectory());

    File exportFile = File('${path.path}/export.json');

    // Write JSON string to export file
    await exportFile.writeAsString(jsonString);

    // Share export file with user
    await Share.shareFiles([exportFile.path], text: 'Here are my items!');
  }
  // Search

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
    itemList.assignAll(filteredItems);
  }

  void clearSearch() {
    searchController.clear();
    loadItems();
  }

  // General

  @override
  void onInit() async {
    super.onInit();
    loadItems();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  // Widgets

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
              onPressed: () {
                // Map payload = {"title": title, "description": description};
                Item item = Item.fromJson({
                  'title': title,
                  'description': description,
                  'picture': "",
                  'upc': "No UCP",
                  'owner': "Admin",
                  'tag': "Others",
                  'id': generateID(),
                });
                itemList.add(item);
                saveItems(itemList);
                loadItems();
                Get.snackbar(
                  "SAA",
                  "Item created!",
                  icon: const Icon(Icons.close_fullscreen_outlined,
                      color: Colors.white),
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.grey,
                );
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void showDeletionDialog(BuildContext context) async {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text("DELETE ALL ITEMS?",
              style: TextStyle(color: Colors.red)),
          content: Column(
            children: const [
              Text("ARE YOU SURE THAT YOU WANT DELETE ALL YOUR STUFF?"),
              Text("YOU WILL NOT BE ABLE TO UNDO OR CANCEL THAT PROCESS"),
            ],
          ),
          actions: [
            CupertinoDialogAction(
              child: const Text(
                'DELETE',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                clearItems();
                Navigator.pop(context);
                Get.snackbar(
                  "SAA",
                  "All items has been deleted!",
                  icon: const Icon(Icons.delete_forever_rounded,
                      color: Colors.white),
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.grey,
                );
                scaffoldKey.currentState?.closeDrawer();
              },
            ),
            CupertinoDialogAction(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.pop(context);
                Get.snackbar(
                  "SAA",
                  "We glad that you change your mind!",
                  icon: const Icon(Icons.accessibility_new_sharp,
                      color: Colors.white),
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.grey,
                );
                scaffoldKey.currentState?.closeDrawer();
              },
            ),
          ],
        );
      },
    );
  }

  Widget feedContent() {
    if (itemList.isEmpty) {
      return Expanded(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              SizedBox(
                height: 50,
              ),
              Text('List of items is empty :[', style: TextStyle(fontSize: 17)),
              SizedBox(
                height: 10,
              ),
              Divider(),
              Text('Some useful tips:', style: TextStyle(fontSize: 14)),
              Divider(),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  'Boost your experience by adding items to your collection! Simply tap on the Plus sign or scan a QR code using the button located in the bottom right corner of the screen.',
                  style: TextStyle(fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ),
              Divider(),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  'Once you will add some items - you will be able to see them instead this text, also you can use Search box to find something specific!',
                  style: TextStyle(fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ),
              Divider(),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  'If you sure that here should be your stuff - try refresh the feed using Refresh button on top-right corner of the screen.',
                  style: TextStyle(fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ),
              Divider(),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  'You can import or export items using SAA Fast Panel, just tap on menu icon in top-left corner of the screen',
                  style: TextStyle(fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ),
              Divider(),
            ],
          ),
        ),
      );
    } else {
      return Expanded(
        child: Obx(
          () => ListView(
            children: itemList.map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Dismissible(
                    key: Key(item.id), // Use a unique key for each item
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: Colors.red,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: const [
                            Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                            Text(
                              "Delete",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ],
                        ),
                      ),
                    ),
                    onDismissed: (direction) {
                      deleteItem(item.id);
                    },
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                      ),
                      child: ListTile(
                        title: Text(item.title),
                        subtitle: Text(
                          item.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Container(
                          decoration: BoxDecoration(
                              color: HexColor.fromHex("#262626"),
                              borderRadius: BorderRadius.circular(100)),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              item.tag,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        onTap: () {
                          Get.toNamed(
                            Routes.DETAIL,
                            arguments: item,
                          );
                        },
                      ),
                    )),
              );
            }).toList(),
          ),
        ),
      );
    }
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

      final product = await getItem(scannedCode.value);

      if (product == false) {
        return Get.snackbar(
          "SAA",
          "Looks like Item are not exist in OpenUPC Database, but you can add item manually using Plus button",
          icon: const Icon(Icons.error_outline_rounded, color: Colors.white),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.grey,
        );
      } else {
        // print('Product details: $product');

        String picture = "";
        if (product["images"].isNotEmpty) {
          picture = product["images"][0];
        }

        Item item = Item.fromJson({
          "id": generateID(),
          "title": product["title"],
          "description": product["description"],
          "picture": picture,
          "owner": "Item",
          'tag': "Others",
          "upc": scannedCode.value
        });

        itemList.add(item);
        saveItems(itemList);
        loadItems();

        return Get.snackbar(
          "SAA",
          "We added ${item.title} to your collection!",
          icon:
              const Icon(Icons.my_library_books_outlined, color: Colors.white),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.grey,
        );
      }
    } on Exception {
      return;
    }
  }
}
