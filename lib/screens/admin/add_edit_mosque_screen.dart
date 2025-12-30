import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/mosque.dart';
import '../../providers/mosque_provider.dart';
import '../../providers/district_provider.dart';
import '../../services/location_service.dart';
import '../../widgets/loading_indicator.dart';

/// Screen for adding or editing a mosque
class AddEditMosqueScreen extends StatefulWidget {
  final Mosque? mosque;

  const AddEditMosqueScreen({super.key, this.mosque});

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
  
  // Location selection state
  bool _isLocationAutoMode = false;
  bool _isCoordinatesAutoMode = false;
  String? _selectedDivision;
  String? _selectedDistrictId;
  bool _isDetectingLocation = false;
  bool _isDetectingCoordinates = false;
  
  // Services
  final LocationService _locationService = LocationService();
  
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

    // Load districts and areas
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final districtProvider = context.read<DistrictProvider>();
      final mosqueProvider = context.read<MosqueProvider>();
      districtProvider.loadDistricts();
      mosqueProvider.loadAreas();
      
      // If editing, load existing location hierarchy
      if (widget.mosque?.areaId != null) {
        _loadExistingLocation(widget.mosque!.areaId);
      }
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
          builder: (context, mosqueProvider, child) {
            return Consumer<DistrictProvider>(
              builder: (context, districtProvider, child) {
                if ((mosqueProvider.isLoading && mosqueProvider.areas.isEmpty) ||
                    (districtProvider.isLoading && districtProvider.districts.isEmpty)) {
                  return const LoadingIndicator(message: 'Loading location data...');
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
                  // Location selection section
                  Text(
                    'Location',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  // Location toggle
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Use Current Location',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      Switch(
                        value: _isLocationAutoMode,
                        onChanged: _isDetectingLocation ? null : _onLocationToggleChanged,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Location selection UI
                  if (_isLocationAutoMode) ...[
                    // Automatic mode - show detected location or loading
                    if (_isDetectingLocation) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const SmallLoadingIndicator(),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                'Detecting location...',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else if (_selectedDivision != null && _selectedDistrictId != null && _selectedAreaId != null) ...[
                      // Show detected location (read-only)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green.withOpacity(0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.check_circle, color: Colors.green, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'Location Detected',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green,
                                      ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text('Division: $_selectedDivision'),
                            const SizedBox(height: 4),
                            Text('District: ${districtProvider.getSelectedDistrict()?.name ?? "Unknown"}'),
                            const SizedBox(height: 4),
                            Text('Area: ${districtProvider.getSelectedArea()?.name ?? "Unknown"}'),
                          ],
                        ),
                      ),
                    ],
                  ] else ...[
                    // Manual mode - hierarchical dropdowns
                    // Division dropdown
                    DropdownButtonFormField<String>(
                      initialValue: _selectedDivision,
                      decoration: const InputDecoration(
                        labelText: 'Division *',
                        prefixIcon: Icon(Icons.map),
                      ),
                      items: districtProvider.getDistrictsByDivision().keys.map((division) {
                        return DropdownMenuItem(
                          value: division,
                          child: Text(division),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedDivision = value;
                          _selectedDistrictId = null;
                          _selectedAreaId = null;
                        });
                        if (value != null) {
                          // Load districts for selected division
                          final districts = districtProvider.getDistrictsByDivision()[value] ?? [];
                          if (districts.isNotEmpty) {
                            // Auto-select first district if only one
                            if (districts.length == 1) {
                              districtProvider.selectDistrict(districts.first.id);
                              setState(() {
                                _selectedDistrictId = districts.first.id;
                              });
                            }
                          }
                        }
                      },
                      validator: (value) {
                        if (!_isLocationAutoMode && (value == null || value.isEmpty)) {
                          return 'Please select a division';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // District dropdown
                    if (_selectedDivision != null) ...[
                      DropdownButtonFormField<String>(
                        initialValue: _selectedDistrictId,
                        decoration: const InputDecoration(
                          labelText: 'District *',
                          prefixIcon: Icon(Icons.location_city),
                        ),
                        items: (districtProvider.getDistrictsByDivision()[_selectedDivision] ?? [])
                            .map((district) {
                          return DropdownMenuItem(
                            value: district.id,
                            child: Text(district.name),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedDistrictId = value;
                            _selectedAreaId = null;
                          });
                          if (value != null) {
                            districtProvider.selectDistrict(value);
                          }
                        },
                        validator: (value) {
                          if (!_isLocationAutoMode && (value == null || value.isEmpty)) {
                            return 'Please select a district';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                    // Area dropdown
                    if (_selectedDistrictId != null) ...[
                      DropdownButtonFormField<String>(
                        initialValue: _selectedAreaId,
                        decoration: const InputDecoration(
                          labelText: 'Area *',
                          prefixIcon: Icon(Icons.place),
                        ),
                        items: districtProvider.areasByDistrict.map((area) {
                          return DropdownMenuItem(
                            value: area.id,
                            child: Text(area.name),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedAreaId = value;
                          });
                          if (value != null) {
                            districtProvider.selectArea(value);
                          }
                        },
                        validator: (value) {
                          if (!_isLocationAutoMode && (value == null || value.isEmpty)) {
                            return 'Please select an area';
                          }
                          return null;
                        },
                      ),
                    ],
                  ],
                  const SizedBox(height: 24),
                  // Coordinates section
                  Text(
                    'Location Coordinates',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  // Coordinates toggle
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Use Current GPS Coordinates',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      Switch(
                        value: _isCoordinatesAutoMode,
                        onChanged: _isDetectingCoordinates ? null : _onCoordinatesToggleChanged,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isCoordinatesAutoMode
                        ? 'Coordinates will be detected automatically'
                        : 'Enter the GPS coordinates of the mosque',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 16),
                  // Coordinates detection status
                  if (_isCoordinatesAutoMode && _isDetectingCoordinates) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const SmallLoadingIndicator(),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              'Detecting coordinates...',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ] else if (_isCoordinatesAutoMode && 
                             _latitudeController.text.isNotEmpty && 
                             _longitudeController.text.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Coordinates detected',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  // Latitude
                  TextFormField(
                    controller: _latitudeController,
                    decoration: const InputDecoration(
                      labelText: 'Latitude *',
                      prefixIcon: Icon(Icons.gps_fixed),
                      hintText: 'e.g., 23.8103',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                      signed: true,
                    ),
                    readOnly: _isCoordinatesAutoMode && !_isDetectingCoordinates,
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
                      hintText: 'e.g., 90.4125',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                      signed: true,
                    ),
                    readOnly: _isCoordinatesAutoMode && !_isDetectingCoordinates,
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
            );
          },
        ),
      ),
    );
  }

  /// Load existing location hierarchy from areaId (for edit mode)
  Future<void> _loadExistingLocation(String areaId) async {
    final districtProvider = context.read<DistrictProvider>();
    final success = await districtProvider.autoSelectLocationFromArea(areaId);
    if (success && mounted) {
      final district = districtProvider.getSelectedDistrict();
      final area = districtProvider.getSelectedArea();
      if (district != null && area != null) {
        setState(() {
          _selectedDivision = district.divisionName;
          _selectedDistrictId = district.id;
          _selectedAreaId = area.id;
        });
      }
    }
  }

  /// Detect location automatically from GPS
  Future<void> _detectLocationAutomatically() async {
    if (!mounted) return;

    setState(() {
      _isDetectingLocation = true;
    });

    try {
      // Check if location services are enabled
      final isLocationEnabled = await _locationService.isLocationServiceEnabled();
      if (!isLocationEnabled) {
        if (mounted) {
          setState(() {
            _isLocationAutoMode = false;
            _isDetectingLocation = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location services are disabled. Please enable them in settings.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      // Find nearest mosque
      final nearestMosque = await _locationService.findNearestMosque();
      
      if (nearestMosque == null) {
        if (mounted) {
          setState(() {
            _isLocationAutoMode = false;
            _isDetectingLocation = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No nearby mosques found. Please select location manually.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      // Auto-select location based on area
      final districtProvider = context.read<DistrictProvider>();
      final success = await districtProvider.autoSelectLocationFromArea(nearestMosque.areaId);

      if (success && mounted) {
        final district = districtProvider.getSelectedDistrict();
        final area = districtProvider.getSelectedArea();
        if (district != null && area != null) {
          setState(() {
            _selectedDivision = district.divisionName;
            _selectedDistrictId = district.id;
            _selectedAreaId = area.id;
            _isDetectingLocation = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Location detected: ${area.name}'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        } else {
          throw 'Failed to get location details';
        }
      } else {
        throw districtProvider.errorMessage ?? 'Failed to detect location';
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLocationAutoMode = false;
          _isDetectingLocation = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to detect location: $e. Please select manually.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Detect coordinates automatically from GPS
  Future<void> _detectCoordinatesAutomatically() async {
    if (!mounted) return;

    setState(() {
      _isDetectingCoordinates = true;
    });

    try {
      // Check if location services are enabled
      final isLocationEnabled = await _locationService.isLocationServiceEnabled();
      if (!isLocationEnabled) {
        if (mounted) {
          setState(() {
            _isCoordinatesAutoMode = false;
            _isDetectingCoordinates = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location services are disabled. Please enable them in settings.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      // Get current position
      final position = await _locationService.getCurrentPosition();

      if (mounted) {
        setState(() {
          _latitudeController.text = position.latitude.toStringAsFixed(6);
          _longitudeController.text = position.longitude.toStringAsFixed(6);
          _isDetectingCoordinates = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Coordinates detected: ${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isCoordinatesAutoMode = false;
          _isDetectingCoordinates = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to detect coordinates: $e. Please enter manually.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Handle location toggle change
  void _onLocationToggleChanged(bool value) {
    setState(() {
      _isLocationAutoMode = value;
      if (value) {
        // Auto-detect immediately when toggled on
        _detectLocationAutomatically();
      } else {
        // Clear selections when switching to manual
        _selectedDivision = null;
        _selectedDistrictId = null;
        _selectedAreaId = null;
      }
    });
  }

  /// Handle coordinates toggle change
  void _onCoordinatesToggleChanged(bool value) {
    setState(() {
      _isCoordinatesAutoMode = value;
      if (value) {
        // Auto-detect immediately when toggled on
        _detectCoordinatesAutomatically();
      }
    });
  }

  Future<void> _submit() async {
    // Additional validation for automatic modes
    if (_isLocationAutoMode && _selectedAreaId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please wait for location detection to complete or switch to manual mode.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (!_isLocationAutoMode && (_selectedDivision == null || _selectedDistrictId == null || _selectedAreaId == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select division, district, and area.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_isCoordinatesAutoMode && (_latitudeController.text.isEmpty || _longitudeController.text.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please wait for coordinates detection to complete or switch to manual mode.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final provider = context.read<MosqueProvider>();
    final mosque = Mosque(
      id: widget.mosque?.id ?? '',
      name: _nameController.text.trim(),
      address: _addressController.text.trim(),
      areaId: _selectedAreaId ?? '',
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

