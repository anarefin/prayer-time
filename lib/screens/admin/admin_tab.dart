import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'admin_login_screen.dart';
import 'admin_dashboard_screen.dart';

/// Admin Tab that switches between Login and Dashboard based on auth state
class AdminTab extends StatelessWidget {
  const AdminTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (authProvider.isLoggedIn && authProvider.isAdmin) {
          return const AdminDashboardContent(
            // When in tab, logout just signs out, no navigation needed
            // The Consumer will rebuild and show AdminLoginContent
            onLogout: null,
          );
        }
        return Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: const AdminLoginContent(
              // When in tab, successful login just updates state
              // The Consumer will rebuild and show AdminDashboardContent
              onLoginSuccess: null,
            ),
          ),
        );
      },
    );
  }
}
