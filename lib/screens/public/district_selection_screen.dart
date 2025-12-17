import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/district_provider.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/empty_state.dart';
import 'area_selection_screen.dart';

/// Screen for selecting a district in Bangladesh
class DistrictSelectionScreen extends StatefulWidget {
  const DistrictSelectionScreen({Key? key}) : super(key: key);

  @override
  State<DistrictSelectionScreen> createState() =>
      _DistrictSelectionScreenState();
}

class _DistrictSelectionScreenState extends State<DistrictSelectionScreen> {
  @override
  void initState() {
    super.initState();
    // Load districts on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DistrictProvider>().loadDistricts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DistrictProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const LoadingIndicator(message: 'Loading districts...');
        }

        if (provider.errorMessage != null) {
          return ErrorState(
            message: provider.errorMessage!,
            onRetry: () => provider.loadDistricts(),
          );
        }

        if (provider.districts.isEmpty) {
          return const EmptyState(
            icon: Icons.location_city,
            title: 'No Districts Available',
            message:
                'No districts have been loaded yet. Please contact the administrator.',
          );
        }

        // Group districts by division
        final districtsByDivision = provider.getDistrictsByDivision();
        final divisions = districtsByDivision.keys.toList()..sort();

        return ListView.builder(
          itemCount: divisions.length,
          itemBuilder: (context, index) {
            final division = divisions[index];
            final districts = districtsByDivision[division]!;

            return ExpansionTile(
              title: Text(
                '$division Division',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: Text('${districts.length} districts'),
              initiallyExpanded: index == 0, // Expand first division
              children: districts.map((district) {
                return ListTile(
                  leading: const Icon(Icons.location_on, color: Colors.green),
                  title: Text(district.name),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    provider.selectDistrict(district.id);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            AreaSelectionScreen(district: district),
                      ),
                    );
                  },
                );
              }).toList(),
            );
          },
        );
      },
    );
  }
}

