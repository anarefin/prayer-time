import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/area.dart';
import '../../providers/mosque_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/favorites_provider.dart';
import '../../widgets/mosque_card.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/empty_state.dart';
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
    final authProvider = context.watch<AuthProvider>();
    final isLoggedIn = authProvider.isLoggedIn;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.area.name),
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
                          showFavoriteButton: isLoggedIn,
                          onFavoriteToggle: isLoggedIn
                              ? () async {
                                  if (authProvider.currentUser != null) {
                                    await favProvider.toggleFavorite(
                                      authProvider.currentUser!.uid,
                                      mosque.id,
                                    );
                                  }
                                }
                              : null,
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
}

