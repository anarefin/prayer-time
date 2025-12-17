import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/mosque.dart';
import '../../providers/prayer_time_provider.dart';
import '../../widgets/prayer_time_card.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/empty_state.dart';

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
                final prayers = prayerTime.getAllPrayers();

                return ListView(
                  padding: const EdgeInsets.only(bottom: 16),
                  children: prayers.entries.map((entry) {
                    final isNext = entry.key == nextPrayer;
                    return PrayerTimeCard(
                      prayerName: entry.key,
                      prayerTime: entry.value,
                      isNext: isNext,
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
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

