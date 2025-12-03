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
    return Event(
      id: json['id'].toString(),
      name: json['name'] ?? 'Unknown Event',
      date: json['date'] ?? '',
      locationCity: json['location']?['city'],
      locationRegion: json['location']?['region'],
      state: json['state'] is int ? json['state'] : int.tryParse(json['state'].toString()) ?? 0,
      type: json['type'] ?? '',
      totalSubscribers: json['totalSubscribers'] is int ? json['totalSubscribers'] : int.tryParse(json['totalSubscribers'].toString()) ?? 0,
      individualsSubscribed: json['individualsSubscribed'] is int ? json['individualsSubscribed'] : int.tryParse(json['individualsSubscribed'].toString()) ?? 0,
      teamsSubscribed: json['teamsSubscribed'] is int ? json['teamsSubscribed'] : int.tryParse(json['teamsSubscribed'].toString()) ?? 0,
      enrollmentEndDate: json['enrollmentEndDate'] ?? '',
      enrollmentEndDays: json['enrollmentEndDays'] is int ? json['enrollmentEndDays'] : int.tryParse(json['enrollmentEndDays'].toString()) ?? 0,
      imgURL: json['imgURL'] ?? '',
      imgThumbnail: json['imgThumbnail'] ?? '',
    );
  }
}
