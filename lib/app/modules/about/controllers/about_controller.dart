import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AboutController extends GetxController {
  String appName = "", packageName = "", version = "", buildNumber = "";

  _versionParser() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    appName = packageInfo.appName;
    packageName = packageInfo.packageName;
    version = packageInfo.version;
    buildNumber = packageInfo.buildNumber;
  }

  List credits = [];

  @override
  void onInit() async {
    super.onInit();
    _versionParser();
    credits = [
      [
        "DEVELOPER INFO",
        [
          "GitHub: @denver-code",
        ],
      ],
      [
        "STACK INFO",
        [
          "Language: Dart&Flutter",
          "Libs: GetX, BarcodeScan2, Share, UUID, FAB, PKI+, Crypto, HTTP, FilePicker"
        ],
      ],
      [
        "APPLICATION INFO",
        [
          "Name: $appName",
          "Version: v$version",
          "Package name: $packageName",
          "Build number: v$buildNumber",
          "Github: denver-code/stuff_accounting"
        ]
      ],
      [
        "NEWS & DONATION LINKS",
        [
          "Telegram: @coming_soon",
          "Patreon: @coming_soon",
          "PayPal: @coming_soon"
        ]
      ]
    ];
  }
}
