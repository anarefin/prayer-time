import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/district.dart';
import '../../models/area.dart';
import '../../providers/district_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/connectivity_provider.dart';
import '../../services/location_service.dart';
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
  final LocationService _locationService = LocationService();
  bool _hasAttemptedAutoLocation = false;
  bool _wasOffline = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeLocation();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkConnectivityAndRefresh();
  }

  /// Check connectivity and refresh data if coming back online
  void _checkConnectivityAndRefresh() {
    final connectivityProvider = context.watch<ConnectivityProvider>();
    
    // If was offline and now online, refresh districts
    if (_wasOffline && connectivityProvider.isConnected) {
      print('📡 Connectivity restored - refreshing districts');
      _wasOffline = false;
      
      // Reset selections to avoid stale references
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _selectedDivision = null;
            _selectedDistrict = null;
            _selectedArea = null;
          });
          
          // Reload districts from Firestore
          context.read<DistrictProvider>().loadDistricts();
        }
      });
    } else if (!connectivityProvider.isConnected) {
      _wasOffline = true;
    }
  }

  /// Initialize location and auto-select area based on user's current position
  Future<void> _initializeLocation() async {
    if (!mounted) return;

    final districtProvider = context.read<DistrictProvider>();
    
    // First, load districts
    await districtProvider.loadDistricts();
    
    // Only attempt auto-location once
    if (_hasAttemptedAutoLocation) return;
    _hasAttemptedAutoLocation = true;

    // Try to auto-select based on location
    await _attemptAutoLocation();
  }

  /// Attempt to auto-select location based on GPS
  Future<void> _attemptAutoLocation() async {
    if (!mounted) return;

    try {
      // Find nearest mosque within 50km radius
      final nearestMosque = await _locationService.findNearestMosque();
      
      if (nearestMosque == null) {
        // No nearby mosque found
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No nearby mosques found. Please select your area manually.'),
              duration: Duration(seconds: 4),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      // Get the area ID from the mosque
      final areaId = nearestMosque.areaId;
      
      if (!mounted) return;
      final districtProvider = context.read<DistrictProvider>();
      
      // Auto-select location based on area
      final success = await districtProvider.autoSelectLocationFromArea(areaId);
      
      if (success && mounted) {
        // Get the selected area and district for display
        final area = districtProvider.getSelectedArea();
        final district = districtProvider.getSelectedDistrict();
        
        if (area != null && district != null) {
          setState(() {
            _selectedDivision = district.divisionName;
            _selectedDistrict = district;
            _selectedArea = area;
          });
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Auto-selected ${area.name} based on your location. You can change it anytime.',
                ),
                duration: const Duration(seconds: 4),
                backgroundColor: Colors.green,
                action: SnackBarAction(
                  label: 'OK',
                  textColor: Colors.white,
                  onPressed: () {},
                ),
              ),
            );
          }
        }
      }
    } catch (e) {
      // Handle various location errors
      if (!mounted) return;
      
      String message;
      if (e.toString().contains('permission denied')) {
        message = 'Location permission denied. Please select your area manually.';
      } else if (e.toString().contains('Location services are disabled')) {
        message = 'Location services are disabled. Please enable them or select your area manually.';
      } else if (e.toString().contains('permanently denied')) {
        message = 'Location permission permanently denied. Please enable it in settings or select your area manually.';
      } else {
        message = 'Unable to get your location. Please select your area manually.';
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 5),
          backgroundColor: Colors.orange,
        ),
      );
    }
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
            // Welcome Banner (only shown when logged in)
            Consumer<AuthProvider>(
              builder: (context, authProvider, _) {
                if (!authProvider.isLoggedIn || authProvider.currentUser == null) {
                  return const SizedBox.shrink();
                }

                final user = authProvider.currentUser!;
                final email = user.email;
                final firstName = email.split('@').first;

                return Consumer<FavoritesProvider>(
                  builder: (context, favProvider, _) {
                    return Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.teal.shade400,
                              Colors.teal.shade600,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            // User Avatar
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.3),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Welcome Text
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Welcome back!',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    firstName,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.favorite,
                                        color: Colors.white,
                                        size: 14,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${favProvider.favoriteCount} favorites',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.9),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            // Sign Out Button
                            IconButton(
                              onPressed: () async {
                                final shouldSignOut = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Sign Out'),
                                    content: const Text('Are you sure you want to sign out?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, false),
                                        child: const Text('Cancel'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () => Navigator.pop(context, true),
                                        child: const Text('Sign Out'),
                                      ),
                                    ],
                                  ),
                                );
                                if (shouldSignOut == true && context.mounted) {
                                  await authProvider.signOut();
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Signed out successfully')),
                                    );
                                  }
                                }
                              },
                              icon: const Icon(Icons.logout, color: Colors.white),
                              tooltip: 'Sign Out',
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            Consumer<AuthProvider>(
              builder: (context, authProvider, _) {
                if (authProvider.isLoggedIn) {
                  return const SizedBox(height: 16);
                }
                return const SizedBox.shrink();
              },
            ),
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
    // Validate that selected district is in the list
    final validSelectedDistrict = _selectedDistrict != null && 
        districts.any((d) => d.id == _selectedDistrict!.id)
        ? _selectedDistrict
        : null;
    
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonFormField<District>(
        key: ValueKey('district_${districts.length}_${validSelectedDistrict?.id}'),
        value: validSelectedDistrict,
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
    // Validate that selected area is in the list
    final validSelectedArea = _selectedArea != null && 
        areas.any((a) => a.id == _selectedArea!.id)
        ? _selectedArea
        : null;
    
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonFormField<Area>(
        key: ValueKey('area_${areas.length}_${validSelectedArea?.id}'),
        value: validSelectedArea,
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

