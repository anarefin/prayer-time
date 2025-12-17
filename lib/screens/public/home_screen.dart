import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/mosque_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/area_tile.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/empty_state.dart';
import 'mosque_list_screen.dart';
import 'favorites_screen.dart';
import 'qibla_compass_screen.dart';
import '../admin/admin_login_screen.dart';

/// Home screen with area selection and bottom navigation
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const AreaSelectionScreen(),
    const FavoritesScreen(),
    const QiblaCompassScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle(_selectedIndex)),
        actions: [
          // Admin login button
          IconButton(
            icon: const Icon(Icons.admin_panel_settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdminLoginScreen(),
                ),
              );
            },
            tooltip: 'Admin Login',
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: 'Qibla',
          ),
        ],
      ),
    );
  }

  String _getTitle(int index) {
    switch (index) {
      case 0:
        return 'Prayer Time';
      case 1:
        return 'Favorites';
      case 2:
        return 'Qibla Compass';
      default:
        return 'Prayer Time';
    }
  }
}

/// Area selection screen (Home tab content)
class AreaSelectionScreen extends StatefulWidget {
  const AreaSelectionScreen({Key? key}) : super(key: key);

  @override
  State<AreaSelectionScreen> createState() => _AreaSelectionScreenState();
}

class _AreaSelectionScreenState extends State<AreaSelectionScreen> {
  @override
  void initState() {
    super.initState();
    // Load areas on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MosqueProvider>().loadAreas();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MosqueProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const LoadingIndicator(message: 'Loading areas...');
        }

        if (provider.errorMessage != null) {
          return ErrorState(
            message: provider.errorMessage!,
            onRetry: () => provider.loadAreas(),
          );
        }

        if (provider.areas.isEmpty) {
          return const EmptyState(
            icon: Icons.location_city,
            title: 'No Areas Available',
            message: 'No areas have been added yet. Please contact the administrator.',
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select Your Area',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Choose an area to view mosques and prayer times',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: provider.areas.length,
                itemBuilder: (context, index) {
                  final area = provider.areas[index];
                  return AreaTile(
                    area: area,
                    onTap: () {
                      provider.selectArea(area.id);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MosqueListScreen(area: area),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

