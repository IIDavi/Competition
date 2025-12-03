import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/event.dart';
import '../models/timeline_item.dart';
import 'mock_data.dart';

class ApiService {
  static const String _baseUrl = 'https://api.judgerules.it/api';

  Future<List<Event>> fetchEvents() async {
    // Using the parameters requested: limit=20, skip=0, list=1
    final uri = Uri.parse('$_baseUrl/events?limit=20&skip=0&list=1');
    try {
      print('Attempting to fetch events from API...');
      final response = await http.get(uri, headers: {
        'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64; rv:140.0) Gecko/20100101 Firefox/140.0',
        'Accept': '*/*',
        'Accept-Language': 'en_GB',
        'Referer': 'https://app.judgerules.it/',
        'Content-Type': 'application/json; charset=UTF-8',
        'Origin': 'https://app.judgerules.it',
        'Sec-Fetch-Dest': 'empty',
        'Sec-Fetch-Mode': 'cors',
        'Sec-Fetch-Site': 'same-site',
        'Connection': 'keep-alive',
        'Priority': 'u=0',
        'TE': 'trailers',
      }).timeout(const Duration(seconds: 5)); // Short timeout to fallback quickly

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print('Fetched ${data.length} raw events from API');
        
        final List<Event> events = data.map((e) {
          try {
            return Event.fromJson(e);
          } catch (err) {
            print('Error parsing event ${e['id']}: $err');
            return null;
          }
        }).whereType<Event>().toList();
        
        if (events.isNotEmpty) {
          return events;
        }
      }
      // If status is not 200 or list is empty, fall through to mock
      print('API returned status ${response.statusCode} or empty list. Switching to mock data.');
    } catch (e) {
      print('Error fetching events from API ($e). Switching to mock data.');
    }

    // Fallback to Mock Data provided by user
    print('Loading ${mockEvents.length} events from Mock Data');
    return mockEvents.map((e) => Event.fromJson(e)).toList();
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
