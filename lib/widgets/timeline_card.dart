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

  Color _getCategoryColor(String category) {
    if (category.isEmpty) return Colors.grey;
    final hash = category.hashCode;
    final colors = [
      Colors.red.shade100, Colors.green.shade100, Colors.blue.shade100, 
      Colors.orange.shade100, Colors.purple.shade100, Colors.teal.shade100, 
      Colors.pink.shade100, Colors.indigo.shade100, Colors.brown.shade100, 
      Colors.cyan.shade100, Colors.lime.shade100, Colors.amber.shade100
    ];
    // Return a lighter shade for background, maybe use darker for text
    return colors[hash.abs() % colors.length];
  }
  
  Color _getCategoryTextColor(String category) {
     if (category.isEmpty) return Colors.black54;
    final hash = category.hashCode;
    final colors = [
      Colors.red.shade900, Colors.green.shade900, Colors.blue.shade900, 
      Colors.orange.shade900, Colors.purple.shade900, Colors.teal.shade900, 
      Colors.pink.shade900, Colors.indigo.shade900, Colors.brown.shade900, 
      Colors.cyan.shade900, Colors.lime.shade900, Colors.amber.shade900
    ];
    return colors[hash.abs() % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.hardEdge,
      color: isHighlight ? Colors.blue.shade50 : null,
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: InkWell(
        onTap: () {
          showModalBottomSheet(
            context: context,
            builder: (ctx) => Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Partecipanti - ${item.teamName}',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Divider(),
                  if (item.participants.isNotEmpty)
                    Flexible(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: item.participants.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            leading: const Icon(Icons.person_outline),
                            title: Text(item.participants[index]),
                            dense: true,
                          );
                        },
                      ),
                    )
                  else
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Text('Nessuna informazione sui partecipanti disponibile.'),
                    ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          );
        },
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
                            'Sarai avvisato prima che ${item.teamName} inizi alle ${item.startingTime}'
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                             const SnackBar(content: Text('Notifica programmata (demo)')),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 4),
              // Category Badge
              if (item.category.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(item.category),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      item.category,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _getCategoryTextColor(item.category),
                      ),
                    ),
                  ),
                ),
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
      ),
    );
  }
}
