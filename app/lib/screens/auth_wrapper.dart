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
  bool _showAuth = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Always show the main app, but with optional authentication
        if (!_showAuth) {
          return Stack(
            children: [
              const AgriBaseHomeScreen(),
              // Optional login overlay
              if (!authProvider.isAuthenticated)
                Positioned(
                  top: 16,
                  right: 16,
                  child: FloatingActionButton(
                    backgroundColor: const Color.fromARGB(255, 0, 77, 64),
                    onPressed: () => _showAuthDialog(context),
                    child: const Icon(Icons.login, color: Colors.white),
                  ),
                ),
            ],
          );
        } else {
          return _buildAuthScreen();
        }
      },
    );
  }

  void _showAuthDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Authentication'),
        content: const Text(
          'Would you like to sign in to access personalized features, or continue as a guest?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() => _showAuth = true);
            },
            child: const Text('Sign In'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Continue as Guest'),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthScreen() {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 0, 77, 64),
          title: const Text('Welcome to AgriBase'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Sign In'),
              Tab(text: 'Register'),
            ],
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => setState(() => _showAuth = false),
          ),
        ),
        body: const TabBarView(children: [LoginScreen(), RegisterScreen()]),
      ),
    );
  }
}
