import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/favorites_provider.dart';
import '../../widgets/mosque_card.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/empty_state.dart';
import 'prayer_time_screen.dart';

/// Screen displaying user's favorite mosques
class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload favorites when user data changes (e.g., when favorites are updated in Firestore)
    _loadFavorites();
  }

  void _loadFavorites() {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.isLoggedIn && authProvider.currentUser != null) {
      context
          .read<FavoritesProvider>()
          .loadFavorites(authProvider.currentUser!.favorites);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    // Reload favorites when user data changes (important for real-time updates)
    if (authProvider.isLoggedIn && authProvider.currentUser != null) {
      // Check if favorites need to be synced
      final favProvider = context.read<FavoritesProvider>();
      final currentFavorites = authProvider.currentUser!.favorites;
      
      // Only reload if the favorites list has changed
      if (!_listsEqual(favProvider.favoriteIds, currentFavorites)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            favProvider.loadFavorites(currentFavorites);
          }
        });
      }
    }

    // Show login prompt if not logged in
    if (!authProvider.isLoggedIn) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.favorite_border,
                size: 80,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
              ),
              const SizedBox(height: 24),
              Text(
                'Sign in to save favorites',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Create an account or sign in to save your favorite mosques',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => _showAuthDialog(context),
                icon: const Icon(Icons.login),
                label: const Text('Sign In'),
              ),
            ],
          ),
        ),
      );
    }

    return Consumer<FavoritesProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const LoadingIndicator(message: 'Loading favorites...');
        }

        if (provider.errorMessage != null) {
          return ErrorState(
            message: provider.errorMessage!,
            onRetry: _loadFavorites,
          );
        }

        if (provider.favoriteMosques.isEmpty) {
          return const EmptyState(
            icon: Icons.favorite_border,
            title: 'No Favorites Yet',
            message:
                'Start adding mosques to your favorites to see them here.',
          );
        }

        return ListView(
          padding: const EdgeInsets.only(top: 8, bottom: 16),
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                '${provider.favoriteCount} Favorite${provider.favoriteCount == 1 ? '' : 's'}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            ...provider.favoriteMosques.map((mosque) {
              return MosqueCard(
                mosque: mosque,
                isFavorite: true,
                onFavoriteToggle: () async {
                  if (authProvider.currentUser != null) {
                    await provider.removeFavorite(
                      authProvider.currentUser!.uid,
                      mosque.id,
                    );
                  }
                },
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PrayerTimeScreen(mosque: mosque),
                    ),
                  );
                },
              );
            }).toList(),
          ],
        );
      },
    );
  }

  void _showAuthDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AuthDialog(),
    );
  }

  /// Helper method to compare two lists
  bool _listsEqual(List<String> list1, List<String> list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (!list2.contains(list1[i])) return false;
    }
    for (int i = 0; i < list2.length; i++) {
      if (!list1.contains(list2[i])) return false;
    }
    return true;
  }
}

/// Dialog for user authentication
class AuthDialog extends StatefulWidget {
  const AuthDialog({Key? key}) : super(key: key);

  @override
  State<AuthDialog> createState() => _AuthDialogState();
}

class _AuthDialogState extends State<AuthDialog> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLogin = true;
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isLogin ? 'Sign In' : 'Create Account'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                  hintText: 'example@email.com',
                ),
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  // Improved email validation
                  final emailRegex = RegExp(
                    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                  );
                  if (!emailRegex.hasMatch(value.trim())) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock),
                  hintText: 'Min. 6 characters',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _submit(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
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
          onPressed: _isLoading
              ? null
              : () {
                  setState(() {
                    _isLogin = !_isLogin;
                  });
                },
          child: Text(_isLogin ? 'Create Account' : 'Sign In Instead'),
        ),
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          child: _isLoading
              ? const SmallLoadingIndicator()
              : Text(_isLogin ? 'Sign In' : 'Register'),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final authProvider = context.read<AuthProvider>();
    
    try {
      bool success;

      if (_isLogin) {
        success = await authProvider.signIn(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      } else {
        success = await authProvider.register(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      }

      // Wait for auth state to update
      await Future.delayed(const Duration(milliseconds: 500));

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        // Check if user is actually logged in (auth might succeed despite errors)
        if (authProvider.isLoggedIn) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_isLogin ? 'Signed in successfully' : 'Account created successfully'),
            ),
          );
        } else if (!success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authProvider.errorMessage ?? 'Authentication failed'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('Auth error caught: $e');
      
      // Wait for auth state to update
      await Future.delayed(const Duration(milliseconds: 500));
      
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        // Check if user is logged in despite the error
        if (authProvider.isLoggedIn) {
          print('User is logged in despite error');
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_isLogin ? 'Signed in successfully' : 'Account created successfully'),
            ),
          );
        } else {
          // Actually failed
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Authentication failed: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}

