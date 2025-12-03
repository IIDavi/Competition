import 'package:flutter_test/flutter_test.dart';
import 'package:judge_rules_tracker/services/api_service.dart';

void main() {
  test('Fetch events from API and print result or error', () async {
    final service = ApiService();
    print('Starting fetch...');
    try {
      final events = await service.fetchEvents();
      print('Fetch complete. Found ${events.length} events.');
      
      if (events.isEmpty) {
        print('WARNING: Returned empty list.');
      } else {
        print('First event: ${events.first.name}');
      }
    } catch (e) {
      print('TEST FAILED WITH EXCEPTION: $e');
    }
  });
}
