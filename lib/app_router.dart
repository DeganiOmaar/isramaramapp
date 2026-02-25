import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controllers/auth_controller.dart';
import 'views/screens/choose_role_screen.dart';
import 'views/screens/fournisseur_onboarding_screen.dart';
import 'views/screens/login_screen.dart';
import 'views/screens/main_shell.dart';

class AppRouter extends StatelessWidget {
  const AppRouter({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final auth = Get.find<AuthController>();
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
      return const MainShell();
    });
  }
}
