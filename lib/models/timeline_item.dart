class TimelineItem {
  final String teamId;
  final String teamName;
  final String workoutName;
  final String heat;
  final String lane;
  final String warmupTime;
  final String startingTime;
  final String category;
  final String date; // "06-12-2025"

  TimelineItem({
    required this.teamId,
    required this.teamName,
    required this.workoutName,
    required this.heat,
    required this.lane,
    required this.warmupTime,
    required this.startingTime,
    required this.category,
    required this.date,
  });

  factory TimelineItem.fromJson(Map<String, dynamic> json) {
    final team = json['team'];
    final athlete = json['athlete'];

    String id = '';
    String name = 'Unknown';

    if (team != null) {
      id = team['id']?.toString() ?? '';
      name = team['name'] ?? 'Unknown Team';
    } else if (athlete != null) {
      // Fallback for individual events
      id = athlete['id']?.toString() ?? '';
      final firstName = athlete['firstName'] ?? '';
      final lastName = athlete['lastName'] ?? '';
      name = '$firstName $lastName'.trim();
      if (name.isEmpty) name = 'Unknown Athlete';
    }

    return TimelineItem(
      teamId: id,
      teamName: name,
      workoutName: json['workoutName'] ?? '',
      heat: json['heat']?.toString() ?? '',
      lane: json['lane']?.toString() ?? '',
      warmupTime: json['warmupTime'] ?? '',
      startingTime: json['startingTime'] ?? '',
      category: json['category'] ?? '',
      date: json['date'] ?? '',
    );
  }

  // Helper to get a proper DateTime object for sorting/alarms
  DateTime? get startDateTime {
    try {
      // Date format appears to be DD-MM-YYYY based on "06-12-2025"
      final dateParts = date.split('-');
      if (dateParts.length != 3) return null;
      
      final timeParts = startingTime.split(':');
      if (timeParts.length != 2) return null;

      return DateTime(
        int.parse(dateParts[2]), // Year
        int.parse(dateParts[1]), // Month
        int.parse(dateParts[0]), // Day
        int.parse(timeParts[0]), // Hour
        int.parse(timeParts[1]), // Minute
      );
    } catch (e) {
      return null;
    }
  }
}
