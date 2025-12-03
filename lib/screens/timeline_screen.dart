import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/timeline_card.dart';
import 'team_selection_screen.dart';

class TimelineScreen extends StatelessWidget {
  const TimelineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Consumer<AppProvider>(
            builder: (context, provider, child) => Text(provider.selectedEvent?.name ?? 'Timeline'),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.group_add),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TeamSelectionScreen()),
                );
              },
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'My Teams'),
              Tab(text: 'Full Schedule'),
            ],
          ),
        ),
        body: Consumer<AppProvider>(
          builder: (context, provider, child) {
            if (provider.isLoadingTimeline) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.timeline.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'No timeline available for this event yet.\nCheck back closer to the competition date.',
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            return TabBarView(
              children: [
                _buildScheduleList(provider.mySchedule, true),
                _buildScheduleList(provider.timeline, false, provider.followedTeamIds),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildScheduleList(List<dynamic> items, bool isMySchedule, [Set<String>? followedIds]) {
    if (items.isEmpty) {
      return Center(
        child: Text(isMySchedule
            ? 'No teams selected.\nTap the icon above to select teams.'
            : 'No items found.'),
      );
    }

    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final isFollowed = followedIds?.contains(item.teamId) ?? true;
        return TimelineCard(item: item, isHighlight: isFollowed);
      },
    );
  }
}
