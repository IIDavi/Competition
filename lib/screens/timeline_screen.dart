import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
            tooltip: _showMyTeamsOnly ? 'Mostra tutto' : 'Mostra le tue squadre',
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
                    content: Text('Visualizzazione: Le tue squadre'),
                    duration: Duration(seconds: 1),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Visualizzazione: Tutti gli eventi'),
                    duration: Duration(seconds: 1),
                  ),
                );
              }
            },
          ),
          // Manage "My Teams"
          IconButton(
            tooltip: 'Gestisci le tue squadre',
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
              return item.teamName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                     item.participants.any((p) => p.toLowerCase().contains(_searchQuery.toLowerCase()));
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
                              ? 'Non segui ancora nessuna squadra.\nClicca sull\'icona "Gestisci le tue squadre" in alto.'
                              : 'Nessun risultato trovato.',
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
                    'Filtro attivo: Le tue squadre (${provider.followedTeamIds.length})',
                    style: TextStyle(color: Colors.blue.shade900, fontSize: 12),
                  ),
                ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: currentList.length,
                  itemBuilder: (context, index) {
                    final item = currentList[index];
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

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Cerca squadra o atleta...',
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
