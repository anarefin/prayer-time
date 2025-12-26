import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/area.dart';
import '../../providers/mosque_provider.dart';
import '../../providers/district_provider.dart';
import '../../widgets/area_tile.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/empty_state.dart';

/// Screen for managing areas (CRUD operations)
class ManageAreasScreen extends StatefulWidget {
  const ManageAreasScreen({super.key});

  @override
  State<ManageAreasScreen> createState() => _ManageAreasScreenState();
}

class _ManageAreasScreenState extends State<ManageAreasScreen> {
  @override
  void initState() {
    super.initState();
    _loadAreas();
  }

  void _loadAreas() {
    context.read<MosqueProvider>().loadAreas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Areas'),
        backgroundColor: const Color(0xFF1565C0),
      ),
      body: SafeArea(
        child: Consumer<MosqueProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const LoadingIndicator(message: 'Loading areas...');
          }

          if (provider.errorMessage != null) {
            return ErrorState(
              message: provider.errorMessage!,
              onRetry: _loadAreas,
            );
          }

          if (provider.areas.isEmpty) {
            return EmptyState(
              icon: Icons.location_city,
              title: 'No Areas',
              message: 'Add your first area to get started',
              actionLabel: 'Add Area',
              onAction: () => _showAddEditDialog(context),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: provider.areas.length,
                  itemBuilder: (context, index) {
                    final area = provider.areas[index];
                    return AreaTile(
                      area: area,
                      showActions: true,
                      onEdit: () => _showAddEditDialog(context, area: area),
                      onDelete: () => _confirmDelete(context, area),
                    );
                  },
                ),
              ),
            ],
          );
        },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Area'),
        backgroundColor: const Color(0xFF1565C0),
      ),
    );
  }

  void _showAddEditDialog(BuildContext context, {Area? area}) {
    showDialog(
      context: context,
      builder: (context) => _AddEditAreaDialog(area: area),
    );
  }

  Future<void> _confirmDelete(BuildContext context, Area area) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Area'),
        content: Text(
          'Are you sure you want to delete "${area.name}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final provider = context.read<MosqueProvider>();
      final success = await provider.deleteArea(area.id);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Area deleted successfully'
                  : provider.errorMessage ?? 'Failed to delete area',
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }
}

/// Dialog for adding/editing areas
class _AddEditAreaDialog extends StatefulWidget {
  final Area? area;

  const _AddEditAreaDialog({super.key, this.area});

  @override
  State<_AddEditAreaDialog> createState() => _AddEditAreaDialogState();
}

class _AddEditAreaDialogState extends State<_AddEditAreaDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _orderController;
  String? _selectedDistrictId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.area?.name ?? '');
    _orderController = TextEditingController(
      text: widget.area?.order.toString() ?? '0',
    );
    _selectedDistrictId = widget.area?.districtId;
    
    // Load districts if not already loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DistrictProvider>().loadDistricts();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _orderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.area != null;

    return Consumer<DistrictProvider>(
      builder: (context, districtProvider, child) {
        return AlertDialog(
          title: Text(isEdit ? 'Edit Area' : 'Add Area'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // District dropdown
                  DropdownButtonFormField<String>(
                    initialValue: _selectedDistrictId,
                    decoration: const InputDecoration(
                      labelText: 'District',
                      prefixIcon: Icon(Icons.map),
                    ),
                    items: districtProvider.districts.map((district) {
                      return DropdownMenuItem(
                        value: district.id,
                        child: Text(district.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedDistrictId = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a district';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Area Name',
                      prefixIcon: Icon(Icons.location_city),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter area name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _orderController,
                    decoration: const InputDecoration(
                      labelText: 'Display Order',
                      prefixIcon: Icon(Icons.sort),
                      helperText: 'Lower numbers appear first',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter display order';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: _isLoading ? null : () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: _isLoading ? null : _submit,
              child: _isLoading
                  ? const SmallLoadingIndicator()
                  : Text(isEdit ? 'Update' : 'Add'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final provider = context.read<MosqueProvider>();
    final area = Area(
      id: widget.area?.id ?? '',
      name: _nameController.text.trim(),
      districtId: _selectedDistrictId ?? '',
      order: int.parse(_orderController.text),
    );

    final bool success;
    if (widget.area != null) {
      success = await provider.updateArea(area);
    } else {
      success = await provider.addArea(area);
    }

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.area != null
                  ? 'Area updated successfully'
                  : 'Area added successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage ?? 'Operation failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

