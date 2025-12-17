import 'package:flutter/material.dart';

/// Widget to display a facility icon with label
class FacilityIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final bool isAvailable;

  const FacilityIcon({
    Key? key,
    required this.icon,
    required this.label,
    this.color,
    this.isAvailable = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: Chip(
        avatar: Icon(
          icon,
          size: 16,
          color: isAvailable
              ? (color ?? Colors.green)
              : Colors.grey,
        ),
        label: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isAvailable ? Colors.black87 : Colors.grey,
          ),
        ),
        backgroundColor: isAvailable
            ? (color?.withOpacity(0.1) ?? Colors.green.withOpacity(0.1))
            : Colors.grey.withOpacity(0.1),
      ),
    );
  }
}

/// Get facility icon data for a facility type
class FacilityIconData {
  static IconData getIcon(String facilityKey) {
    switch (facilityKey) {
      case 'hasWomenPrayer':
        return Icons.woman;
      case 'hasCarParking':
        return Icons.local_parking;
      case 'hasBikeParking':
        return Icons.two_wheeler;
      case 'hasCycleParking':
        return Icons.pedal_bike;
      case 'hasWudu':
        return Icons.water_drop;
      case 'hasAC':
        return Icons.ac_unit;
      case 'isWheelchairAccessible':
        return Icons.accessible;
      default:
        return Icons.check_circle;
    }
  }

  static String getLabel(String facilityKey) {
    switch (facilityKey) {
      case 'hasWomenPrayer':
        return 'Women Prayer';
      case 'hasCarParking':
        return 'Car Parking';
      case 'hasBikeParking':
        return 'Bike Parking';
      case 'hasCycleParking':
        return 'Cycle Parking';
      case 'hasWudu':
        return 'Wudu';
      case 'hasAC':
        return 'AC';
      case 'isWheelchairAccessible':
        return 'Wheelchair';
      default:
        return facilityKey;
    }
  }

  static Color getColor(String facilityKey) {
    switch (facilityKey) {
      case 'hasWomenPrayer':
        return Colors.purple;
      case 'hasCarParking':
        return Colors.blue;
      case 'hasBikeParking':
        return Colors.orange;
      case 'hasCycleParking':
        return Colors.green;
      case 'hasWudu':
        return Colors.lightBlue;
      case 'hasAC':
        return Colors.cyan;
      case 'isWheelchairAccessible':
        return Colors.teal;
      default:
        return Colors.green;
    }
  }
}

