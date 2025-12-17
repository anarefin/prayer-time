import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/favorites_provider.dart';
import '../../widgets/mosque_card.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/empty_state.dart';
import 'prayer_time_screen.dart';

/// Screen displaying user's favorite mosques
class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  void _loadFavorites() {
    // Load favorites from local storage
    context.read<FavoritesProvider>().initializeFavorites();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FavoritesProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const LoadingIndicator(message: 'Loading favorites...');
        }

        if (provider.errorMessage != null) {
          return ErrorState(
            message: provider.errorMessage!,
            onRetry: _loadFavorites,
          );
        }

        if (provider.favoriteMosques.isEmpty) {
          return const EmptyState(
            icon: Icons.favorite_border,
            title: 'No Favorites Yet',
            message:
                'Start adding mosques to your favorites to see them here.',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: provider.favoriteMosques.length,
          itemBuilder: (context, index) {
            final mosque = provider.favoriteMosques[index];
            return MosqueCard(
              mosque: mosque,
              isFavorite: true,
              onFavoriteToggle: () async {
                await provider.removeFavorite(mosque.id);
              },
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PrayerTimeScreen(mosque: mosque),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

