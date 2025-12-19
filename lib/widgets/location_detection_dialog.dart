import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

/// A beautiful loading dialog shown during location detection
class LocationDetectionDialog extends StatelessWidget {
  const LocationDetectionDialog({super.key});

  /// Show the location detection dialog
  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) => const LocationDetectionDialog(),
    );
  }

  /// Dismiss the dialog
  static void dismiss(BuildContext context, {bool cancelled = false}) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context, cancelled);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animated location icon
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.location_searching,
                size: 48,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            
            // Loading indicator
            SizedBox(
              height: 4,
              width: 200,
              child: LinearProgressIndicator(
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Message
            Text(
              'Detecting your location...',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Please wait while we find your area',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            
            // Cancel button
            TextButton(
              onPressed: () {
                Navigator.pop(context, true); // true = cancelled
              },
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Dialog shown when location services are disabled
class LocationDisabledDialog extends StatelessWidget {
  const LocationDisabledDialog({super.key});

  /// Show the location disabled dialog
  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) => const LocationDisabledDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: const Row(
        children: [
          Icon(
            Icons.location_off,
            color: Colors.orange,
            size: 28,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text('Location Services Disabled'),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'To automatically detect your area, please enable location services.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          Text(
            'You can also select your location manually if you prefer.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context, false); // User chose to select manually
          },
          child: const Text('Select Manually'),
        ),
        ElevatedButton.icon(
          onPressed: () async {
            Navigator.pop(context, true); // User chose to enable location
            // Open app settings
            await openAppSettings();
          },
          icon: const Icon(Icons.settings),
          label: const Text('Enable Location'),
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }
}

