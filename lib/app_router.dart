import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'controllers/auth_controller.dart';
import 'views/screens/choose_role_screen.dart';
import 'views/screens/fournisseur_onboarding_screen.dart';
import 'views/screens/home_screen.dart';
import 'views/screens/login_screen.dart';

class AppRouter extends StatelessWidget {
  const AppRouter({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthController>(
      builder: (context, auth, _) {
        if (!auth.initialized) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Chargement...'),
                ],
              ),
            ),
          );
        }
        if (!auth.isLoggedIn) {
          return const LoginScreen();
        }
        if (!auth.isRegistrationComplete) {
          if (auth.user?.role == null) {
            return const ChooseRoleScreen();
          }
          if (auth.user?.role == 'fournisseur') {
            return const FournisseurOnboardingScreen();
          }
        }
        return const HomeScreen();
      },
    );
  }
}
