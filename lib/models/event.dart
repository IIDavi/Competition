class Event {
  final String id;
  final String name;
  final String date;
  final String? locationCity;
  final int state;

  Event({
    required this.id,
    required this.name,
    required this.date,
    this.locationCity,
    required this.state,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'].toString(),
      name: json['name'] ?? 'Unknown Event',
      date: json['date'] ?? '',
      locationCity: json['location']?['city'],
      state: json['state'] is int ? json['state'] : int.tryParse(json['state'].toString()) ?? 0,
    );
  }
}
