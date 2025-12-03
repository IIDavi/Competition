import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/event.dart';
import '../models/timeline_item.dart';
import '../services/api_service.dart';

class AppProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<Event> _events = [];
  bool _isLoadingEvents = false;
  String? _errorMessage;
  
  Event? _selectedEvent;
  List<TimelineItem> _timeline = [];
  bool _isLoadingTimeline = false;
  
  // Set of team IDs user wants to track
  Set<String> _followedTeamIds = {};
  
  // Getters
  List<Event> get events => _events;
  bool get isLoadingEvents => _isLoadingEvents;
  String? get errorMessage => _errorMessage;
  Event? get selectedEvent => _selectedEvent;
  List<TimelineItem> get timeline => _timeline;
  bool get isLoadingTimeline => _isLoadingTimeline;
  Set<String> get followedTeamIds => _followedTeamIds;

  // Derived: Get filtered timeline for followed teams
  List<TimelineItem> get mySchedule {
    if (_followedTeamIds.isEmpty) return [];
    return _timeline.where((item) => _followedTeamIds.contains(item.teamId)).toList();
  }

  // Derived: Get all unique teams in the current timeline
  List<Map<String, String>> get availableTeams {
    final Map<String, String> teams = {};
    for (var item in _timeline) {
      if (item.teamId.isNotEmpty && item.teamName.isNotEmpty) {
        teams[item.teamId] = item.teamName;
      }
    }
    return teams.entries.map((e) => {'id': e.key, 'name': e.value}).toList();
  }

  AppProvider() {
    print('AppProvider initialized (Safe Mode)');
    _loadPreferences();
    fetchEvents();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? savedTeams = prefs.getStringList('followedTeams');
    if (savedTeams != null) {
      _followedTeamIds = savedTeams.toSet();
      notifyListeners();
    }
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('followedTeams', _followedTeamIds.toList());
  }

  Future<void> fetchEvents() async {
    _isLoadingEvents = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _events = await _apiService.fetchEvents();
    } catch (e) {
      print('Error fetching events: $e');
      _errorMessage = e.toString();
      _events = [];
    } finally {
      _isLoadingEvents = false;
      notifyListeners();
    }
  }

  Future<void> selectEvent(Event event) async {
    _selectedEvent = event;
    _timeline = []; // Clear previous
    await fetchTimeline(event.id);
  }

  Future<void> fetchTimeline(String eventId) async {
    _isLoadingTimeline = true;
    notifyListeners();
    try {
      _timeline = await _apiService.fetchTimeline(eventId);
    } catch (e) {
      _timeline = [];
    } finally {
      _isLoadingTimeline = false;
      notifyListeners();
    }
  }

  Future<void> loadDemoEvent() async {
    // Manually load South Throwdown (ID 1022) as requested
    final demoEvent = Event(
      id: '1022',
      name: 'South Throwdown',
      date: 'December 06/07 2025',
      locationCity: 'Napoli',
      locationRegion: 'Campania',
      state: 50,
      type: 'team',
      totalSubscribers: 0,
      individualsSubscribed: 0,
      teamsSubscribed: 0,
      enrollmentEndDate: '',
      enrollmentEndDays: 0,
      imgURL: '',
      imgThumbnail: '',
    );
    await selectEvent(demoEvent);
  }

  void toggleTeamFollow(String teamId) {
    if (_followedTeamIds.contains(teamId)) {
      _followedTeamIds.remove(teamId);
    } else {
      _followedTeamIds.add(teamId);
    }
    _savePreferences();
    notifyListeners();
  }
  
  bool isFollowing(String teamId) => _followedTeamIds.contains(teamId);
}
