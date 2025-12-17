import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/district.dart';
import '../../providers/district_provider.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/area_tile.dart';
import 'mosque_list_screen.dart';

/// Screen for selecting an area within a district
class AreaSelectionScreen extends StatefulWidget {
  final District district;

  const AreaSelectionScreen({
    Key? key,
    required this.district,
  }) : super(key: key);

  @override
  State<AreaSelectionScreen> createState() => _AreaSelectionScreenState();
}

class _AreaSelectionScreenState extends State<AreaSelectionScreen> {
  @override
  void initState() {
    super.initState();
    // Load areas for this district
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DistrictProvider>().loadAreasByDistrict(widget.district.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.district.name),
            Text(
              '${widget.district.divisionName} Division',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
      body: Consumer<DistrictProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const LoadingIndicator(message: 'Loading areas...');
          }

          if (provider.errorMessage != null) {
            return ErrorState(
              message: provider.errorMessage!,
              onRetry: () =>
                  provider.loadAreasByDistrict(widget.district.id),
            );
          }

          if (provider.areasByDistrict.isEmpty) {
            return const EmptyState(
              icon: Icons.location_city,
              title: 'No Areas Available',
              message:
                  'No areas have been added for this district yet. Please contact the administrator.',
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select Your Area',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Choose an area to view mosques and prayer times',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: provider.areasByDistrict.length,
                  itemBuilder: (context, index) {
                    final area = provider.areasByDistrict[index];
                    return AreaTile(
                      area: area,
                      onTap: () {
                        provider.selectArea(area.id);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MosqueListScreen(area: area),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

