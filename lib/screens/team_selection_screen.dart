import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class TeamSelectionScreen extends StatefulWidget {
  const TeamSelectionScreen({super.key});

  @override
  State<TeamSelectionScreen> createState() => _TeamSelectionScreenState();
}

class _TeamSelectionScreenState extends State<TeamSelectionScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Teams'),
      ),
      body: Consumer<AppProvider>(
        builder: (context, provider, child) {
          final allTeams = provider.availableTeams;
          final filteredTeams = _searchQuery.isEmpty
              ? allTeams
              : allTeams.where((t) =>
                  t['name']!.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Search Team',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: filteredTeams.length,
                  itemBuilder: (context, index) {
                    final team = filteredTeams[index];
                    final teamId = team['id']!;
                    final isSelected = provider.isFollowing(teamId);

                    return CheckboxListTile(
                      title: Text(team['name']!),
                      value: isSelected,
                      onChanged: (bool? value) {
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
