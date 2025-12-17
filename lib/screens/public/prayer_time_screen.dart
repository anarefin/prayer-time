import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/mosque.dart';
import '../../providers/prayer_time_provider.dart';
import '../../services/location_service.dart';
import '../../widgets/prayer_time_card.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/facility_icon.dart';

/// Screen displaying prayer times for a specific mosque
class PrayerTimeScreen extends StatefulWidget {
  final Mosque mosque;

  const PrayerTimeScreen({
    Key? key,
    required this.mosque,
  }) : super(key: key);

  @override
  State<PrayerTimeScreen> createState() => _PrayerTimeScreenState();
}

class _PrayerTimeScreenState extends State<PrayerTimeScreen> {
  DateTime _selectedDate = DateTime.now();
  final LocationService _locationService = LocationService();

  @override
  void initState() {
    super.initState();
    // Load prayer times for today
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PrayerTimeProvider>().loadPrayerTime(
            widget.mosque.id,
            _selectedDate,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.mosque.name),
        actions: [
          // Notification toggle
          Consumer<PrayerTimeProvider>(
            builder: (context, provider, _) {
              if (provider.currentPrayerTime == null) return const SizedBox();
              
              return IconButton(
                icon: Icon(
                  provider.notificationsEnabled
                      ? Icons.notifications_active
                      : Icons.notifications_none,
                ),
                onPressed: () async {
                  if (provider.notificationsEnabled) {
                    await provider.disableNotifications();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Notifications disabled'),
                        ),
                      );
                    }
                  } else {
                    final success = await provider.enableNotifications();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            success
                                ? 'Notifications enabled'
                                : 'Failed to enable notifications',
                          ),
                        ),
                      );
                    }
                  }
                },
                tooltip: provider.notificationsEnabled
                    ? 'Disable notifications'
                    : 'Enable notifications',
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Mosque info card
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.mosque,
                        color: Theme.of(context).colorScheme.primary,
                        size: 32,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.mosque.name,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          widget.mosque.address,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Facilities section
                  _buildFacilitiesSection(context),
                  const SizedBox(height: 16),
                  // Google Maps button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        try {
                          await _locationService.openNavigation(
                            widget.mosque.latitude,
                            widget.mosque.longitude,
                          );
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(e.toString()),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.map),
                      label: const Text('Open in Maps'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Date selector
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Selected Date',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('EEEE, MMMM d, yyyy').format(_selectedDate),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () => _selectDate(context),
                    tooltip: 'Change date',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Prayer times list
          Expanded(
            child: Consumer<PrayerTimeProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const LoadingIndicator(message: 'Loading prayer times...');
                }

                if (provider.errorMessage != null) {
                  return ErrorState(
                    message: provider.errorMessage!,
                    onRetry: () => provider.loadPrayerTime(
                      widget.mosque.id,
                      _selectedDate,
                    ),
                  );
                }

                if (provider.currentPrayerTime == null) {
                  return const EmptyState(
                    icon: Icons.access_time,
                    title: 'No Prayer Times',
                    message:
                        'Prayer times have not been set for this date yet.',
                  );
                }

                final prayerTime = provider.currentPrayerTime!;
                final nextPrayer = prayerTime.getNextPrayer();
                final prayers = prayerTime.getPrayersForDisplay();

                return Column(
                  children: [
                    // Show Jummah notice if it's Friday
                    if (prayerTime.isFriday() && prayerTime.jummah != null)
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green, width: 2),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.mosque, color: Colors.green, size: 28),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Jummah Prayer (Friday)',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.green.shade800,
                                    ),
                                  ),
                                  Text(
                                    'Special congregational prayer',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.green.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.only(bottom: 16),
                        children: prayers.entries.map((entry) {
                          final isNext = entry.key == nextPrayer;
                          return PrayerTimeCard(
                            prayerName: entry.key,
                            prayerTime: entry.value,
                            isNext: isNext,
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFacilitiesSection(BuildContext context) {
    final facilities = <Map<String, dynamic>>[];
    
    // Build list of available facilities with their metadata
    if (widget.mosque.hasWomenPrayer) {
      facilities.add({
        'key': 'hasWomenPrayer',
        'icon': FacilityIconData.getIcon('hasWomenPrayer'),
        'label': FacilityIconData.getLabel('hasWomenPrayer'),
        'color': FacilityIconData.getColor('hasWomenPrayer'),
      });
    }
    if (widget.mosque.hasCarParking) {
      facilities.add({
        'key': 'hasCarParking',
        'icon': FacilityIconData.getIcon('hasCarParking'),
        'label': FacilityIconData.getLabel('hasCarParking'),
        'color': FacilityIconData.getColor('hasCarParking'),
      });
    }
    if (widget.mosque.hasBikeParking) {
      facilities.add({
        'key': 'hasBikeParking',
        'icon': FacilityIconData.getIcon('hasBikeParking'),
        'label': FacilityIconData.getLabel('hasBikeParking'),
        'color': FacilityIconData.getColor('hasBikeParking'),
      });
    }
    if (widget.mosque.hasCycleParking) {
      facilities.add({
        'key': 'hasCycleParking',
        'icon': FacilityIconData.getIcon('hasCycleParking'),
        'label': FacilityIconData.getLabel('hasCycleParking'),
        'color': FacilityIconData.getColor('hasCycleParking'),
      });
    }
    if (widget.mosque.hasWudu) {
      facilities.add({
        'key': 'hasWudu',
        'icon': FacilityIconData.getIcon('hasWudu'),
        'label': FacilityIconData.getLabel('hasWudu'),
        'color': FacilityIconData.getColor('hasWudu'),
      });
    }
    if (widget.mosque.hasAC) {
      facilities.add({
        'key': 'hasAC',
        'icon': FacilityIconData.getIcon('hasAC'),
        'label': FacilityIconData.getLabel('hasAC'),
        'color': FacilityIconData.getColor('hasAC'),
      });
    }
    if (widget.mosque.isWheelchairAccessible) {
      facilities.add({
        'key': 'isWheelchairAccessible',
        'icon': FacilityIconData.getIcon('isWheelchairAccessible'),
        'label': FacilityIconData.getLabel('isWheelchairAccessible'),
        'color': FacilityIconData.getColor('isWheelchairAccessible'),
      });
    }

    if (facilities.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Facilities',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Theme.of(context).textTheme.bodySmall?.color,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: facilities.map((facility) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: (facility['color'] as Color).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: (facility['color'] as Color).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    facility['icon'] as IconData,
                    size: 16,
                    color: facility['color'] as Color,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    facility['label'] as String,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      if (mounted) {
        context.read<PrayerTimeProvider>().loadPrayerTime(
              widget.mosque.id,
              picked,
            );
      }
    }
  }
}

