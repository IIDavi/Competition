import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class TeamSelectionModal extends StatefulWidget {
  const TeamSelectionModal({super.key});

  @override
  State<TeamSelectionModal> createState() => _TeamSelectionModalState();
}

class _TeamSelectionModalState extends State<TeamSelectionModal> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      padding: const EdgeInsets.all(16.0),
      child: Consumer<AppProvider>(
        builder: (context, provider, child) {
          final allTeams = provider.availableTeams;
          
          // Filter teams based on search query
          final filteredTeams = allTeams.where((team) {
            final name = team['name']?.toLowerCase() ?? '';
            return name.contains(_searchQuery.toLowerCase());
          }).toList();

          // Sort: Followed teams first, then alphabetical
          filteredTeams.sort((a, b) {
            final aId = a['id']!;
            final bId = b['id']!;
            final aFollowed = provider.isFollowing(aId);
            final bFollowed = provider.isFollowing(bId);

            if (aFollowed && !bFollowed) return -1;
            if (!aFollowed && bFollowed) return 1;
            return (a['name'] ?? '').compareTo(b['name'] ?? '');
          });

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Your teams',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Search team...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              Expanded(
                child: filteredTeams.isEmpty
                    ? const Center(child: Text('No teams found'))
                    : ListView.builder(
                        itemCount: filteredTeams.length,
                        itemBuilder: (context, index) {
                          final team = filteredTeams[index];
                          final teamId = team['id']!;
                          final teamName = team['name']!;
                          final isFollowing = provider.isFollowing(teamId);

                          return CheckboxListTile(
                            title: Text(teamName),
                            value: isFollowing,
                            activeColor: Colors.blue,
                            onChanged: (_) {
                              provider.toggleTeamFollow(teamId);
                            },
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
}
