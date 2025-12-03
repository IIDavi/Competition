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
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.star),
                        label: const Text('Load South Throwdown (Demo)'),
                        onPressed: () {
                          final provider = Provider.of<AppProvider>(context, listen: false);
                          provider.loadDemoEvent().then((_) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const TimelineScreen()),
                            );
                          });
                        },
                      ),
                    ],
                  ),
                ),
              );
            }
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('No events found.'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                       final provider = Provider.of<AppProvider>(context, listen: false);
                       provider.loadDemoEvent().then((_) {
                         Navigator.push(
                           context,
                           MaterialPageRoute(builder: (context) => const TimelineScreen()),
                         );
                       });
                    },
                    child: const Text('Load South Throwdown (Demo)'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: provider.events.length,
            itemBuilder: (context, index) {
              final event = provider.events[index];
              return Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 16),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () {
                    provider.selectEvent(event);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const TimelineScreen()),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Banner Image
                      if (event.imgURL.isNotEmpty)
                        SizedBox(
                          height: 140,
                          width: double.infinity,
                          child: Image.network(
                            event.imgURL,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: Colors.grey[200],
                              child: const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                            ),
                          ),
                        ),
                        
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title
                            Text(
                              event.name,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            
                            // Date and Location
                            Row(
                              children: [
                                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(event.date, style: TextStyle(color: Colors.grey[700])),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.location_on, size: 16, color: Colors.grey),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    '${event.locationCity ?? "Unknown"}, ${event.locationRegion ?? ""}',
                                    style: TextStyle(color: Colors.grey[700]),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            
                            const Divider(height: 24),
                            
                            // Details Grid
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Type
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.blue.withOpacity(0.5)),
                                  ),
                                  child: Text(
                                    event.type.toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                // Enrollment Status
                                Text(
                                  'Ends in ${event.enrollmentEndDays} days',
                                  style: TextStyle(
                                    color: event.enrollmentEndDays < 7 ? Colors.red : Colors.green,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // Subscriber Stats
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('👥 Total: ${event.totalSubscribers}'),
                                Text('👤 Ind: ${event.individualsSubscribed}'),
                                Text('🛡️ Team: ${event.teamsSubscribed}'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
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
