import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Reusable card widget for displaying individual prayer time
class PrayerTimeCard extends StatelessWidget {
  final String prayerName;
  final DateTime prayerTime;
  final bool isNext;

  const PrayerTimeCard({
    super.key,
    required this.prayerName,
    required this.prayerTime,
    this.isNext = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      color: isNext
          ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
          : null,
      elevation: isNext ? 4 : 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            // Prayer icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isNext
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                _getPrayerIcon(prayerName),
                color: isNext
                    ? Colors.white
                    : Theme.of(context).colorScheme.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 16),
            // Prayer name
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    prayerName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: isNext ? FontWeight.bold : FontWeight.w600,
                        ),
                  ),
                  if (isNext)
                    Text(
                      'Next Prayer',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                ],
              ),
            ),
            // Prayer time
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  DateFormat('h:mm a').format(prayerTime),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isNext
                            ? Theme.of(context).colorScheme.primary
                            : null,
                      ),
                ),
                if (isNext)
                  Text(
                    _getTimeUntil(prayerTime),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Get appropriate icon for each prayer
  IconData _getPrayerIcon(String prayer) {
    switch (prayer.toLowerCase()) {
      case 'fajr':
        return Icons.wb_twilight;
      case 'dhuhr':
        return Icons.wb_sunny;
      case 'jummah':
        return Icons.mosque;
      case 'asr':
        return Icons.light_mode;
      case 'maghrib':
        return Icons.nightlight;
      case 'isha':
        return Icons.nights_stay;
      default:
        return Icons.access_time;
    }
  }

  /// Get time until prayer
  String _getTimeUntil(DateTime prayerTime) {
    final now = DateTime.now();
    final difference = prayerTime.difference(now);

    if (difference.isNegative) return 'Now';

    final hours = difference.inHours;
    final minutes = difference.inMinutes % 60;

    if (hours > 0) {
      return 'in ${hours}h ${minutes}m';
    } else {
      return 'in ${minutes}m';
    }
  }
}

