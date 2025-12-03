import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import 'timeline_screen.dart';

class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('JudgeRules Competitions'),
      ),
      body: Consumer<AppProvider>(
        builder: (context, provider, child) {
          if (provider.isLoadingEvents) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (provider.events.isEmpty) {
            if (provider.errorMessage != null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading events:\n${provider.errorMessage}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          Provider.of<AppProvider>(context, listen: false).fetchEvents();
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }
            return const Center(child: Text('No events found.'));
          }

          return ListView.builder(
            itemCount: provider.events.length,
            itemBuilder: (context, index) {
              final event = provider.events[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  title: Text(event.name),
                  subtitle: Text('${event.date} - ${event.locationCity ?? "Unknown Location"}'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    provider.selectEvent(event);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const TimelineScreen()),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Provider.of<AppProvider>(context, listen: false).fetchEvents();
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
