import 'package:flutter/material.dart';
import '../models/timeline_item.dart';
import '../services/notification_service.dart';

class TimelineCard extends StatelessWidget {
  final TimelineItem item;
  final bool isHighlight;

  const TimelineCard({
    super.key,
    required this.item,
    this.isHighlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isHighlight ? Colors.blue.shade50 : null,
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  item.startingTime,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                Row(
                  children: [
                    Text(
                      'Heat ${item.heat} | Lane ${item.lane}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.alarm),
                      onPressed: () {
                        // In a real app, calculate time difference.
                        // For prototype: show confirmation.
                        NotificationService().showNotification(
                          'Alert Set', 
                          'You will be notified before ${item.teamName} starts at ${item.startingTime}'
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                           const SnackBar(content: Text('Alert scheduled (demo mode)')),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              item.teamName,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
                color: isHighlight ? Colors.blue.shade800 : Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              item.workoutName,
              style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Text('Warmup: ${item.warmupTime}', style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
