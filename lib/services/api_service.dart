import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/event.dart';
import '../models/timeline_item.dart';

class ApiService {
  static const String _baseUrl = 'https://api.judgerules.it/api';
  static const String _ccUrl = 'https://competitioncorner.net/api2/v1/events/filtered?timing=active&timestamp=1764794437313&page=1&perPage=1000';
  static const String _circle21Url = 'https://api.circle21.events/api/competition?page=1&per_page=100&public=1&published=1';

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

    // 3. Fetch from Circle21
    try {
      final uri = Uri.parse(_circle21Url);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        if (jsonResponse.containsKey('data') && jsonResponse['data'] is List) {
           final List<dynamic> data = jsonResponse['data'];
           allEvents.addAll(data.map((e) {
             try {
               return Event.fromCircle21Json(e);
             } catch (err) {
               print('Error parsing Circle21 event: $err');
               return null;
             }
           }).whereType<Event>());
        }
      }
    } catch (e) {
      print('Error fetching Circle21 events: $e');
    }

    if (allEvents.isEmpty) {
      // Only throw if ALL failed to return any events
      throw Exception('Failed to load events from any source.');
    }
    
    return allEvents;
  }

  Future<List<TimelineItem>> fetchTimeline(Event event) async {
    if (event.source == 'competitioncorner') {
      return _fetchCompetitionCornerTimeline(event.id);
    } else if (event.source == 'circle21') {
      return []; 
    } else {
      return _fetchJudgeRulesTimeline(event.id);
    }
  }

  Future<List<TimelineItem>> _fetchJudgeRulesTimeline(String eventId) async {
    final uri = Uri.parse('$_baseUrl/events/$eventId/timeline');
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((e) => TimelineItem.fromJson(e)).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  Future<List<TimelineItem>> _fetchCompetitionCornerTimeline(String eventId) async {
    List<TimelineItem> timeline = [];
    try {
      // 1. Fetch Workouts
      final workoutsUri = Uri.parse('https://competitioncorner.net/api2/v1/schedule/events/$eventId/workouts');
      final workoutsResponse = await http.get(workoutsUri);
      
      if (workoutsResponse.statusCode != 200) return [];
      
      final workoutsData = json.decode(workoutsResponse.body);
      final List<dynamic> workouts = workoutsData['workouts'] ?? [];
      
      // 2. Fetch Heats for each Workout
      for (var w in workouts) {
        final int workoutId = w['id'];
        final String workoutName = w['name'] ?? 'Unknown Workout';
        final String workoutDateStr = w['date'] ?? '';
        
        // Format date to DD-MM-YYYY if possible to match TimelineItem expectation
        String formattedDate = workoutDateStr;
        try {
           final d = DateTime.parse(workoutDateStr);
           formattedDate = "${d.day.toString().padLeft(2, '0')}-${d.month.toString().padLeft(2, '0')}-${d.year}";
        } catch (_) {}

        final heatsUri = Uri.parse('https://competitioncorner.net/api2/v1/schedule/workout/$workoutId?divisionId=all');
        final heatsResponse = await http.get(heatsUri);
        
        if (heatsResponse.statusCode == 200) {
           final List<dynamic> heats = json.decode(heatsResponse.body);
           
           for (var h in heats) {
             final String heatTitle = h['title'] ?? 'Heat';
             final String heatTime = h['time'] ?? '';
             final String warmupTime = h['warmupTime'] ?? '';
             
             final List<dynamic> stations = h['stations'] ?? [];
             for (var s in stations) {
               // Parse teammates
               List<String> participants = [];
               final String teammatesStr = s['teammates'] ?? '';
               if (teammatesStr.isNotEmpty) {
                 // Remove "(C)" leader marker and split
                 participants = teammatesStr
                     .replaceAll('(C) ', '')
                     .split(',')
                     .map((e) => e.trim())
                     .where((e) => e.isNotEmpty)
                     .toList();
               }

               timeline.add(TimelineItem(
                 teamId: s['participantId']?.toString() ?? '',
                 teamName: s['participantName'] ?? 'Unknown Team',
                 workoutName: workoutName,
                 heat: heatTitle,
                 lane: s['station']?.toString() ?? '',
                 warmupTime: warmupTime,
                 startingTime: heatTime,
                 category: s['division'] ?? '',
                 date: formattedDate,
                 participants: participants,
               ));
             }
           }
        }
      }
      
      // Sort by date and time is implicitly handled if the list order is preserved or we can sort it.
      // Usually API returns in order, but TimelineScreen logic handles simple grouping.
      
    } catch (e) {
      print('Error fetching CC timeline: $e');
    }
    return timeline;
  }
}
