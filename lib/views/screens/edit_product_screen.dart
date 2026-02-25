import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../models/product_model.dart';
import '../../services/api_service.dart';
import '../../services/product_service.dart';

class EditProductScreen extends StatefulWidget {
  final ProductModel product;

  const EditProductScreen({super.key, required this.product});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nomController;
  late final TextEditingController _quantiteController;
  late final TextEditingController _prixController;
  bool _isLoading = false;

  static const _primary = Color(0xFF1A5F7A);
  static const _surface = Color(0xFFF8FAFC);

  @override
  void initState() {
    super.initState();
    _nomController = TextEditingController(text: widget.product.nom);
    _quantiteController = TextEditingController(text: '${widget.product.quantite}');
    _prixController = TextEditingController(text: '${widget.product.prixTND}');
  }

  @override
  void dispose() {
    _nomController.dispose();
    _quantiteController.dispose();
    _prixController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await ProductService().updateProduct(
        widget.product.id,
        nom: _nomController.text.trim(),
        quantite: int.parse(_quantiteController.text.trim()),
        prixTND: double.parse(_prixController.text.trim()),
      );
      if (mounted) {
        Get.snackbar('Succès', 'Produit modifié');
        Get.back(result: true);
      }
    } on ApiException catch (e) {
      if (mounted) Get.snackbar('Erreur', e.message);
    } catch (e) {
      if (mounted) Get.snackbar('Erreur', e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surface,
      appBar: AppBar(
        title: Text('Modifier le produit', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600)),
        centerTitle: true,
        backgroundColor: _primary,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(20.w),
          children: [
            _StyledTextField(
              controller: _nomController,
              label: 'Nom du produit',
              hint: 'Ex: T-shirt coton premium',
              icon: Icons.shopping_bag_rounded,
              validator: (v) => v == null || v.trim().isEmpty ? 'Le nom est requis' : null,
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: _StyledTextField(
                    controller: _quantiteController,
                    label: 'Quantité',
                    hint: '0',
                    icon: Icons.inventory_2_rounded,
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Requis';
                      if (int.tryParse(v) == null || int.parse(v) < 0) return 'Invalide';
                      return null;
                    },
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: _StyledTextField(
                    controller: _prixController,
                    label: 'Prix (TND)',
                    hint: '0.00',
                    icon: Icons.paid_rounded,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Requis';
                      if (double.tryParse(v) == null || double.parse(v) < 0) return 'Invalide';
                      return null;
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 40.h),
            SizedBox(
              height: 52.h,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                child: _isLoading
                    ? SizedBox(height: 24.h, width: 24.w, child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Enregistrer'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StyledTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _StyledTextField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF1A5F7A);
    const secondary = Color(0xFF57C5B6);

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Container(
          margin: EdgeInsets.only(right: 12.w),
          padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(
            color: secondary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(icon, size: 22.sp, color: primary),
        ),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14.r)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14.r), borderSide: BorderSide(color: Colors.grey.shade200)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14.r), borderSide: const BorderSide(color: primary, width: 2)),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      ),
    );
  }
}
