import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/math_captcha_widget.dart';
import '../../services/captcha_service.dart';
import 'admin_dashboard_screen.dart';

/// Admin login screen with role verification
class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _captchaService = CaptchaService();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _isCaptchaValid = false;
  
  // Rate limiting
  static const String _attemptCountKey = 'admin_login_attempts';
  static const String _lockoutTimeKey = 'admin_login_lockout';
  static const int _maxAttempts = 5;
  static const int _lockoutDurationMinutes = 5;
  int _attemptCount = 0;
  DateTime? _lockoutTime;

  @override
  void initState() {
    super.initState();
    _loadRateLimitData();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Load rate limiting data from local storage
  Future<void> _loadRateLimitData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _attemptCount = prefs.getInt(_attemptCountKey) ?? 0;
      final lockoutTimestamp = prefs.getInt(_lockoutTimeKey);
      if (lockoutTimestamp != null) {
        _lockoutTime = DateTime.fromMillisecondsSinceEpoch(lockoutTimestamp);
        
        // Check if lockout has expired
        if (DateTime.now().isAfter(_lockoutTime!)) {
          _attemptCount = 0;
          _lockoutTime = null;
          prefs.remove(_attemptCountKey);
          prefs.remove(_lockoutTimeKey);
        }
      }
    });
  }

  /// Save rate limiting data to local storage
  Future<void> _saveRateLimitData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_attemptCountKey, _attemptCount);
    if (_lockoutTime != null) {
      await prefs.setInt(_lockoutTimeKey, _lockoutTime!.millisecondsSinceEpoch);
    }
  }

  /// Increment failed attempt count
  Future<void> _incrementAttemptCount() async {
    setState(() {
      _attemptCount++;
    });
    
    if (_attemptCount >= _maxAttempts) {
      setState(() {
        _lockoutTime = DateTime.now().add(
          const Duration(minutes: _lockoutDurationMinutes),
        );
      });
    }
    
    await _saveRateLimitData();
  }

  /// Reset attempt count on successful login
  Future<void> _resetAttemptCount() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_attemptCountKey);
    await prefs.remove(_lockoutTimeKey);
    setState(() {
      _attemptCount = 0;
      _lockoutTime = null;
    });
  }

  /// Check if currently locked out
  bool get _isLockedOut {
    if (_lockoutTime == null) return false;
    return DateTime.now().isBefore(_lockoutTime!);
  }

  /// Get remaining lockout time
  String get _remainingLockoutTime {
    if (_lockoutTime == null) return '';
    final remaining = _lockoutTime!.difference(DateTime.now());
    if (remaining.isNegative) return '';
    final minutes = remaining.inMinutes;
    final seconds = remaining.inSeconds % 60;
    return '${minutes}m ${seconds}s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Login'),
        backgroundColor: const Color(0xFF1565C0), // Admin blue color
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Admin icon
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1565C0).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: const Icon(
                    Icons.admin_panel_settings,
                    size: 60,
                    color: Color(0xFF1565C0),
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Admin Portal',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sign in with your admin credentials',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                // Email field
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                    hintText: 'admin@example.com',
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
                // Password field
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock),
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
                  onFieldSubmitted: (_) => _login(),
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
                const SizedBox(height: 16),
                // CAPTCHA Widget
                MathCaptchaWidget(
                  captchaService: _captchaService,
                  onValidationChanged: (isValid) {
                    setState(() {
                      _isCaptchaValid = isValid;
                    });
                  },
                  difficulty: CaptchaDifficulty.easy,
                ),
                const SizedBox(height: 24),
                // Rate limit warning
                if (_attemptCount > 0 && !_isLockedOut)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber, color: Colors.orange, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Failed attempts: $_attemptCount/$_maxAttempts',
                            style: TextStyle(
                              color: Colors.orange.shade800,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                // Lockout message
                if (_isLockedOut)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.lock_clock, color: Colors.red, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Too many failed attempts. Try again in $_remainingLockoutTime',
                            style: TextStyle(
                              color: Colors.red.shade800,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                // Login button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: (_isLoading || !_isCaptchaValid || _isLockedOut) 
                        ? null 
                        : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1565C0),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isLoading
                        ? const SmallLoadingIndicator(color: Colors.white)
                        : const Text(
                            'Sign In',
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                ),
                const SizedBox(height: 24),
                // Warning message
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber, color: Colors.amber),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Admin access only. Unauthorized access is prohibited.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
          ),
      ),
    );
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    // Check lockout status
    if (_isLockedOut) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Account temporarily locked. Try again in $_remainingLockoutTime'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validate CAPTCHA
    if (!_isCaptchaValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete the security verification'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final authProvider = context.read<AuthProvider>();
    
    try {
      final success = await authProvider.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      // Wait a moment for auth state to update
      await Future.delayed(const Duration(milliseconds: 500));

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        // Check if user is actually logged in (auth might succeed despite errors)
        if (authProvider.isLoggedIn) {
          // Check if user is admin
          if (authProvider.isAdmin) {
            // Success! Reset attempt count
            await _resetAttemptCount();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const AdminDashboardScreen(),
              ),
            );
          } else {
            // User is not admin
            await authProvider.signOut();
            await _incrementAttemptCount();
            // Regenerate CAPTCHA
            _captchaService.generateCaptcha();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Access denied. Admin credentials required.'),
                backgroundColor: Colors.red,
              ),
            );
          }
        } else if (!success) {
          // Only show error if actually not logged in
          await _incrementAttemptCount();
          // Regenerate CAPTCHA
          _captchaService.generateCaptcha();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authProvider.errorMessage ?? 'Login failed'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Login error caught: $e');
      
      // Wait for auth state to update
      await Future.delayed(const Duration(milliseconds: 500));
      
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        // Check if user is logged in despite the error
        if (authProvider.isLoggedIn) {
          debugPrint('User is logged in despite error');
          // Check if user is admin
          if (authProvider.isAdmin) {
            // Success! Reset attempt count
            await _resetAttemptCount();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const AdminDashboardScreen(),
              ),
            );
          } else {
            // User is not admin
            await authProvider.signOut();
            await _incrementAttemptCount();
            // Regenerate CAPTCHA
            _captchaService.generateCaptcha();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Access denied. Admin credentials required.'),
                backgroundColor: Colors.red,
              ),
            );
          }
        } else {
          // Actually failed to login
          await _incrementAttemptCount();
          // Regenerate CAPTCHA
          _captchaService.generateCaptcha();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Login failed: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}

