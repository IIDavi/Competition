import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/event.dart';
import '../models/timeline_item.dart';

class ApiService {
  static const String _baseUrl = 'https://api.judgerules.it/api';
  static const String _ccUrl = 'https://competitioncorner.net/api2/v1/events/filtered?timing=active&timestamp=1764794437313&page=1&perPage=1000';

  Future<List<Event>> fetchEvents() async {
    List<Event> allEvents = [];
    
    // 1. Fetch from JudgeRules
    try {
      final uri = Uri.parse('$_baseUrl/events?limit=20&skip=0&list=1');
      final response = await http.get(uri, headers: {
        'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64; rv:140.0) Gecko/20100101 Firefox/140.0',
        'Accept': '*/*',
        'Accept-Language': 'en_GB',
        'Referer': 'https://app.judgerules.it/',
        'Content-Type': 'application/json; charset=UTF-8',
        'Origin': 'https://app.judgerules.it',
        'Connection': 'keep-alive',
      });

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        allEvents.addAll(data.map((e) {
          try {
            return Event.fromJson(e);
          } catch (err) {
            print('Error parsing JR event: $err');
            return null;
          }
        }).whereType<Event>());
      }
    } catch (e) {
      print('Error fetching JR events: $e');
      // Continue to try other sources
    }

    // 2. Fetch from Competition Corner
    try {
      final uri = Uri.parse(_ccUrl);
      final response = await http.get(uri); // Usually public API doesn't need complex headers

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        allEvents.addAll(data.map((e) {
          try {
            return Event.fromCompetitionCornerJson(e);
          } catch (err) {
            print('Error parsing CC event: $err');
            return null;
          }
        }).whereType<Event>());
      }
    } catch (e) {
      print('Error fetching CC events: $e');
    }

    if (allEvents.isEmpty) {
      // Only throw if BOTH failed to return any events
      throw Exception('Failed to load events from any source.');
    }
    
    return allEvents;
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
