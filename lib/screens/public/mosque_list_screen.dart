import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/area.dart';
import '../../providers/mosque_provider.dart';
import '../../providers/favorites_provider.dart';
import '../../widgets/mosque_card.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/facility_icon.dart';
import 'prayer_time_screen.dart';

/// Screen displaying list of mosques in an area
class MosqueListScreen extends StatefulWidget {
  final Area area;

  const MosqueListScreen({
    Key? key,
    required this.area,
  }) : super(key: key);

  @override
  State<MosqueListScreen> createState() => _MosqueListScreenState();
}

class _MosqueListScreenState extends State<MosqueListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load mosques for this area
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MosqueProvider>().loadMosquesByArea(widget.area.id);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.area.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter by facilities',
            onPressed: () => _showFacilityFiltersDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search mosques...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          context.read<MosqueProvider>().clearSearch();
                        },
                      )
                    : null,
              ),
              onChanged: (query) {
                context.read<MosqueProvider>().searchMosques(query);
              },
            ),
          ),
          // Active filters display
          Consumer<MosqueProvider>(
            builder: (context, provider, _) {
              if (!provider.hasActiveFacilityFilters) {
                return const SizedBox.shrink();
              }
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    const Text('Filters:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: provider.facilityFilters.entries
                              .where((e) => e.value)
                              .map((e) => Padding(
                                    padding: const EdgeInsets.only(right: 4),
                                    child: Chip(
                                      label: Text(
                                        FacilityIconData.getLabel(e.key),
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      onDeleted: () => provider.toggleFacilityFilter(e.key),
                                      deleteIconColor: Colors.white,
                                      backgroundColor: FacilityIconData.getColor(e.key),
                                      labelStyle: const TextStyle(color: Colors.white),
                                    ),
                                  ))
                              .toList(),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => provider.clearFacilityFilters(),
                      child: const Text('Clear All'),
                    ),
                  ],
                ),
              );
            },
          ),
          // Mosque list
          Expanded(
            child: Consumer<MosqueProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const LoadingIndicator(message: 'Loading mosques...');
                }

                if (provider.errorMessage != null) {
                  return ErrorState(
                    message: provider.errorMessage!,
                    onRetry: () => provider.loadMosquesByArea(widget.area.id),
                  );
                }

                if (provider.mosques.isEmpty) {
                  if (provider.searchQuery.isNotEmpty) {
                    return EmptyState(
                      icon: Icons.search_off,
                      title: 'No Results',
                      message:
                          'No mosques found matching "${provider.searchQuery}"',
                    );
                  }
                  return const EmptyState(
                    icon: Icons.mosque,
                    title: 'No Mosques',
                    message:
                        'No mosques have been added to this area yet.',
                  );
                }

                return ListView.builder(
                  itemCount: provider.mosques.length,
                  itemBuilder: (context, index) {
                    final mosque = provider.mosques[index];
                    
                    return Consumer<FavoritesProvider>(
                      builder: (context, favProvider, _) {
                        final isFavorite = favProvider.isFavorite(mosque.id);
                        
                        return MosqueCard(
                          mosque: mosque,
                          isFavorite: isFavorite,
                          onFavoriteToggle: () async {
                            await favProvider.toggleFavorite(mosque.id);
                          },
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PrayerTimeScreen(
                                  mosque: mosque,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showFacilityFiltersDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Filter by Facilities'),
        content: Consumer<MosqueProvider>(
          builder: (context, provider, _) {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: provider.facilityFilters.keys.map((facilityKey) {
                  final isActive = provider.facilityFilters[facilityKey] ?? false;
                  return CheckboxListTile(
                    title: Row(
                      children: [
                        Icon(
                          FacilityIconData.getIcon(facilityKey),
                          size: 20,
                          color: FacilityIconData.getColor(facilityKey),
                        ),
                        const SizedBox(width: 8),
                        Text(FacilityIconData.getLabel(facilityKey)),
                      ],
                    ),
                    value: isActive,
                    onChanged: (value) {
                      provider.toggleFacilityFilter(facilityKey);
                    },
                  );
                }).toList(),
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              context.read<MosqueProvider>().clearFacilityFilters();
            },
            child: const Text('Clear All'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

