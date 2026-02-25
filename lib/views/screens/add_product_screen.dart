import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/api_service.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _quantiteController = TextEditingController();
  final _prixController = TextEditingController();
  final _picker = ImagePicker();
  final List<File> _images = [];
  bool _isLoading = false;

  static const _primary = Color(0xFF1A5F7A);
  static const _secondary = Color(0xFF57C5B6);
  static const _surface = Color(0xFFF8FAFC);

  @override
  void dispose() {
    _nomController.dispose();
    _quantiteController.dispose();
    _prixController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    if (_images.length >= 4) {
      Get.snackbar('Maximum atteint', 'Vous pouvez ajouter jusqu\'à 4 photos');
      return;
    }
    final XFile? file = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (file != null) {
      setState(() => _images.add(File(file.path)));
    }
  }

  void _removeImage(int index) {
    setState(() => _images.removeAt(index));
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_images.isEmpty) {
      Get.snackbar('Photos requises', 'Ajoutez au moins une photo pour votre produit',
          backgroundColor: Colors.red.shade100, colorText: Colors.red.shade900);
      return;
    }
    setState(() => _isLoading = true);
    debugPrint('[ADD_PRODUCT] Submitting: nom=${_nomController.text}, quantite=${_quantiteController.text}, prix=${_prixController.text}, images=${_images.length}');
    try {
      await ApiService().postMultipart(
        '/products',
        fields: {
          'nom': _nomController.text.trim(),
          'quantite': _quantiteController.text.trim(),
          'prixTND': _prixController.text.trim(),
        },
        imageFiles: _images,
      );
      debugPrint('[ADD_PRODUCT] Success');
      if (mounted) {
        Get.back();
        Get.snackbar('Succès', 'Votre produit a été ajouté avec succès',
            backgroundColor: Colors.green.shade600, colorText: Colors.white);
      }
    } on ApiException catch (e) {
      debugPrint('[ADD_PRODUCT] ApiException: ${e.message} (status ${e.statusCode})');
      if (mounted) Get.snackbar('Erreur', e.message,
          backgroundColor: Colors.red.shade600, colorText: Colors.white);
    } catch (e, st) {
      debugPrint('[ADD_PRODUCT] Unexpected error: $e');
      debugPrint('[ADD_PRODUCT] Stack: $st');
      if (mounted) Get.snackbar('Erreur', e.toString(),
          backgroundColor: Colors.red.shade600, colorText: Colors.white);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surface,
      appBar: AppBar(
        title: Text(
          'Nouveau produit',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: _primary,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            _buildImageSection(),
            _buildFormSection(),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: _primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.photo_library_rounded, size: 18.sp, color: _primary),
                    SizedBox(width: 6.w),
                    Text(
                      '${_images.length}/4 photos',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: _primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          _images.isEmpty ? _buildEmptyImageState() : _buildImageGrid(),
        ],
      ),
    );
  }

  Widget _buildEmptyImageState() {
    return GestureDetector(
      onTap: _pickImage,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        height: 200.h,
        decoration: BoxDecoration(
          color: _primary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: _secondary.withValues(alpha: 0.5),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: _primary.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: _secondary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.add_photo_alternate_rounded, size: 48.sp, color: _primary),
              ),
              SizedBox(height: 16.h),
              Text(
                'Ajoutez des photos de votre produit',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A1A2E),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 4.h),
              Text(
                'Appuyez pour sélectionner jusqu\'à 4 images',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageGrid() {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 140.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _images.length + (_images.length < 4 ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _images.length) {
                  return Padding(
                    padding: EdgeInsets.only(left: 12.w),
                    child: _AddImageCard(onTap: _pickImage),
                  );
                }
                return Padding(
                  padding: EdgeInsets.only(right: index < _images.length - 1 ? 12.w : 0),
                  child: _ImageThumb(
                    file: _images[index],
                    onRemove: () => _removeImage(index),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormSection() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informations du produit',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1A2E),
              letterSpacing: 0.3,
            ),
          ),
          SizedBox(height: 16.h),
          _InputCard(
            children: [
              _StyledTextField(
                controller: _nomController,
                label: 'Nom du produit',
                hint: 'Ex: T-shirt coton premium',
                icon: Icons.shopping_bag_rounded,
                validator: (v) => v == null || v.trim().isEmpty ? 'Le nom est requis' : null,
              ),
              SizedBox(height: 20.h),
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
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 32.h, 20.w, 40.h),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isLoading ? null : _submit,
          borderRadius: BorderRadius.circular(16.r),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 56.h,
            decoration: BoxDecoration(
              gradient: _isLoading
                  ? null
                  : const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [_primary, Color(0xFF2D7A8C)],
                    ),
              color: _isLoading ? Colors.grey.shade300 : null,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: _isLoading
                  ? null
                  : [
                      BoxShadow(
                        color: _primary.withValues(alpha: 0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
            ),
            child: Center(
              child: _isLoading
                  ? SizedBox(
                      height: 26.h,
                      width: 26.w,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_outline_rounded, size: 22.sp, color: Colors.white),
                        SizedBox(width: 10.w),
                        Text(
                          'Ajouter le produit',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.5,
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
}

class _AddImageCard extends StatelessWidget {
  final VoidCallback onTap;

  const _AddImageCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120.w,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: const Color(0xFF57C5B6).withValues(alpha: 0.4),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_rounded, size: 40.sp, color: const Color(0xFF57C5B6)),
            SizedBox(height: 8.h),
            Text(
              'Ajouter',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1A5F7A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImageThumb extends StatelessWidget {
  final File file;
  final VoidCallback onRemove;

  const _ImageThumb({required this.file, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 120.w,
          height: 140.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16.r),
            child: Image.file(file, fit: BoxFit.cover),
          ),
        ),
        Positioned(
          top: 8.h,
          right: 8.w,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: EdgeInsets.all(6.w),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Icon(Icons.close_rounded, size: 18.sp, color: Colors.red.shade600),
            ),
          ),
        ),
      ],
    );
  }
}

class _InputCard extends StatelessWidget {
  final List<Widget> children;

  const _InputCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A5F7A).withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(children: children),
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
        labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14.sp),
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14.sp),
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
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      ),
    );
  }
}
