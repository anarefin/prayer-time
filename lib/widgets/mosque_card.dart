import 'package:flutter/material.dart';
import '../models/mosque.dart';

/// Reusable card widget for displaying mosque information
class MosqueCard extends StatelessWidget {
  final Mosque mosque;
  final VoidCallback? onTap;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;
  final bool showFavoriteButton;
  final bool showFacilities;

  const MosqueCard({
    Key? key,
    required this.mosque,
    this.onTap,
    this.isFavorite = false,
    this.onFavoriteToggle,
    this.showFavoriteButton = true,
    this.showFacilities = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Mosque icon
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Icon(
                  Icons.mosque,
                  color: Theme.of(context).colorScheme.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              // Mosque details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mosque.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 16,
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            mosque.address,
                            style: Theme.of(context).textTheme.bodySmall,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (showFacilities) ...[
                      const SizedBox(height: 8),
                      _buildFacilitiesRow(),
                    ],
                  ],
                ),
              ),
              // Favorite button
              if (showFavoriteButton && onFavoriteToggle != null)
                IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite
                        ? Colors.red
                        : Theme.of(context).iconTheme.color,
                  ),
                  onPressed: onFavoriteToggle,
                  tooltip: isFavorite ? 'Remove from favorites' : 'Add to favorites',
                ),
              // Arrow icon if tappable
              if (onTap != null && !showFavoriteButton)
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Theme.of(context).iconTheme.color?.withOpacity(0.5),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFacilitiesRow() {
    final facilities = <Map<String, dynamic>>[];
    
    if (mosque.hasWomenPrayer) {
      facilities.add({
        'icon': Icons.woman,
        'color': Colors.purple,
        'label': 'Women',
      });
    }
    if (mosque.hasCarParking) {
      facilities.add({
        'icon': Icons.local_parking,
        'color': Colors.blue,
        'label': 'Car',
      });
    }
    if (mosque.hasBikeParking) {
      facilities.add({
        'icon': Icons.two_wheeler,
        'color': Colors.orange,
        'label': 'Bike',
      });
    }
    if (mosque.hasCycleParking) {
      facilities.add({
        'icon': Icons.pedal_bike,
        'color': Colors.green,
        'label': 'Cycle',
      });
    }
    if (mosque.hasWudu) {
      facilities.add({
        'icon': Icons.water_drop,
        'color': Colors.lightBlue,
        'label': 'Wudu',
      });
    }
    if (mosque.hasAC) {
      facilities.add({
        'icon': Icons.ac_unit,
        'color': Colors.cyan,
        'label': 'AC',
      });
    }
    if (mosque.isWheelchairAccessible) {
      facilities.add({
        'icon': Icons.accessible,
        'color': Colors.teal,
        'label': 'Wheelchair',
      });
    }

    if (facilities.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: facilities.map((facility) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          decoration: BoxDecoration(
            color: (facility['color'] as Color).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: (facility['color'] as Color).withOpacity(0.3),
              width: 0.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                facility['icon'] as IconData,
                size: 12,
                color: facility['color'] as Color,
              ),
              const SizedBox(width: 4),
              Text(
                facility['label'] as String,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: facility['color'] as Color,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

