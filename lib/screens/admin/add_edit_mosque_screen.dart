import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/mosque.dart';
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
  late final TextEditingController _descriptionController;
  late final TextEditingController _latitudeController;
  late final TextEditingController _longitudeController;
  String? _selectedAreaId;
  bool _isLoading = false;
  
  // Facility flags
  bool _hasWomenPrayer = false;
  bool _hasCarParking = false;
  bool _hasBikeParking = false;
  bool _hasCycleParking = false;
  bool _hasWudu = true;
  bool _hasAC = false;
  bool _isWheelchairAccessible = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.mosque?.name ?? '');
    _addressController =
        TextEditingController(text: widget.mosque?.address ?? '');
    _descriptionController =
        TextEditingController(text: widget.mosque?.description ?? '');
    _latitudeController = TextEditingController(
      text: widget.mosque?.latitude.toString() ?? '',
    );
    _longitudeController = TextEditingController(
      text: widget.mosque?.longitude.toString() ?? '',
    );
    _selectedAreaId = widget.mosque?.areaId;
    
    // Initialize facility flags from mosque
    if (widget.mosque != null) {
      _hasWomenPrayer = widget.mosque!.hasWomenPrayer;
      _hasCarParking = widget.mosque!.hasCarParking;
      _hasBikeParking = widget.mosque!.hasBikeParking;
      _hasCycleParking = widget.mosque!.hasCycleParking;
      _hasWudu = widget.mosque!.hasWudu;
      _hasAC = widget.mosque!.hasAC;
      _isWheelchairAccessible = widget.mosque!.isWheelchairAccessible;
    }

    // Load areas
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MosqueProvider>().loadAreas();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();
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
      body: SafeArea(
        child: Consumer<MosqueProvider>(
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
                  // Description
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description (Optional)',
                      prefixIcon: Icon(Icons.description),
                    ),
                    maxLines: 3,
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
                  // Facilities section
                  Text(
                    'Facilities',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Select available facilities at this mosque',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 16),
                  CheckboxListTile(
                    title: const Text('Women Prayer Place'),
                    subtitle: const Text('Separate prayer area for women'),
                    secondary: const Icon(Icons.woman, color: Colors.purple),
                    value: _hasWomenPrayer,
                    onChanged: (value) {
                      setState(() {
                        _hasWomenPrayer = value ?? false;
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: const Text('Car Parking'),
                    subtitle: const Text('Parking available for cars'),
                    secondary: const Icon(Icons.local_parking, color: Colors.blue),
                    value: _hasCarParking,
                    onChanged: (value) {
                      setState(() {
                        _hasCarParking = value ?? false;
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: const Text('Motorbike Parking'),
                    subtitle: const Text('Parking available for motorbikes'),
                    secondary: const Icon(Icons.two_wheeler, color: Colors.orange),
                    value: _hasBikeParking,
                    onChanged: (value) {
                      setState(() {
                        _hasBikeParking = value ?? false;
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: const Text('Cycle Parking'),
                    subtitle: const Text('Parking available for bicycles'),
                    secondary: const Icon(Icons.pedal_bike, color: Colors.green),
                    value: _hasCycleParking,
                    onChanged: (value) {
                      setState(() {
                        _hasCycleParking = value ?? false;
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: const Text('Wudu Facilities'),
                    subtitle: const Text('Ablution facilities available'),
                    secondary: const Icon(Icons.water_drop, color: Colors.lightBlue),
                    value: _hasWudu,
                    onChanged: (value) {
                      setState(() {
                        _hasWudu = value ?? true;
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: const Text('Air Conditioning'),
                    subtitle: const Text('AC available in prayer hall'),
                    secondary: const Icon(Icons.ac_unit, color: Colors.cyan),
                    value: _hasAC,
                    onChanged: (value) {
                      setState(() {
                        _hasAC = value ?? false;
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: const Text('Wheelchair Accessible'),
                    subtitle: const Text('Accessible for wheelchair users'),
                    secondary: const Icon(Icons.accessible, color: Colors.teal),
                    value: _isWheelchairAccessible,
                    onChanged: (value) {
                      setState(() {
                        _isWheelchairAccessible = value ?? false;
                      });
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
      hasWomenPrayer: _hasWomenPrayer,
      hasCarParking: _hasCarParking,
      hasBikeParking: _hasBikeParking,
      hasCycleParking: _hasCycleParking,
      hasWudu: _hasWudu,
      hasAC: _hasAC,
      isWheelchairAccessible: _isWheelchairAccessible,
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
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

