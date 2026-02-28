import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../config/api_config.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/cart_controller.dart';
import '../../models/cart_item_model.dart';
import '../../services/order_service.dart';

const _primary = Color(0xFF1A5F7A);

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = Get.find<CartController>();
    final auth = Get.find<AuthController>();

    if (auth.isFournisseur) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Panier',
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
          ),
          centerTitle: true,
        ),
        body: const Center(child: Text('Le panier est réservé aux clients.')),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        title: Text(
          'Mon panier',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          Obx(() {
            if (cart.itemCount == 0) return const SizedBox.shrink();
            return Center(
              child: Padding(
                padding: EdgeInsets.only(right: 16.w),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    '${cart.itemCount} article(s)',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
      body: Obx(() {
        if (cart.items.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.shopping_cart_outlined,
                  size: 80.sp,
                  color: Colors.grey.shade400,
                ),
                SizedBox(height: 16.h),
                Text(
                  'Votre panier est vide',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Parcourez les produits et ajoutez-les à votre panier',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.all(16.w),
                itemCount: cart.items.length,
                itemBuilder: (_, i) => _CartItemCard(item: cart.items[i]),
              ),
            ),
            _buildBottomBar(cart),
          ],
        );
      }),
    );
  }

  Widget _buildBottomBar(CartController cart) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${cart.totalAmount.toStringAsFixed(0)} TND',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: _primary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            SizedBox(
              width: double.infinity,
              height: 52.h,
              child: FilledButton(
                onPressed: () => _placeOrder(cart),
                style: FilledButton.styleFrom(
                  backgroundColor: _primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  'Passer ma commande',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _placeOrder(CartController cart) async {
    if (cart.items.isEmpty) {
      Get.snackbar('Erreur', 'Le panier est vide', 
      backgroundColor: Colors.red, 
      colorText: Colors.white
      );
      return;
    }

    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Confirmer la commande'),
        content: Text(
          'Vous allez commander ${cart.itemCount} article(s) pour un total de ${cart.totalAmount.toStringAsFixed(0)} TND.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      final items = cart.items
          .map((i) => {'productId': i.product.id, 'quantite': i.quantite})
          .toList();

      await OrderService().createOrder(items);
      cart.clearCart();
      Get.back();
      Get.snackbar('Succès', 'Votre commande a été envoyée au fournisseur', 
      backgroundColor: Colors.green, 
      colorText: Colors.black87
      );
    } catch (e) {
      Get.back();
      Get.snackbar('Erreur', e.toString());
    }
  }
}

class _CartItemCard extends StatelessWidget {
  final CartItemModel item;

  const _CartItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final cart = Get.find<CartController>();
    final imageUrl = item.product.images.isNotEmpty
        ? '${ApiConfig.serverUrl}${item.product.images.first}'
        : null;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
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
          ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: imageUrl != null
                ? Image.network(
                    imageUrl,
                    width: 80.w,
                    height: 80.w,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _placeholder(),
                  )
                : _placeholder(),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.nom,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Text(
                  '${item.product.prixTND.toStringAsFixed(0)} TND × ${item.quantite}',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
                SizedBox(height: 6.h),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.remove_circle_outline,
                        size: 22.sp,
                        color: _primary,
                      ),
                      onPressed: () {
                        if (item.quantite > 1) {
                          cart.updateQuantity(
                            item.product.id,
                            item.quantite - 1,
                          );
                        } else {
                          cart.removeFromCart(item.product.id);
                        }
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      child: Text(
                        '${item.quantite}',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.add_circle_outline,
                        size: 22.sp,
                        color: _primary,
                      ),
                      onPressed: item.quantite < item.product.quantite
                          ? () => cart.updateQuantity(
                              item.product.id,
                              item.quantite + 1,
                            )
                          : null,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${item.sousTotal.toStringAsFixed(0)} TND',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: _primary,
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.delete_outline,
                  size: 22.sp,
                  color: Colors.red.shade600,
                ),
                onPressed: () => cart.removeFromCart(item.product.id),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _placeholder() => Container(
    width: 80.w,
    height: 80.w,
    color: Colors.grey.shade200,
    child: Icon(Icons.image_outlined, size: 32.sp, color: Colors.grey.shade400),
  );
}
