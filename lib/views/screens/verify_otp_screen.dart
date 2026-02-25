import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app_router.dart';
import '../../controllers/auth_controller.dart';

class VerifyOtpScreen extends StatefulWidget {
  final String email;

  const VerifyOtpScreen({super.key, required this.email});

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  final _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = Get.find<AuthController>();
    final err = await auth.verifyOtp(widget.email, _otpController.text.trim());
    if (!mounted) return;
    if (err != null) {
      Get.snackbar('Erreur', err, backgroundColor: Colors.red.shade100);
    } else {
      Get.offAll(() => const AppRouter());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final auth = Get.find<AuthController>();
      return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 48),
                Icon(Icons.mark_email_read_outlined, size: 80, color: Theme.of(context).colorScheme.primary),
                const SizedBox(height: 24),
                Text(
                  'Vérification',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1A1A2E),
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Entrez le code à 6 chiffres envoyé à\n${widget.email}',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                TextFormField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 24, letterSpacing: 12),
                  decoration: const InputDecoration(
                    hintText: '000000',
                    counterText: '',
                  ),
                  validator: (v) {
                    if (v == null || v.length != 6) return 'Code à 6 chiffres requis';
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: auth.isLoading
                      ? null
                      : () async {
                          final ctrl = Get.find<AuthController>();
                          final err = await ctrl.resendOtp(widget.email);
                          if (!mounted) return;
                          if (err != null) {
                            Get.snackbar('Erreur', err, backgroundColor: Colors.red.shade100);
                          } else {
                            Get.snackbar('Succès', 'Code renvoyé à votre email');
                          }
                        },
                  child: const Text('Renvoyer le code'),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: auth.isLoading ? null : _verify,
                    child: auth.isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Vérifier'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    });
  }
}
