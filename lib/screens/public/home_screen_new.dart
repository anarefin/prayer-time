import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/district.dart';
import '../../models/area.dart';
import '../../providers/district_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/connectivity_provider.dart';
import '../../services/location_service.dart';
import '../../services/local_storage_service.dart';
import '../../widgets/location_detection_dialog.dart';
import 'mosque_list_screen.dart';
import 'favorites_screen.dart';
import 'nearest_mosque_screen.dart';
import 'qibla_compass_screen.dart';
import '../admin/admin_tab.dart'; // Import AdminTab

/// Redesigned Home screen with dropdown selectors
class HomeScreenNew extends StatefulWidget {
  const HomeScreenNew({super.key});

  @override
  State<HomeScreenNew> createState() => _HomeScreenNewState();
}

class _HomeScreenNewState extends State<HomeScreenNew> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      const ImprovedHomeTab(),
      const FavoritesScreen(),
      const NearestMosqueScreen(),
      const QiblaCompassScreen(),
      const AdminTab(), // Added Admin Tab
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle(_selectedIndex)),
        // Removed admin icon action
      ),
      body: screens[_selectedIndex],
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
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.near_me), label: 'Nearby'),
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Qibla'),
          BottomNavigationBarItem(
            icon: Icon(Icons.admin_panel_settings),
            label: 'Admin',
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
      case 4:
        return 'Admin Portal';
      default:
        return 'Prayer Time';
    }
  }
}

/// Improved Home Tab with Dropdown Selectors
class ImprovedHomeTab extends StatefulWidget {
  const ImprovedHomeTab({super.key});

  @override
  State<ImprovedHomeTab> createState() => _ImprovedHomeTabState();
}

class _ImprovedHomeTabState extends State<ImprovedHomeTab>
    with WidgetsBindingObserver {
  String? _selectedDivision;
  District? _selectedDistrict;
  Area? _selectedArea;
  final LocationService _locationService = LocationService();
  final LocalStorageService _localStorageService = LocalStorageService();
  bool _wasOffline = false;
  bool _previousConnectivityState = true;
  bool _connectivityListenerSetup = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeLocation();
      _setupConnectivityListener();
    });
  }

  /// Set up connectivity listener to only respond to actual connectivity changes
  void _setupConnectivityListener() {
    if (!mounted || _connectivityListenerSetup) return;
    try {
      final connectivityProvider = context.read<ConnectivityProvider>();
      _previousConnectivityState = connectivityProvider.isConnected;

      // Listen to connectivity changes via provider's notifyListeners
      connectivityProvider.addListener(_onConnectivityChanged);
      _connectivityListenerSetup = true;
    } catch (e) {
      debugPrint('Error setting up connectivity listener: $e');
    }
  }

  /// Handle connectivity changes - only called when connectivity actually changes
  void _onConnectivityChanged() {
    if (!mounted) return;
    final connectivityProvider = context.read<ConnectivityProvider>();
    final isConnected = connectivityProvider.isConnected;

    // Only respond to actual connectivity state changes
    if (_previousConnectivityState != isConnected) {
      _previousConnectivityState = isConnected;
      _checkConnectivityAndRefresh();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // Remove connectivity listener
    if (_connectivityListenerSetup) {
      try {
        context.read<ConnectivityProvider>().removeListener(
          _onConnectivityChanged,
        );
      } catch (e) {
        // Provider might already be disposed
      }
    }
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Do NOT check connectivity here - it's called on every tab navigation
    // Connectivity is now handled by a proper listener in initState()
  }

  /// Check connectivity and refresh data if coming back online
  void _checkConnectivityAndRefresh() {
    if (!mounted) return;
    final connectivityProvider = context.read<ConnectivityProvider>();

    // If was offline and now online, refresh districts
    if (_wasOffline && connectivityProvider.isConnected) {
      debugPrint('📡 Connectivity restored - refreshing districts');
      _wasOffline = false;

      // Only reload districts and preferences, do NOT trigger location detection again
      // if it has already been attempted
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          // Reload districts from Firestore
          context.read<DistrictProvider>().loadDistricts().then((_) {
            if (mounted) {
              // Only reload saved preferences, don't trigger location detection
              _loadSavedPreference();
            }
          });
        }
      });
    } else if (!connectivityProvider.isConnected) {
      _wasOffline = true;
    }
  }

  /// Load saved location preference
  Future<bool> _loadSavedPreference() async {
    if (!mounted) return false;

    final preference = await _localStorageService.getLocationPreference();
    if (preference == null) return false;

    final districtProvider = context.read<DistrictProvider>();

    try {
      // Load the saved area
      final success = await districtProvider.autoSelectLocationFromArea(
        preference['areaId']!,
      );

      if (success && mounted) {
        // Get the selected area and district
        final area = districtProvider.getSelectedArea();
        final district = districtProvider.getSelectedDistrict();

        if (area != null && district != null) {
          setState(() {
            _selectedDivision = district.divisionName;
            _selectedDistrict = district;
            _selectedArea = area;
          });
          return true;
        }
      }
    } catch (e) {
      debugPrint('Error loading saved preference: $e');
    }

    return false;
  }

  /// Initialize location and auto-select area based on user's current position
  Future<void> _initializeLocation() async {
    if (!mounted) return;

    final districtProvider = context.read<DistrictProvider>();

    // First, load districts
    await districtProvider.loadDistricts();

    // Check if we've already checked location this session
    if (districtProvider.isLocationChecked) {
      // Just load saved preference without checking location again
      await _loadSavedPreference();
      return;
    }

    // Try to load saved preference first (to populate dropdowns immediately)
    final hasSavedPreference = await _loadSavedPreference();

    // Always attempt to detect location with dialog when app opens
    if (hasSavedPreference) {
      // Has saved preference, check if location changed
      await _checkLocationUpdate();
    } else {
      // No saved preference, do first-time auto-location
      await _attemptAutoLocation();
    }

    // Mark location as checked for this session
    if (mounted) {
      districtProvider.markLocationChecked();
    }
  }

  /// Save location preference to local storage
  Future<void> _saveLocationPreference() async {
    if (_selectedDivision != null &&
        _selectedDistrict != null &&
        _selectedArea != null) {
      await _localStorageService.saveLocationPreference(
        divisionName: _selectedDivision!,
        districtId: _selectedDistrict!.id,
        areaId: _selectedArea!.id,
      );
    }
  }

  /// Check if user's current location differs significantly from saved location
  /// and update if necessary
  Future<void> _checkLocationUpdate() async {
    if (!mounted) return;
    if (_selectedArea == null) return;

    // Check if location services are enabled first
    final isLocationEnabled = await _locationService.isLocationServiceEnabled();

    if (!isLocationEnabled) {
      // Show location disabled dialog
      if (mounted) {
        await LocationDisabledDialog.show(context);
      }
      return;
    }

    // Show loading dialog while checking location
    bool dialogCancelled = false;
    LocationDetectionDialog.show(context).then((cancelled) {
      if (cancelled == true) {
        dialogCancelled = true;
      }
    });

    try {
      // Get current location with dialog showing
      final nearestMosque = await _locationService.findNearestMosque();

      // Dismiss dialog
      if (mounted && !dialogCancelled) {
        LocationDetectionDialog.dismiss(context);
      }

      if (dialogCancelled) return;

      if (nearestMosque == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No nearby mosques found. Using saved location.'),
              duration: Duration(seconds: 3),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      // Check if the nearest mosque is in a different area
      if (nearestMosque.areaId != _selectedArea!.id) {
        // Location has changed significantly
        if (!mounted) return;
        final districtProvider = context.read<DistrictProvider>();

        // Auto-select new location based on area
        final success = await districtProvider.autoSelectLocationFromArea(
          nearestMosque.areaId,
        );

        if (success && mounted) {
          final area = districtProvider.getSelectedArea();
          final district = districtProvider.getSelectedDistrict();

          if (area != null && district != null) {
            setState(() {
              _selectedDivision = district.divisionName;
              _selectedDistrict = district;
              _selectedArea = area;
            });

            // Save new preference
            await _saveLocationPreference();

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Location updated to ${area.name} based on your current position.',
                  ),
                  duration: const Duration(seconds: 3),
                  backgroundColor: Colors.green,
                ),
              );
            }
          }
        }
      } else {
        // Same location, just show brief confirmation
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Location confirmed: ${_selectedArea!.name}'),
              duration: const Duration(seconds: 2),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      // Dismiss dialog on error
      if (mounted && !dialogCancelled) {
        LocationDetectionDialog.dismiss(context);
      }

      if (!mounted || dialogCancelled) return;

      // Handle errors
      String message;
      if (e.toString().contains('permission denied')) {
        message = 'Location permission denied. Using saved location.';
      } else if (e.toString().contains('permanently denied')) {
        message = 'Location permission denied. Please enable in settings.';
      } else {
        message = 'Could not detect location. Using saved location.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  /// Attempt to auto-select location based on GPS
  Future<void> _attemptAutoLocation({bool updateExisting = false}) async {
    if (!mounted) return;

    // Check if location services are enabled first
    final isLocationEnabled = await _locationService.isLocationServiceEnabled();

    if (!isLocationEnabled) {
      // Show location disabled dialog immediately
      if (mounted) {
        await LocationDisabledDialog.show(context);
      }
      return;
    }

    // Show loading dialog
    bool dialogCancelled = false;
    LocationDetectionDialog.show(context).then((cancelled) {
      if (cancelled == true) {
        dialogCancelled = true;
      }
    });

    try {
      // Find nearest mosque within 50km radius
      final nearestMosque = await _locationService.findNearestMosque();

      // Check if dialog was cancelled
      if (dialogCancelled) {
        return;
      }

      // Dismiss loading dialog
      if (mounted) {
        LocationDetectionDialog.dismiss(context);
      }

      if (nearestMosque == null) {
        // No nearby mosque found
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'No nearby mosques found. Please select your area manually.',
              ),
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

          // Save preference after auto-selection
          await _saveLocationPreference();

          if (mounted) {
            final message = updateExisting
                ? 'Location updated to ${area.name} based on your current position.'
                : 'Auto-selected ${area.name} based on your location. You can change it anytime.';

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message),
                duration: const Duration(seconds: 3),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
      }
    } catch (e) {
      // Dismiss loading dialog
      if (mounted && !dialogCancelled) {
        LocationDetectionDialog.dismiss(context);
      }

      // Handle various location errors
      if (!mounted) return;

      // Check if location services are disabled
      if (e.toString().contains('Location services are disabled')) {
        // Show location disabled dialog
        await LocationDisabledDialog.show(context);
        return;
      }

      String message;
      if (e.toString().contains('permission denied')) {
        message =
            'Location permission denied. Please select your area manually.';
      } else if (e.toString().contains('permanently denied')) {
        message =
            'Location permission permanently denied. Please enable it in settings or select your area manually.';
      } else {
        message =
            'Unable to get your location. Please select your area manually.';
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
                if (!authProvider.isLoggedIn ||
                    authProvider.currentUser == null) {
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
                                    content: const Text(
                                      'Are you sure you want to sign out?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: const Text('Cancel'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        child: const Text('Sign Out'),
                                      ),
                                    ],
                                  ),
                                );
                                if (shouldSignOut == true && context.mounted) {
                                  await authProvider.signOut();
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Signed out successfully',
                                        ),
                                      ),
                                    );
                                  }
                                }
                              },
                              icon: const Icon(
                                Icons.logout,
                                color: Colors.white,
                              ),
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
                    const Icon(Icons.mosque, size: 60, color: Colors.white),
                    const SizedBox(height: 16),
                    Text(
                      'Find Prayer Times',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
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
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
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

                        final divisions =
                            provider.getDistrictsByDivision().keys.toList()
                              ..sort();

                        return _buildDropdown(
                          icon: Icons.location_city,
                          label: 'Division',
                          value: _selectedDivision,
                          items: divisions,
                          enabled: true,
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

                    // District Dropdown - Always visible
                    Consumer<DistrictProvider>(
                      builder: (context, provider, _) {
                        final districtsByDivision = provider
                            .getDistrictsByDivision();
                        final districts =
                            districtsByDivision[_selectedDivision] ?? [];
                        final isEnabled = _selectedDivision != null;

                        return _buildDistrictDropdown(
                          districts: districts.isEmpty
                              ? [
                                  District(
                                    id: 'placeholder',
                                    name: 'Select division first',
                                    divisionName: '',
                                    order: 0,
                                  ),
                                ]
                              : districts,
                          enabled: isEnabled,
                          onChanged: (district) {
                            if (district?.id == 'placeholder') return;
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
                    const SizedBox(height: 16),

                    // Area Dropdown - Always visible
                    Consumer<DistrictProvider>(
                      builder: (context, provider, _) {
                        if (provider.isLoading && _selectedDistrict != null) {
                          return Container(
                            height: 60,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Center(
                              child: SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                          );
                        }

                        final areas = provider.areasByDistrict;
                        final isEnabled = _selectedDistrict != null;

                        return _buildAreaDropdown(
                          areas: areas.isEmpty
                              ? [
                                  Area(
                                    id: 'placeholder',
                                    name: 'Select district first',
                                    districtId: '',
                                    order: 0,
                                  ),
                                ]
                              : areas,
                          enabled: isEnabled,
                          onChanged: (area) async {
                            if (area?.id == 'placeholder') return;
                            setState(() {
                              _selectedArea = area;
                            });
                            // Save preference when user manually selects area
                            if (area != null) {
                              await _saveLocationPreference();
                            }
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    // Find Mosques Button - Always visible
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _selectedArea != null
                            ? () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        MosqueListScreen(area: _selectedArea!),
                                  ),
                                );
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
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
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
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
                        final homeState = context
                            .findAncestorStateOfType<_HomeScreenNewState>();
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
                        final homeState = context
                            .findAncestorStateOfType<_HomeScreenNewState>();
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
    bool enabled = true,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: enabled ? Colors.grey[300]! : Colors.grey[200]!,
        ),
        borderRadius: BorderRadius.circular(12),
        color: enabled ? null : Colors.grey[50],
      ),
      child: IgnorePointer(
        ignoring: !enabled,
        child: Opacity(
          opacity: enabled ? 1.0 : 0.5,
          child: DropdownButtonFormField<String>(
            initialValue: value,
            decoration: InputDecoration(
              labelText: label,
              prefixIcon: Icon(
                icon,
                color: enabled
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey[400],
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            items: items.map((item) {
              return DropdownMenuItem(value: item, child: Text(item));
            }).toList(),
            onChanged: enabled ? onChanged : null,
          ),
        ),
      ),
    );
  }

  Widget _buildDistrictDropdown({
    required List<District> districts,
    required Function(District?) onChanged,
    bool enabled = true,
  }) {
    // Validate that selected district is in the list
    final validSelectedDistrict =
        _selectedDistrict != null &&
            districts.any((d) => d.id == _selectedDistrict!.id)
        ? _selectedDistrict
        : null;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: enabled ? Colors.grey[300]! : Colors.grey[200]!,
        ),
        borderRadius: BorderRadius.circular(12),
        color: enabled ? null : Colors.grey[50],
      ),
      child: IgnorePointer(
        ignoring: !enabled,
        child: Opacity(
          opacity: enabled ? 1.0 : 0.5,
          child: DropdownButtonFormField<District>(
            key: ValueKey(
              'district_${districts.length}_${validSelectedDistrict?.id}',
            ),
            initialValue: validSelectedDistrict,
            decoration: InputDecoration(
              labelText: 'District',
              prefixIcon: Icon(
                Icons.map,
                color: enabled
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey[400],
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            items: districts.map((district) {
              return DropdownMenuItem(
                value: district,
                child: Text(district.name),
              );
            }).toList(),
            onChanged: enabled ? onChanged : null,
          ),
        ),
      ),
    );
  }

  Widget _buildAreaDropdown({
    required List<Area> areas,
    required Function(Area?) onChanged,
    bool enabled = true,
  }) {
    // Validate that selected area is in the list
    final validSelectedArea =
        _selectedArea != null && areas.any((a) => a.id == _selectedArea!.id)
        ? _selectedArea
        : null;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: enabled ? Colors.grey[300]! : Colors.grey[200]!,
        ),
        borderRadius: BorderRadius.circular(12),
        color: enabled ? null : Colors.grey[50],
      ),
      child: IgnorePointer(
        ignoring: !enabled,
        child: Opacity(
          opacity: enabled ? 1.0 : 0.5,
          child: DropdownButtonFormField<Area>(
            key: ValueKey('area_${areas.length}_${validSelectedArea?.id}'),
            initialValue: validSelectedArea,
            decoration: InputDecoration(
              labelText: 'Area',
              prefixIcon: Icon(
                Icons.location_on,
                color: enabled
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey[400],
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            items: areas.map((area) {
              return DropdownMenuItem(value: area, child: Text(area.name));
            }).toList(),
            onChanged: enabled ? onChanged : null,
          ),
        ),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                style: const TextStyle(
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
