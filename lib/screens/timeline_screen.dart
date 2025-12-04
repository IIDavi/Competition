import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/timeline_item.dart';
import '../providers/app_provider.dart';
import '../widgets/timeline_card.dart';
import '../widgets/team_selection_modal.dart';

class TimelineScreen extends StatefulWidget {
  const TimelineScreen({super.key});

  @override
  State<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _showMyTeamsOnly = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<AppProvider>(
          builder: (context, provider, child) => 
            Text(provider.selectedEvent?.name ?? 'Timeline'),
        ),
        actions: [
          // Toggle "My Teams" view
          IconButton(
            tooltip: _showMyTeamsOnly ? 'Show all' : 'Show my teams',
            icon: Icon(
              _showMyTeamsOnly ? Icons.filter_alt : Icons.filter_alt_off,
              color: _showMyTeamsOnly ? Colors.blue : null,
            ),
            onPressed: () {
              setState(() {
                _showMyTeamsOnly = !_showMyTeamsOnly;
              });
              
              if (_showMyTeamsOnly) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('View: Your teams'),
                    duration: Duration(seconds: 1),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('View: All events'),
                    duration: Duration(seconds: 1),
                  ),
                );
              }
            },
          ),
          // Manage "My Teams"
          IconButton(
            tooltip: 'Manage your teams',
            icon: const Icon(Icons.groups),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) => const TeamSelectionModal(),
              );
            },
          ),
        ],
      ),
      body: Consumer<AppProvider>(
        builder: (context, provider, child) {
          if (provider.isLoadingTimeline) {
            return const Center(child: CircularProgressIndicator());
          }

          // 1. Select Source List
          List<TimelineItem> currentList = _showMyTeamsOnly 
              ? provider.mySchedule 
              : provider.timeline;

          // 2. Apply Text Search Filter
          if (_searchQuery.isNotEmpty) {
            currentList = currentList.where((item) {
              final query = _searchQuery.toLowerCase();
              return item.teamName.toLowerCase().contains(query) ||
                     item.participants.any((p) => p.toLowerCase().contains(query));
            }).toList();
          }

          if (currentList.isEmpty) {
            return Column(
              children: [
                _buildSearchBar(),
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _showMyTeamsOnly ? Icons.groups_3 : Icons.search_off,
                          size: 64, 
                          color: Colors.grey.shade300
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _showMyTeamsOnly && provider.followedTeamIds.isEmpty
                              ? 'You are not following any team yet.\nClick the "Manage your teams" icon above.'
                              : 'The timeline is not available yet.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }

          return Column(
            children: [
              _buildSearchBar(),
              if (_showMyTeamsOnly)
                Container(
                  width: double.infinity,
                  color: Colors.blue.shade50,
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                  child: Text(
                    'Active filter: Your teams (${provider.followedTeamIds.length})',
                    style: TextStyle(color: Colors.blue.shade900, fontSize: 12),
                  ),
                ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: currentList.length,
                  itemBuilder: (context, index) {
                    final item = currentList[index];
                    bool showHeader = false;
                    
                    if (index == 0) {
                      showHeader = true;
                    } else {
                      final prevItem = currentList[index - 1];
                      if (item.date != prevItem.date) {
                        showHeader = true;
                      }
                    }

                    if (showHeader) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDateHeader(item),
                          TimelineCard(
                            item: item, 
                            isHighlight: provider.isFollowing(item.teamId),
                          ),
                        ],
                      );
                    }
                    
                    return TimelineCard(
                      item: item, 
                      isHighlight: provider.isFollowing(item.teamId),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDateHeader(TimelineItem item) {
    String dateText = item.date;
    try {
      final dt = item.startDateTime;
      if (dt != null) {
        // Example: "Sabato 6 Dicembre" (assuming Italian locale or default en)
        // Note: initializeDateFormatting might be needed in main.dart depending on locale usage,
        // but often standard patterns work. Let's stick to a safe simple format or English default if IT not loaded.
        // We will try to format it nicely.
        dateText = DateFormat('EEEE d MMMM yyyy').format(dt);
      }
    } catch (_) {}

    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0, left: 8.0),
      child: Row(
        children: [
          const Icon(Icons.calendar_today, size: 16, color: Colors.blueGrey),
          const SizedBox(width: 8),
          Text(
            dateText,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey,
            ),
          ),
          const SizedBox(width: 8),
          const Expanded(child: Divider(thickness: 1, color: Colors.blueGrey)),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search team or athlete...',
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }
}
