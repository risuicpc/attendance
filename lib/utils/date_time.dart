import 'dart:convert';

import 'package:http/http.dart' as http;

Future<DateTime> get currentLocalTime async {
  try {
    final response = await http.get(
        Uri.parse('http://worldtimeapi.org/api/timezone/Africa/Addis_Ababa'));

    if (response.statusCode == 200) {
      return DateTime.parse(jsonDecode(response.body)["datetime"]).toLocal();
    } else {
      throw Exception('Failed to load current time');
    }
  } catch (_) {
    throw Exception('Failed to load current time');
  }
}
