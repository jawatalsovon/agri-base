import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'home_screen.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import '../providers/auth_provider.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isGuestMode = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // If user is authenticated, show home screen
        if (authProvider.isAuthenticated) {
          return const AgriBaseHomeScreen();
        }
        
        // If guest mode is enabled, show home screen
        if (_isGuestMode) {
          return const AgriBaseHomeScreen();
        }
        
        // Otherwise, show onboarding/auth screen
        return _buildOnboardingScreen();
      },
    );
  }

  Widget _buildOnboardingScreen() {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              // Tab bar
              Container(
                color: const Color.fromARGB(255, 0, 77, 64),
                child: const TabBar(
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white70,
                  indicatorColor: Colors.white,
                  tabs: [
                    Tab(text: 'Sign In'),
                    Tab(text: 'Sign Up'),
                  ],
                ),
              ),
              // Tab view
              Expanded(
                child: TabBarView(
                  children: [
                    LoginScreen(onGuestMode: () {
                      setState(() => _isGuestMode = true);
                    }),
                    RegisterScreen(onGuestMode: () {
                      setState(() => _isGuestMode = true);
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
