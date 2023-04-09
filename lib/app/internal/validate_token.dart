import 'package:http/http.dart' as http;

import 'package:stuff_accounting_app/config.dart';

Future<bool> validateToken(token) async {
  if (token == null) {
    return false;
  }
  final response = await http.get(
    Uri.parse('$SERVER_URI/public/tools/verify/'),
    headers: <String, String>{
      'Authorisation': token,
    },
  );

  return true ? response.statusCode == 200 : false;
}
