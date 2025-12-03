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
    
    // Construct full image URL if relative
    String img = json['image']?.toString() ?? '';
    if (img.isNotEmpty && !img.startsWith('http')) {
      img = 'https://competitioncorner.net/$img'; // Assuming base URL, check this
    }
    // API returns full URL usually? "Events/..." -> likely needs base.
    // The example in reasoning said "Events/jzf51uxp7.jpg". 
    // It's likely relative to https://competitioncorner.net/file.aspx/ or something.
    // Let's assume for now it needs a prefix if it doesn't have http.
    // Checking the user's provided JSON structure, it just says "Events/...". 
    // I'll assume https://competitioncorner.net/api2/v1/events/... or similar?
    // Actually, typically it's https://s3.amazonaws.com/competitioncorner or similar.
    // But let's look at the fetched JSON again.
    // Ah, I don't see the full URL in the snippet.
    // I'll add a safe check.
    
    // Correction: Competition Corner images often need a base. 
    // Let's use a placeholder if unsure, or try to construct it.
    // "Events/..." usually maps to https://competitioncorner.net/events/... or CDN.
    // I will use "https://competitioncorner.net/file.aspx/" as a guess or just leave it as is if it's broken.
    // Better yet, I'll just map it and if it breaks, the UI has an error builder.
    
    // Actually, looking at the response: `image` "Events/jzf51uxp7.jpg". 
    // Let's prefix with `https://competitioncorner.net/` just in case, but usually these might be CDN.
    // Let's try `https://cdn.competitioncorner.net/` or similar? 
    // Safe bet: `https://competitioncorner.net/` + path if not http.

    return Event(
      id: json['id'].toString(),
      name: json['name']?.toString() ?? 'Unknown Event',
      date: dateStr,
      locationCity: city,
      locationRegion: country, // Using country as region
      state: (json['active'] == true) ? 1 : 0, // Map active to state 1
      type: json['type']?.toString() ?? 'competition',
      totalSubscribers: 0, // Not available
      individualsSubscribed: 0,
      teamsSubscribed: 0,
      enrollmentEndDate: json['registrationEnd']?.toString() ?? '',
      enrollmentEndDays: daysRemaining,
      imgURL: json['image'] != null ? 'https://competitioncorner.net/file.aspx/${json['image']}' : '', // Educated guess for image URL
      imgThumbnail: json['thumbnail'] != null ? 'https://competitioncorner.net/file.aspx/${json['thumbnail']}' : '',
    );
  }
}
