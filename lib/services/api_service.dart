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
        'User-Agent': 'JudgeRulesApp/1.0',
        'Accept': 'application/json',
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
