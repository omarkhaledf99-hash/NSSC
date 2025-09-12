import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _checkAuthStatus();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _animationController.forward();
  }

  Future<void> _checkAuthStatus() async {
    // Wait for animation to complete
    await Future.delayed(const Duration(seconds: 3));
    
    try {
      final isLoggedIn = await AuthService.isLoggedIn();
      
      if (!mounted) return;
      
      if (isLoggedIn) {
        final userRole = await AuthService.getUserRole();
        _navigateToDashboard(userRole);
      } else {
        _navigateToLogin();
      }
    } catch (e) {
      // If there's an error, navigate to login
      if (mounted) {
        _navigateToLogin();
      }
    }
  }

  void _navigateToLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
    );
  }

  void _navigateToDashboard(String? userRole) {
    // Navigate based on user role
    // For now, we'll navigate to a placeholder dashboard
    // You can replace this with actual dashboard screens based on role
    
    String routeName;
    switch (userRole?.toLowerCase()) {
      case 'admin':
        routeName = '/admin_dashboard';
        break;
      case 'supervisor':
        routeName = '/supervisor_dashboard';
        break;
      case 'worker':
        routeName = '/worker_dashboard';
        break;
      default:
        routeName = '/dashboard';
    }
    
    // For now, navigate to login as dashboards are not implemented yet
    // Replace this with actual navigation when dashboards are ready
    _navigateToLogin();
    
    // Uncomment when dashboards are implemented:
    // Navigator.of(context).pushReplacementNamed(routeName);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Company Logo
              Container(
                width: 200,
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    color: const Color(0xFF2E5BBA),
                    child: const Center(
                      child: Text(
                        'NSSC\nFactory\nTracking',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              
              // Loading indicator
              const SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2E5BBA)),
                ),
              ),
              const SizedBox(height: 20),
              
              // Loading text
              Text(
                'Loading...',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 60),
              
              // Version info
              Text(
                'Version 1.0.0',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[400],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}