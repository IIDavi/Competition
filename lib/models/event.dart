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
}
