import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/district.dart';
import '../../models/area.dart';
import '../../providers/district_provider.dart';
import '../../providers/mosque_provider.dart';
import 'mosque_list_screen.dart';
import 'favorites_screen.dart';
import 'nearest_mosque_screen.dart';
import 'qibla_compass_screen.dart';
import '../admin/admin_login_screen.dart';

/// Redesigned Home screen with dropdown selectors
class HomeScreenNew extends StatefulWidget {
  const HomeScreenNew({Key? key}) : super(key: key);

  @override
  State<HomeScreenNew> createState() => _HomeScreenNewState();
}

class _HomeScreenNewState extends State<HomeScreenNew> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> _screens = [
      const ImprovedHomeTab(),
      const FavoritesScreen(),
      const NearestMosqueScreen(),
      const QiblaCompassScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle(_selectedIndex)),
        actions: [
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
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).colorScheme.primary,
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
            icon: Icon(Icons.near_me),
            label: 'Nearby',
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
        return 'Prayer Time - Bangladesh';
      case 1:
        return 'Favorites';
      case 2:
        return 'Nearby Mosques';
      case 3:
        return 'Qibla Compass';
      default:
        return 'Prayer Time';
    }
  }
}

/// Improved Home Tab with Dropdown Selectors
class ImprovedHomeTab extends StatefulWidget {
  const ImprovedHomeTab({Key? key}) : super(key: key);

  @override
  State<ImprovedHomeTab> createState() => _ImprovedHomeTabState();
}

class _ImprovedHomeTabState extends State<ImprovedHomeTab> {
  String? _selectedDivision;
  District? _selectedDistrict;
  Area? _selectedArea;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DistrictProvider>().loadDistricts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.1),
            Colors.white,
          ],
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.primary.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.mosque,
                      size: 60,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Find Prayer Times',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Select your location to view mosques and prayer times',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Selection Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select Your Location',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Choose division, district and area',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                    const SizedBox(height: 24),

                    // Division Dropdown
                    Consumer<DistrictProvider>(
                      builder: (context, provider, _) {
                        if (provider.isLoading) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        final divisions = provider
                            .getDistrictsByDivision()
                            .keys
                            .toList()
                          ..sort();

                        return _buildDropdown(
                          icon: Icons.location_city,
                          label: 'Division',
                          value: _selectedDivision,
                          items: divisions,
                          onChanged: (value) {
                            setState(() {
                              _selectedDivision = value;
                              _selectedDistrict = null;
                              _selectedArea = null;
                            });
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // District Dropdown
                    if (_selectedDivision != null)
                      Consumer<DistrictProvider>(
                        builder: (context, provider, _) {
                          final districtsByDivision =
                              provider.getDistrictsByDivision();
                          final districts =
                              districtsByDivision[_selectedDivision] ?? [];

                          return _buildDistrictDropdown(
                            districts: districts,
                            onChanged: (district) {
                              setState(() {
                                _selectedDistrict = district;
                                _selectedArea = null;
                              });
                              if (district != null) {
                                provider.selectDistrict(district.id);
                                provider.loadAreasByDistrict(district.id);
                              }
                            },
                          );
                        },
                      ),
                    if (_selectedDivision != null) const SizedBox(height: 16),

                    // Area Dropdown
                    if (_selectedDistrict != null)
                      Consumer<DistrictProvider>(
                        builder: (context, provider, _) {
                          if (provider.isLoading) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(20),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }

                          return _buildAreaDropdown(
                            areas: provider.areasByDistrict,
                            onChanged: (area) {
                              setState(() {
                                _selectedArea = area;
                              });
                            },
                          );
                        },
                      ),
                    if (_selectedDistrict != null) const SizedBox(height: 24),

                    // Find Mosques Button
                    if (_selectedArea != null)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    MosqueListScreen(area: _selectedArea!),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.search),
                              SizedBox(width: 8),
                              Text(
                                'Find Mosques',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Quick Actions
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildQuickActionCard(
                    context,
                    icon: Icons.near_me,
                    title: 'Nearby\nMosques',
                    color: Colors.green,
                    onTap: () {
                      // Switch to nearby tab
                      if (mounted) {
                        final homeState =
                            context.findAncestorStateOfType<_HomeScreenNewState>();
                        homeState?.setState(() {
                          homeState._selectedIndex = 2;
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickActionCard(
                    context,
                    icon: Icons.explore,
                    title: 'Qibla\nDirection',
                    color: Colors.orange,
                    onTap: () {
                      // Switch to qibla tab
                      if (mounted) {
                        final homeState =
                            context.findAncestorStateOfType<_HomeScreenNewState>();
                        homeState?.setState(() {
                          homeState._selectedIndex = 3;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required IconData icon,
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Theme.of(context).colorScheme.primary),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        items: items.map((item) {
          return DropdownMenuItem(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildDistrictDropdown({
    required List<District> districts,
    required Function(District?) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonFormField<District>(
        value: _selectedDistrict,
        decoration: InputDecoration(
          labelText: 'District',
          prefixIcon:
              Icon(Icons.map, color: Theme.of(context).colorScheme.primary),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        items: districts.map((district) {
          return DropdownMenuItem(
            value: district,
            child: Text(district.name),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildAreaDropdown({
    required List<Area> areas,
    required Function(Area?) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonFormField<Area>(
        value: _selectedArea,
        decoration: InputDecoration(
          labelText: 'Area',
          prefixIcon: Icon(Icons.location_on,
              color: Theme.of(context).colorScheme.primary),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        items: areas.map((area) {
          return DropdownMenuItem(
            value: area,
            child: Text(area.name),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 32, color: color),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

