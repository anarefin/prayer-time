import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/district.dart';
import '../../providers/district_provider.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/empty_state.dart';

/// Admin screen for managing districts
class ManageDistrictsScreen extends StatefulWidget {
  const ManageDistrictsScreen({Key? key}) : super(key: key);

  @override
  State<ManageDistrictsScreen> createState() => _ManageDistrictsScreenState();
}

class _ManageDistrictsScreenState extends State<ManageDistrictsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DistrictProvider>().loadDistricts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Districts'),
      ),
      body: Consumer<DistrictProvider>(
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
              title: 'No Districts',
              message: 'No districts have been added yet.',
            );
          }

          final districtsByDivision = provider.getDistrictsByDivision();
          final divisions = districtsByDivision.keys.toList()..sort();

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: divisions.length,
            itemBuilder: (context, index) {
              final division = divisions[index];
              final districts = districtsByDivision[division]!;

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ExpansionTile(
                  title: Text(
                    '$division Division',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text('${districts.length} districts'),
                  children: districts.map((district) {
                    return ListTile(
                      leading: const Icon(Icons.location_on),
                      title: Text(district.name),
                      subtitle: Text('Order: ${district.order}'),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'edit') {
                            _showEditDialog(context, district);
                          } else if (value == 'delete') {
                            _showDeleteConfirmation(context, district);
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, size: 20),
                                SizedBox(width: 8),
                                Text('Edit'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, size: 20),
                                SizedBox(width: 8),
                                Text('Delete'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final nameController = TextEditingController();
    final divisionController = TextEditingController();
    final orderController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add District'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'District Name'),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Required' : null,
                ),
                TextFormField(
                  controller: divisionController,
                  decoration: const InputDecoration(labelText: 'Division Name'),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Required' : null,
                ),
                TextFormField(
                  controller: orderController,
                  decoration: const InputDecoration(labelText: 'Order'),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Required' : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final district = District(
                  id: '',
                  name: nameController.text,
                  divisionName: divisionController.text,
                  order: int.parse(orderController.text),
                );

                Navigator.pop(dialogContext);
                final success =
                    await context.read<DistrictProvider>().addDistrict(district);

                if (mounted && success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('District added successfully')),
                  );
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, District district) {
    final nameController = TextEditingController(text: district.name);
    final divisionController = TextEditingController(text: district.divisionName);
    final orderController = TextEditingController(text: district.order.toString());
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit District'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'District Name'),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Required' : null,
                ),
                TextFormField(
                  controller: divisionController,
                  decoration: const InputDecoration(labelText: 'Division Name'),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Required' : null,
                ),
                TextFormField(
                  controller: orderController,
                  decoration: const InputDecoration(labelText: 'Order'),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Required' : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final updatedDistrict = district.copyWith(
                  name: nameController.text,
                  divisionName: divisionController.text,
                  order: int.parse(orderController.text),
                );

                Navigator.pop(dialogContext);
                final success = await context
                    .read<DistrictProvider>()
                    .updateDistrict(updatedDistrict);

                if (mounted && success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('District updated successfully')),
                  );
                }
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, District district) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete District'),
        content: Text('Are you sure you want to delete ${district.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              final success = await context
                  .read<DistrictProvider>()
                  .deleteDistrict(district.id);

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'District deleted successfully'
                          : 'Failed to delete district',
                    ),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

