class Event {
  final String id;
  final String name;
  final String date;
  final String? locationCity;
  final String? locationRegion;
  final int state;
  final String type;
  final int totalSubscribers;
  final int individualsSubscribed;
  final int teamsSubscribed;
  final String enrollmentEndDate;
  final int enrollmentEndDays;
  final String imgURL;
  final String imgThumbnail;
  final String source;

  Event({
    required this.id,
    required this.name,
    required this.date,
    this.locationCity,
    this.locationRegion,
    required this.state,
    required this.type,
    required this.totalSubscribers,
    required this.individualsSubscribed,
    required this.teamsSubscribed,
    required this.enrollmentEndDate,
    required this.enrollmentEndDays,
    required this.imgURL,
    required this.imgThumbnail,
    this.source = 'judgerules',
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    String? city;
    String? region;
    
    // Handle location safely (it might be null, a Map, or even an empty List in some PHP APIs)
    final loc = json['location'];
    if (loc is Map) {
      city = loc['city']?.toString();
      region = loc['region']?.toString();
    }

    return Event(
      id: json['id'].toString(),
      name: json['name']?.toString() ?? 'Unknown Event',
      date: json['date']?.toString() ?? '',
      locationCity: city,
      locationRegion: region,
      state: int.tryParse(json['state'].toString()) ?? 0,
      type: json['type']?.toString() ?? '',
      totalSubscribers: int.tryParse(json['totalSubscribers'].toString()) ?? 0,
      individualsSubscribed: int.tryParse(json['individualsSubscribed'].toString()) ?? 0,
      teamsSubscribed: int.tryParse(json['teamsSubscribed'].toString()) ?? 0,
      enrollmentEndDate: json['enrollmentEndDate']?.toString() ?? '',
      enrollmentEndDays: int.tryParse(json['enrollmentEndDays'].toString()) ?? 0,
      imgURL: json['imgURL']?.toString() ?? '',
      imgThumbnail: json['imgThumbnail']?.toString() ?? '',
      source: 'judgerules',
    );
  }

  factory Event.fromCompetitionCornerJson(Map<String, dynamic> json) {
    String? city;
    String? country;
    
    final loc = json['eventLocation'];
    if (loc is Map) {
      city = loc['city']?.toString();
      country = loc['country']?.toString();
    }

    // Parse dates
    String dateStr = '';
    if (json['startDateTime'] != null) {
       try {
         final start = DateTime.parse(json['startDateTime']);
         final end = json['endDateTime'] != null ? DateTime.parse(json['endDateTime']) : null;
         // Simple formatting: "YYYY-MM-DD"
         dateStr = "${start.toLocal()}".split(' ')[0]; 
         if (end != null && end.day != start.day) {
            dateStr += " / ${"${end.toLocal()}".split(' ')[0]}";
         }
       } catch (e) {
         dateStr = json['startDateTime'].toString();
       }
    }

    // Calculate days remaining
    int daysRemaining = 0;
    if (json['registrationEnd'] != null) {
      try {
        final end = DateTime.parse(json['registrationEnd']);
        final now = DateTime.now();
        daysRemaining = end.difference(now).inDays;
        if (daysRemaining < 0) daysRemaining = 0;
      } catch (_) {}
    }
    
    // Construct full image URL
    // The API returns a relative path like "Events/..." which needs to be served via the file handler
    String _buildCcUrl(String? path) {
      if (path == null || path.isEmpty) return '';
      if (path.startsWith('http')) return path;
      return 'https://competitioncorner.net/file.aspx/mainFilesystem?$path';
    }

    return Event(
      id: json['id'].toString(),
      name: json['name']?.toString() ?? 'Unknown Event',
      date: dateStr,
      locationCity: city,
      locationRegion: country, 
      state: (json['active'] == true) ? 1 : 0, 
      type: json['type']?.toString() ?? 'competition',
      totalSubscribers: 0,
      individualsSubscribed: 0,
      teamsSubscribed: 0,
      enrollmentEndDate: json['registrationEnd']?.toString() ?? '',
      enrollmentEndDays: daysRemaining,
      imgURL: _buildCcUrl(json['image']?.toString()),
      imgThumbnail: _buildCcUrl(json['thumbnail']?.toString()),
      source: 'competitioncorner',
    );
  }
}
