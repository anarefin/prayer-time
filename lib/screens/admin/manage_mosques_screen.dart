import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/mosque.dart';
import '../../providers/mosque_provider.dart';
import '../../widgets/mosque_card.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/empty_state.dart';
import 'add_edit_mosque_screen.dart';

/// Screen for managing mosques (CRUD operations)
class ManageMosquesScreen extends StatefulWidget {
  const ManageMosquesScreen({Key? key}) : super(key: key);

  @override
  State<ManageMosquesScreen> createState() => _ManageMosquesScreenState();
}

class _ManageMosquesScreenState extends State<ManageMosquesScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final provider = context.read<MosqueProvider>();
    provider.loadAreas();
    provider.loadAllMosques();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Mosques'),
        backgroundColor: const Color(0xFF1565C0),
      ),
      body: SafeArea(
        child: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search mosques...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          context.read<MosqueProvider>().clearSearch();
                        },
                      )
                    : null,
              ),
              onChanged: (query) {
                context.read<MosqueProvider>().searchMosques(query);
              },
            ),
          ),
          // Mosque list
          Expanded(
            child: Consumer<MosqueProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const LoadingIndicator(message: 'Loading mosques...');
                }

                if (provider.errorMessage != null) {
                  return ErrorState(
                    message: provider.errorMessage!,
                    onRetry: _loadData,
                  );
                }

                if (provider.mosques.isEmpty) {
                  if (provider.searchQuery.isNotEmpty) {
                    return EmptyState(
                      icon: Icons.search_off,
                      title: 'No Results',
                      message:
                          'No mosques found matching "${provider.searchQuery}"',
                    );
                  }
                  return EmptyState(
                    icon: Icons.mosque,
                    title: 'No Mosques',
                    message: 'Add your first mosque to get started',
                    actionLabel: 'Add Mosque',
                    onAction: () => _navigateToAddEdit(context),
                  );
                }

                return ListView.builder(
                  itemCount: provider.mosques.length,
                  itemBuilder: (context, index) {
                    final mosque = provider.mosques[index];
                    return MosqueCard(
                      mosque: mosque,
                      showFavoriteButton: false,
                      onTap: () => _showMosqueOptions(context, mosque),
                    );
                  },
                );
              },
            ),
          ),
        ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToAddEdit(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Mosque'),
        backgroundColor: const Color(0xFF1565C0),
      ),
    );
  }

  void _navigateToAddEdit(BuildContext context, {Mosque? mosque}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditMosqueScreen(mosque: mosque),
      ),
    );
  }

  void _showMosqueOptions(BuildContext context, Mosque mosque) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.blue),
              title: const Text('Edit Mosque'),
              onTap: () {
                Navigator.pop(context);
                _navigateToAddEdit(context, mosque: mosque);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete Mosque'),
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(context, mosque);
              },
            ),
            ListTile(
              leading: const Icon(Icons.info, color: Colors.grey),
              title: const Text('Mosque Details'),
              subtitle: Text(
                'Lat: ${mosque.latitude.toStringAsFixed(6)}, '
                'Lng: ${mosque.longitude.toStringAsFixed(6)}',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, Mosque mosque) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Mosque'),
        content: Text(
          'Are you sure you want to delete "${mosque.name}"? '
          'This will also delete all associated prayer times.',
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
      final success = await provider.deleteMosque(mosque.id);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Mosque deleted successfully'
                  : provider.errorMessage ?? 'Failed to delete mosque',
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }
}

