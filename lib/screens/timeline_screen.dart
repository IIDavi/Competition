import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/timeline_card.dart';

class TimelineScreen extends StatelessWidget {
  const TimelineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<AppProvider>(
          builder: (context, provider, child) => Text(provider.selectedEvent?.name ?? 'Timeline'),
        ),
      ),
      body: Consumer<AppProvider>(
        builder: (context, provider, child) {
          if (provider.isLoadingTimeline) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.timeline.isEmpty) {
            return Column(
              children: [
                Container(
                  width: double.infinity,
                  color: Colors.amber.shade100,
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: const [
                      Icon(Icons.info_outline, color: Colors.amber),
                      SizedBox(width: 16),
                      Text(
                        'Timeline non disponibile',
                        style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const Expanded(
                  child: Center(
                    child: Text('Nessun dato presente per questo evento.'),
                  ),
                ),
              ],
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: provider.timeline.length,
            itemBuilder: (context, index) {
              final item = provider.timeline[index];
              return TimelineCard(item: item);
            },
          );
        },
      ),
    );
  }
}
