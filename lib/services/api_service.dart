import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/event.dart';
import '../models/timeline_item.dart';

class ApiService {
  static const String _baseUrl = 'https://api.judgerules.it/api';

  Future<List<Event>> fetchEvents() async {
    // Using the parameters requested: limit=20, skip=0, list=1
    final uri = Uri.parse('$_baseUrl/events?limit=20&skip=0&list=1');
    try {
      final response = await http.get(uri, headers: {
        'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64; rv:140.0) Gecko/20100101 Firefox/140.0',
        'Accept': '*/*',
        'Accept-Language': 'en_GB',
        // 'Accept-Encoding': 'gzip, deflate, br, zstd', // Dart http client handles encoding automatically
        'Referer': 'https://app.judgerules.it/',
        'Content-Type': 'application/json; charset=UTF-8',
        'Origin': 'https://app.judgerules.it',
        'Sec-Fetch-Dest': 'empty',
        'Sec-Fetch-Mode': 'cors',
        'Sec-Fetch-Site': 'same-site',
        'Connection': 'keep-alive',
        'Priority': 'u=0',
        'TE': 'trailers',
      });

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((e) {
          try {
            return Event.fromJson(e);
          } catch (err) {
            print('Error parsing event: $err');
            return null;
          }
        }).whereType<Event>().toList();
      } else {
        throw Exception('Failed to load events: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching events: $e');
    }
  }

  Future<List<TimelineItem>> fetchTimeline(String eventId) async {
    final uri = Uri.parse('$_baseUrl/events/$eventId/timeline');
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((e) => TimelineItem.fromJson(e)).toList();
      } else {
        // Sometimes 404 or empty list means not available
        return [];
      }
    } catch (e) {
      // Treat errors as empty timeline
      return [];
    }
  }
}
