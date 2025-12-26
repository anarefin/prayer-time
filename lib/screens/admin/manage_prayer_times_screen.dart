import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/mosque.dart';
import '../../models/district.dart';
import '../../models/area.dart';
import '../../models/prayer_time.dart';
import '../../providers/mosque_provider.dart';
import '../../providers/district_provider.dart';
import '../../providers/prayer_time_provider.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/empty_state.dart';

/// Screen for managing prayer times
class ManagePrayerTimesScreen extends StatefulWidget {
  const ManagePrayerTimesScreen({super.key});

  @override
  State<ManagePrayerTimesScreen> createState() =>
      _ManagePrayerTimesScreenState();
}

class _ManagePrayerTimesScreenState extends State<ManagePrayerTimesScreen> {
  String? _selectedDivision;
  District? _selectedDistrict;
  Area? _selectedArea;
  Mosque? _selectedMosque;
  DateTime _selectedDate = DateTime.now();
  List<Mosque> _filteredMosques = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DistrictProvider>().loadDistricts();
      context.read<MosqueProvider>().loadAllMosques();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Prayer Times'),
        backgroundColor: const Color(0xFF1565C0),
      ),
      body: SafeArea(
        child: Column(
        children: [
          // Hierarchical selector
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Select Mosque',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Choose division, district, area and mosque',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 16),
                  // Division dropdown
                  Consumer<DistrictProvider>(
                    builder: (context, districtProvider, child) {
                      if (districtProvider.isLoading) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: SmallLoadingIndicator(),
                          ),
                        );
                      }

                      final divisions = districtProvider
                          .getDistrictsByDivision()
                          .keys
                          .toList()
                        ..sort();

                      if (divisions.isEmpty) {
                        return const Text(
                          'No divisions available. Please add districts first.',
                          style: TextStyle(color: Colors.red),
                        );
                      }

                      return DropdownButtonFormField<String>(
                        initialValue: _selectedDivision,
                        decoration: const InputDecoration(
                          labelText: 'Division',
                          prefixIcon: Icon(Icons.map),
                        ),
                        items: divisions.map((division) {
                          return DropdownMenuItem(
                            value: division,
                            child: Text(division),
                          );
                        }).toList(),
                        onChanged: (division) {
                          setState(() {
                            _selectedDivision = division;
                            _selectedDistrict = null;
                            _selectedArea = null;
                            _selectedMosque = null;
                            _filteredMosques = [];
                          });
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  // District dropdown
                  if (_selectedDivision != null)
                    Consumer<DistrictProvider>(
                      builder: (context, districtProvider, child) {
                        final districtsByDivision =
                            districtProvider.getDistrictsByDivision();
                        final districts =
                            districtsByDivision[_selectedDivision] ?? [];

                        return DropdownButtonFormField<District>(
                          initialValue: _selectedDistrict,
                          decoration: const InputDecoration(
                            labelText: 'District',
                            prefixIcon: Icon(Icons.location_city),
                          ),
                          items: districts.map((district) {
                            return DropdownMenuItem(
                              value: district,
                              child: Text(district.name),
                            );
                          }).toList(),
                          onChanged: (district) {
                            setState(() {
                              _selectedDistrict = district;
                              _selectedArea = null;
                              _selectedMosque = null;
                              _filteredMosques = [];
                            });
                            if (district != null) {
                              context
                                  .read<DistrictProvider>()
                                  .loadAreasByDistrict(district.id);
                            }
                          },
                        );
                      },
                    ),
                  if (_selectedDivision != null) const SizedBox(height: 12),
                  // Area dropdown
                  if (_selectedDistrict != null)
                    Consumer<DistrictProvider>(
                      builder: (context, districtProvider, child) {
                        final areas = districtProvider.areasByDistrict;

                        if (areas.isEmpty) {
                          return const Text(
                            'No areas available for this district.',
                            style: TextStyle(color: Colors.orange),
                          );
                        }

                        return DropdownButtonFormField<Area>(
                          initialValue: _selectedArea,
                          decoration: const InputDecoration(
                            labelText: 'Area',
                            prefixIcon: Icon(Icons.place),
                          ),
                          items: areas.map((area) {
                            return DropdownMenuItem(
                              value: area,
                              child: Text(area.name),
                            );
                          }).toList(),
                          onChanged: (area) {
                            setState(() {
                              _selectedArea = area;
                              _selectedMosque = null;
                            });
                            if (area != null) {
                              _loadMosquesByArea(area.id);
                            }
                          },
                        );
                      },
                    ),
                  if (_selectedDistrict != null) const SizedBox(height: 12),
                  // Mosque dropdown
                  if (_selectedArea != null)
                    Consumer<MosqueProvider>(
                      builder: (context, mosqueProvider, child) {
                        if (_filteredMosques.isEmpty) {
                          return const Text(
                            'No mosques available for this area.',
                            style: TextStyle(color: Colors.orange),
                          );
                        }

                        return DropdownButtonFormField<Mosque>(
                          initialValue: _selectedMosque,
                          decoration: const InputDecoration(
                            labelText: 'Mosque',
                            prefixIcon: Icon(Icons.mosque),
                          ),
                          items: _filteredMosques.map((mosque) {
                            return DropdownMenuItem(
                              value: mosque,
                              child: Text(mosque.name),
                            );
                          }).toList(),
                          onChanged: (mosque) {
                            setState(() {
                              _selectedMosque = mosque;
                            });
                            if (mosque != null) {
                              context
                                  .read<PrayerTimeProvider>()
                                  .loadPrayerTime(mosque.id, _selectedDate);
                            }
                          },
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
          // Date selector
          if (_selectedMosque != null)
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: InkWell(
                onTap: () => _selectDate(context),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Selected Date',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat('EEEE, MMMM d, yyyy')
                                  .format(_selectedDate),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 16),
                    ],
                  ),
                ),
              ),
            ),
          const SizedBox(height: 16),
          // Prayer times display/edit
          if (_selectedMosque != null)
            Expanded(
              child: Consumer<PrayerTimeProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return const LoadingIndicator(
                        message: 'Loading prayer times...');
                  }

                  if (provider.currentPrayerTime == null) {
                    return EmptyState(
                      icon: Icons.access_time,
                      title: 'No Prayer Times Set',
                      message:
                          'Set prayer times for ${_selectedMosque!.name} on ${DateFormat('MMM d, yyyy').format(_selectedDate)}',
                      actionLabel: 'Set Prayer Times',
                      onAction: () => _showSetPrayerTimesDialog(context),
                    );
                  }

                  final prayerTime = provider.currentPrayerTime!;
                  return Column(
                    children: [
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          children: [
                            _buildPrayerTimeRow(
                                'Fajr', prayerTime.fajr, context),
                            _buildPrayerTimeRow(
                                'Dhuhr', prayerTime.dhuhr, context),
                            if (prayerTime.jummah != null)
                              _buildPrayerTimeRow(
                                  'Jummah', prayerTime.jummah!, context, 
                                  isJummah: true),
                            _buildPrayerTimeRow(
                                'Asr', prayerTime.asr, context),
                            _buildPrayerTimeRow(
                                'Maghrib', prayerTime.maghrib, context),
                            _buildPrayerTimeRow(
                                'Isha', prayerTime.isha, context),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () =>
                                    _showSetPrayerTimesDialog(context),
                                icon: const Icon(Icons.edit),
                                label: const Text('Edit Times'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1565C0),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          if (_selectedMosque == null)
            const Expanded(
              child: EmptyState(
                icon: Icons.mosque,
                title: 'Select a Mosque',
                message: 'Choose a mosque to manage its prayer times',
              ),
            ),
        ],
        ),
      ),
    );
  }

  Widget _buildPrayerTimeRow(
      String name, DateTime time, BuildContext context, {bool isJummah = false}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      color: isJummah ? Colors.green.withOpacity(0.1) : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              isJummah ? Icons.mosque : Icons.access_time,
              color: isJummah ? Colors.green : Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isJummah ? Colors.green.shade800 : null,
                        ),
                  ),
                  if (isJummah)
                    Text(
                      'Friday Prayer',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.green.shade700,
                          ),
                    ),
                ],
              ),
            ),
            Text(
              DateFormat('HH:mm').format(time),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isJummah ? Colors.green.shade800 : Theme.of(context).colorScheme.primary,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  void _loadMosquesByArea(String areaId) {
    final allMosques = context.read<MosqueProvider>().mosques;
    setState(() {
      _filteredMosques = allMosques.where((m) => m.areaId == areaId).toList();
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null && picked != _selectedDate && _selectedMosque != null) {
      setState(() {
        _selectedDate = picked;
      });
      if (mounted) {
        context
            .read<PrayerTimeProvider>()
            .loadPrayerTime(_selectedMosque!.id, picked);
      }
    }
  }

  void _showSetPrayerTimesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _SetPrayerTimesDialog(
        mosque: _selectedMosque!,
        date: _selectedDate,
        existingPrayerTime: context.read<PrayerTimeProvider>().currentPrayerTime,
      ),
    );
  }
}

/// Dialog for setting prayer times
class _SetPrayerTimesDialog extends StatefulWidget {
  final Mosque mosque;
  final DateTime date;
  final PrayerTime? existingPrayerTime;

  const _SetPrayerTimesDialog({
    super.key,
    required this.mosque,
    required this.date,
    this.existingPrayerTime,
  });

  @override
  State<_SetPrayerTimesDialog> createState() => _SetPrayerTimesDialogState();
}

class _SetPrayerTimesDialogState extends State<_SetPrayerTimesDialog> {
  final _formKey = GlobalKey<FormState>();
  late TimeOfDay _fajrTime;
  late TimeOfDay _dhuhrTime;
  late TimeOfDay _asrTime;
  late TimeOfDay _maghribTime;
  late TimeOfDay _ishaTime;
  TimeOfDay? _jummahTime;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingPrayerTime != null) {
      _fajrTime = TimeOfDay.fromDateTime(widget.existingPrayerTime!.fajr);
      _dhuhrTime = TimeOfDay.fromDateTime(widget.existingPrayerTime!.dhuhr);
      _asrTime = TimeOfDay.fromDateTime(widget.existingPrayerTime!.asr);
      _maghribTime = TimeOfDay.fromDateTime(widget.existingPrayerTime!.maghrib);
      _ishaTime = TimeOfDay.fromDateTime(widget.existingPrayerTime!.isha);
      _jummahTime = widget.existingPrayerTime!.jummah != null
          ? TimeOfDay.fromDateTime(widget.existingPrayerTime!.jummah!)
          : null;
    } else {
      // Default times
      _fajrTime = const TimeOfDay(hour: 5, minute: 30);
      _dhuhrTime = const TimeOfDay(hour: 13, minute: 0);
      _asrTime = const TimeOfDay(hour: 16, minute: 30);
      _maghribTime = const TimeOfDay(hour: 19, minute: 15);
      _ishaTime = const TimeOfDay(hour: 20, minute: 30);
      _jummahTime = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Set Prayer Times'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTimeField('Fajr', _fajrTime, (time) => _fajrTime = time),
              const SizedBox(height: 12),
              _buildTimeField('Dhuhr', _dhuhrTime, (time) => _dhuhrTime = time),
              const SizedBox(height: 12),
              _buildJummahTimeField(),
              const SizedBox(height: 12),
              _buildTimeField('Asr', _asrTime, (time) => _asrTime = time),
              const SizedBox(height: 12),
              _buildTimeField(
                  'Maghrib', _maghribTime, (time) => _maghribTime = time),
              const SizedBox(height: 12),
              _buildTimeField('Isha', _ishaTime, (time) => _ishaTime = time),
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
              : const Text('Save'),
        ),
      ],
    );
  }

  Widget _buildTimeField(
      String label, TimeOfDay time, Function(TimeOfDay) onChanged) {
    return InkWell(
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: time,
        );
        if (picked != null) {
          setState(() {
            onChanged(picked);
          });
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: const Icon(Icons.access_time),
        ),
        child: Text(
          time.format(context),
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    );
  }

  Widget _buildJummahTimeField() {
    return InkWell(
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: _jummahTime ?? const TimeOfDay(hour: 13, minute: 0),
        );
        if (picked != null) {
          setState(() {
            _jummahTime = picked;
          });
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Jummah (Friday Prayer)',
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_jummahTime != null)
                IconButton(
                  icon: const Icon(Icons.clear, size: 20),
                  onPressed: () {
                    setState(() {
                      _jummahTime = null;
                    });
                  },
                  tooltip: 'Clear Jummah time',
                ),
              const Icon(Icons.access_time),
            ],
          ),
        ),
        child: Text(
          _jummahTime != null ? _jummahTime!.format(context) : 'Not set (Optional)',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: _jummahTime == null 
                    ? Theme.of(context).textTheme.bodySmall?.color 
                    : null,
              ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final provider = context.read<PrayerTimeProvider>();
    final prayerTime = PrayerTime(
      id: PrayerTime.generateId(widget.mosque.id, widget.date),
      mosqueId: widget.mosque.id,
      date: widget.date,
      fajr: DateTime(widget.date.year, widget.date.month, widget.date.day,
          _fajrTime.hour, _fajrTime.minute),
      dhuhr: DateTime(widget.date.year, widget.date.month, widget.date.day,
          _dhuhrTime.hour, _dhuhrTime.minute),
      asr: DateTime(widget.date.year, widget.date.month, widget.date.day,
          _asrTime.hour, _asrTime.minute),
      maghrib: DateTime(widget.date.year, widget.date.month, widget.date.day,
          _maghribTime.hour, _maghribTime.minute),
      isha: DateTime(widget.date.year, widget.date.month, widget.date.day,
          _ishaTime.hour, _ishaTime.minute),
      jummah: _jummahTime != null
          ? DateTime(widget.date.year, widget.date.month, widget.date.day,
              _jummahTime!.hour, _jummahTime!.minute)
          : null,
    );

    final success = await provider.setPrayerTime(prayerTime);

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Prayer times set successfully'),
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

