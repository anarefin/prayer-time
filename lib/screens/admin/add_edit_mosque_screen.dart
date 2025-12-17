import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/mosque.dart';
import '../../models/area.dart';
import '../../providers/mosque_provider.dart';
import '../../widgets/loading_indicator.dart';

/// Screen for adding or editing a mosque
class AddEditMosqueScreen extends StatefulWidget {
  final Mosque? mosque;

  const AddEditMosqueScreen({Key? key, this.mosque}) : super(key: key);

  @override
  State<AddEditMosqueScreen> createState() => _AddEditMosqueScreenState();
}

class _AddEditMosqueScreenState extends State<AddEditMosqueScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _addressController;
  late final TextEditingController _latitudeController;
  late final TextEditingController _longitudeController;
  String? _selectedAreaId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.mosque?.name ?? '');
    _addressController =
        TextEditingController(text: widget.mosque?.address ?? '');
    _latitudeController = TextEditingController(
      text: widget.mosque?.latitude.toString() ?? '',
    );
    _longitudeController = TextEditingController(
      text: widget.mosque?.longitude.toString() ?? '',
    );
    _selectedAreaId = widget.mosque?.areaId;

    // Load areas
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MosqueProvider>().loadAreas();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.mosque != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Mosque' : 'Add Mosque'),
        backgroundColor: const Color(0xFF1565C0),
      ),
      body: Consumer<MosqueProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.areas.isEmpty) {
            return const LoadingIndicator(message: 'Loading areas...');
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Mosque name
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Mosque Name *',
                      prefixIcon: Icon(Icons.mosque),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter mosque name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // Address
                  TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(
                      labelText: 'Address *',
                      prefixIcon: Icon(Icons.location_on),
                    ),
                    maxLines: 2,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // Area dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedAreaId,
                    decoration: const InputDecoration(
                      labelText: 'Area *',
                      prefixIcon: Icon(Icons.location_city),
                    ),
                    items: provider.areas.map((area) {
                      return DropdownMenuItem(
                        value: area.id,
                        child: Text(area.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedAreaId = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select an area';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  // Coordinates section
                  Text(
                    'Location Coordinates',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Enter the GPS coordinates of the mosque',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 16),
                  // Latitude
                  TextFormField(
                    controller: _latitudeController,
                    decoration: const InputDecoration(
                      labelText: 'Latitude *',
                      prefixIcon: Icon(Icons.gps_fixed),
                      hintText: 'e.g., 3.140853',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                      signed: true,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter latitude';
                      }
                      final lat = double.tryParse(value);
                      if (lat == null) {
                        return 'Please enter a valid number';
                      }
                      if (lat < -90 || lat > 90) {
                        return 'Latitude must be between -90 and 90';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // Longitude
                  TextFormField(
                    controller: _longitudeController,
                    decoration: const InputDecoration(
                      labelText: 'Longitude *',
                      prefixIcon: Icon(Icons.gps_fixed),
                      hintText: 'e.g., 101.693207',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                      signed: true,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter longitude';
                      }
                      final lng = double.tryParse(value);
                      if (lng == null) {
                        return 'Please enter a valid number';
                      }
                      if (lng < -180 || lng > 180) {
                        return 'Longitude must be between -180 and 180';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  // Help text
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.info_outline,
                            color: Colors.blue, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Tip: You can get coordinates from Google Maps by right-clicking on a location',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Submit button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1565C0),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isLoading
                        ? const SmallLoadingIndicator(color: Colors.white)
                        : Text(
                            isEdit ? 'Update Mosque' : 'Add Mosque',
                            style: const TextStyle(fontSize: 16),
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final provider = context.read<MosqueProvider>();
    final mosque = Mosque(
      id: widget.mosque?.id ?? '',
      name: _nameController.text.trim(),
      address: _addressController.text.trim(),
      areaId: _selectedAreaId!,
      latitude: double.parse(_latitudeController.text),
      longitude: double.parse(_longitudeController.text),
    );

    final bool success;
    if (widget.mosque != null) {
      success = await provider.updateMosque(mosque);
    } else {
      success = await provider.addMosque(mosque);
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
              widget.mosque != null
                  ? 'Mosque updated successfully'
                  : 'Mosque added successfully',
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

