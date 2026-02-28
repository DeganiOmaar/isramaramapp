import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../config/api_config.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/cart_controller.dart';
import '../../models/product_model.dart';

class ProductDetailsScreen extends StatefulWidget {
  final ProductModel product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  int _selectedQuantite = 1;

  static const _primary = Color(0xFF1A5F7A);

  @override
  void initState() {
    super.initState();
    _selectedQuantite = 1;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final images = product.images
        .map((p) => '${ApiConfig.serverUrl}$p')
        .where((u) => u.isNotEmpty)
        .toList();
    if (images.isEmpty) images.add('');

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        title: Text(product.nom, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 24.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: SizedBox(
                height: 300.h,
                child: images.length == 1 && images.first.isEmpty
                    ? _placeholder()
                    : PageView.builder(
                        controller: _pageController,
                        onPageChanged: (i) => setState(() => _currentPage = i),
                        itemCount: images.length,
                        itemBuilder: (_, i) => images[i].isEmpty
                            ? _placeholder()
                            : Image.network(
                                  images[i],
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  errorBuilder: (_, __, ___) => _placeholder(),
                              ),
                      ),
              ),
            ),
            SizedBox(height: 20.h),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildFournisseurCard(product),
                    SizedBox(height: 20.h),
                    _buildProductInfo(product),
                    if (!Get.find<AuthController>().isFournisseur) ...[
                      SizedBox(height: 20.h),
                      _buildAddToCartSection(product),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: images.length > 1
          ? SafeArea(
              child: Padding(
                padding: EdgeInsets.only(bottom: 16.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    images.length,
                    (i) => AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: EdgeInsets.symmetric(horizontal: 3.w),
                      width: _currentPage == i ? 24.w : 8.w,
                      height: 8.h,
                      decoration: BoxDecoration(
                        color: _currentPage == i ? _primary : Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),
                  ),
                ),
              ),
            )
          : null,
    );
  }

  Widget _placeholder() => Container(
        color: Colors.grey.shade200,
        child: Center(
          child: Icon(Icons.image_outlined, size: 64.sp, color: Colors.grey.shade400),
        ),
      );

  Widget _buildFournisseurCard(ProductModel product) {
    final prenom = product.fournisseurPrenom.trim();
    final nom = product.fournisseurNom.trim();
    final initial = prenom.isNotEmpty
        ? prenom[0].toUpperCase()
        : nom.isNotEmpty
            ? nom[0].toUpperCase()
            : '?';

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28.r,
            backgroundColor: _primary.withValues(alpha: 0.2),
            child: Text(
              initial,
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: _primary,
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Vendeur',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  product.fournisseurDisplay,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A2E),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductInfo(ProductModel product) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            product.nom,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1A1A2E),
            ),
          ),
          SizedBox(height: 20.h),
          _InfoRow(icon: Icons.inventory_2_outlined, label: 'Quantité disponible', value: '${product.quantite}'),
          SizedBox(height: 12.h),
          _InfoRow(icon: Icons.paid_outlined, label: 'Prix', value: '${product.prixTND} TND'),
        ],
      ),
    );
  }

  Widget _buildAddToCartSection(ProductModel product) {
    final cart = Get.find<CartController>();
    final maxQty = product.quantite;
    if (maxQty < 1) {
      return Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Text(
          'Produit indisponible',
          style: TextStyle(fontSize: 14.sp, color: Colors.orange.shade800),
        ),
      );
    }
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Quantité',
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: const Color(0xFF1A1A2E)),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              IconButton.filled(
                onPressed: _selectedQuantite > 1 ? () => setState(() => _selectedQuantite--) : null,
                icon: Icon(Icons.remove, size: 20.sp),
                style: IconButton.styleFrom(
                  backgroundColor: _primary.withValues(alpha: 0.15),
                  foregroundColor: _primary,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Text(
                  '$_selectedQuantite',
                  style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                ),
              ),
              IconButton.filled(
                onPressed: _selectedQuantite < maxQty ? () => setState(() => _selectedQuantite++) : null,
                icon: Icon(Icons.add, size: 20.sp),
                style: IconButton.styleFrom(
                  backgroundColor: _primary.withValues(alpha: 0.15),
                  foregroundColor: _primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          SizedBox(
            height: 48.h,
            child: FilledButton.icon(
              onPressed: () {
                cart.addToCart(product, _selectedQuantite);
                Get.snackbar('Panier', '${product.nom} (x$_selectedQuantite) ajouté au panier');
              },
              icon: Icon(Icons.shopping_cart_outlined, size: 22.sp),
              label: Text('Ajouter au panier - ${(product.prixTND * _selectedQuantite).toStringAsFixed(0)} TND'),
              style: FilledButton.styleFrom(
                backgroundColor: _primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(
            color: const Color(0xFF1A5F7A).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(icon, size: 22.sp, color: const Color(0xFF1A5F7A)),
        ),
        SizedBox(width: 14.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600)),
              Text(value, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }
}
