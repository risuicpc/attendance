import 'dart:convert';

import 'package:http/http.dart' as http;

const String uri = 'http://worldtimeapi.org/api/timezone/Africa/Addis_Ababa';

Future<DateTime> get currentLocalTime async {
  try {
    final response = await http.get(Uri.parse(uri));
    return DateTime.parse(jsonDecode(response.body)["datetime"]).toLocal();
  } catch (_) {
    return DateTime.now();
  }
}
