import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app_router.dart';
import '../../controllers/auth_controller.dart';

class FournisseurOnboardingScreen extends StatefulWidget {
  const FournisseurOnboardingScreen({super.key});

  @override
  State<FournisseurOnboardingScreen> createState() => _FournisseurOnboardingScreenState();
}

class _FournisseurOnboardingScreenState extends State<FournisseurOnboardingScreen> {
  final _pageController = PageController();
  final _societeController = TextEditingController();
  final _produitController = TextEditingController();
  final _descController = TextEditingController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    _societeController.dispose();
    _produitController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentPage++);
    } else {
      _submit();
    }
  }

  void _back() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentPage--);
    }
  }

  bool _validateCurrent() {
    switch (_currentPage) {
      case 0:
        return _societeController.text.trim().isNotEmpty;
      case 1:
        return _produitController.text.trim().isNotEmpty;
      case 2:
        return _descController.text.trim().isNotEmpty;
      default:
        return true;
    }
  }

  Future<void> _submit() async {
    if (!_validateCurrent()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs'), backgroundColor: Colors.red),
      );
      return;
    }
    final auth = context.read<AuthController>();
    final err = await auth.updateFournisseurInfo(
      societeNom: _societeController.text.trim(),
      produitAVendre: _produitController.text.trim(),
      descriptionActivite: _descController.text.trim(),
    );
    if (!mounted) return;
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err), backgroundColor: Colors.red),
      );
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const AppRouter()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    return Scaffold(
      appBar: AppBar(
        leading: _currentPage > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _back,
              )
            : const SizedBox(),
        title: Text('Étape ${_currentPage + 1}/3'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: LinearProgressIndicator(
                value: (_currentPage + 1) / 3,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation(Theme.of(context).colorScheme.primary),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _currentPage = i),
                children: [
                  _OnboardingPage(
                    icon: Icons.business_outlined,
                    title: 'Quelle est le nom de votre société ?',
                    hint: 'Ex: Ma Société SARL',
                    controller: _societeController,
                    maxLines: 1,
                  ),
                  _OnboardingPage(
                    icon: Icons.inventory_2_outlined,
                    title: 'Quel est le produit à vendre ?',
                    hint: 'Ex: Électronique, Textile...',
                    controller: _produitController,
                    maxLines: 1,
                  ),
                  _OnboardingPage(
                    icon: Icons.description_outlined,
                    title: 'Quelle est la description de votre activité ?',
                    hint: 'Décrivez brièvement votre activité commerciale',
                    controller: _descController,
                    maxLines: 4,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: auth.isLoading ? null : _next,
                  child: auth.isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text(_currentPage < 2 ? 'Suivant' : 'Terminer'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String hint;
  final TextEditingController controller;
  final int maxLines;

  const _OnboardingPage({
    required this.icon,
    required this.title,
    required this.hint,
    required this.controller,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          Icon(icon, size: 64, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 32),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A1A2E),
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          TextFormField(
            controller: controller,
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hint,
              alignLabelWithHint: maxLines > 1,
            ),
          ),
        ],
      ),
    );
  }
}
