import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/mosque.dart';
import '../../providers/mosque_provider.dart';
import '../../services/location_service.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/empty_state.dart';
import 'prayer_time_screen.dart';

/// Screen showing nearby mosques with list view
class NearestMosqueScreen extends StatefulWidget {
  const NearestMosqueScreen({Key? key}) : super(key: key);

  @override
  State<NearestMosqueScreen> createState() => _NearestMosqueScreenState();
}

class _NearestMosqueScreenState extends State<NearestMosqueScreen> {
  final LocationService _locationService = LocationService();
  bool _isLoading = true;
  String? _errorMessage;
  double? _userLat;
  double? _userLng;
  final double _searchRadius = 5.0; // 5km radius

  @override
  void initState() {
    super.initState();
    _loadNearbyMosques();
  }

  Future<void> _loadNearbyMosques() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Get user location
      final position = await _locationService.getCurrentPosition();
      _userLat = position.latitude;
      _userLng = position.longitude;

      // Load nearby mosques
      if (mounted) {
        await context
            .read<MosqueProvider>()
            .loadNearbyMosques(radiusKm: _searchRadius);
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _openAllMosquesInMap(List<Mosque> mosques) async {
    if (mosques.isEmpty || _userLat == null || _userLng == null) return;

    try {
      await _locationService.openMultipleMosquesInMap(
        mosques,
        _userLat!,
        _userLng!,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const LoadingIndicator(message: 'Finding nearby mosques...');
    }

    if (_errorMessage != null) {
      return ErrorState(
        message: _errorMessage!,
        onRetry: _loadNearbyMosques,
      );
    }

    return Consumer<MosqueProvider>(
      builder: (context, provider, child) {
        if (provider.nearbyMosques.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const EmptyState(
                  icon: Icons.location_off,
                  title: 'No Nearby Mosques',
                  message:
                      'No mosques found within 5km of your location.',
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _loadNearbyMosques,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try Again'),
                ),
              ],
            ),
          );
        }

        // Ensure we have valid user location before building list
        if (_userLat == null || _userLng == null) {
          return ErrorState(
            message: 'Unable to determine your location',
            onRetry: _loadNearbyMosques,
          );
        }

        return Column(
          children: [
            // Header with mosque count and "View All on Map" button
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Icon(Icons.mosque,
                          color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        '${provider.nearbyMosques.length} nearby mosques',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () => _openAllMosquesInMap(provider.nearbyMosques),
                    icon: const Icon(Icons.map),
                    label: const Text('View All on Map'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
            // Mosque list
            Expanded(
              child: ListView.builder(
                itemCount: provider.nearbyMosques.length,
                itemBuilder: (context, index) {
                  final mosque = provider.nearbyMosques[index];
                  final distance = _locationService.calculateDistance(
                    _userLat!,
                    _userLng!,
                    mosque.latitude,
                    mosque.longitude,
                  );

                  return Card(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                            Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        child: Icon(
                          Icons.mosque,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      title: Text(
                        mosque.name,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            mosque.address,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.directions_walk,
                                size: 14,
                                color: Colors.green,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${distance.toStringAsFixed(2)} km away',
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.directions, color: Colors.blue),
                        onPressed: () async {
                          try {
                            await _locationService.openNavigation(
                              mosque.latitude,
                              mosque.longitude,
                            );
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(e.toString())),
                              );
                            }
                          }
                        },
                        tooltip: 'Navigate',
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                PrayerTimeScreen(mosque: mosque),
                          ),
                        );
                      },
                    ),
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
