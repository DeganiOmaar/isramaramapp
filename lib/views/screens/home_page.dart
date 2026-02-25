import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../config/api_config.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/product_controller.dart';
import '../../models/product_model.dart';
import 'add_product_screen.dart';
import 'edit_product_screen.dart';
import 'product_details_screen.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    final productCtrl = Get.find<ProductController>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Accueil', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600)),
        centerTitle: true,
        actions: [
          if (auth.isFournisseur) ...[
            IconButton(
              icon: Icon(Icons.delete_sweep, size: 24.sp),
              onPressed: () => _confirmClearAll(context, auth, productCtrl),
              tooltip: 'Vider ma liste',
            ),
            IconButton(
              icon: Icon(Icons.add_circle_outline, size: 26.sp),
              onPressed: () => Get.to(() => const AddProductScreen())?.then((_) => productCtrl.fetchProducts()),
              tooltip: 'Ajouter un produit',
            ),
          ],
        ],
      ),
      body: Obx(() {
        if (productCtrl.isLoading && productCtrl.products.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Theme.of(context).colorScheme.primary),
                SizedBox(height: 16.h),
                Text('Chargement des produits...', style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade600)),
              ],
            ),
          );
        }
        if (productCtrl.products.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inventory_2_outlined, size: 64.sp, color: Colors.grey.shade400),
                SizedBox(height: 16.h),
                Text('Aucun produit', style: TextStyle(fontSize: 16.sp, color: Colors.grey.shade600)),
                if (auth.isFournisseur) ...[
                  SizedBox(height: 8.h),
                  Text('Appuyez sur + pour ajouter', style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade500)),
                ],
              ],
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: () => productCtrl.fetchProducts(),
          child: ListView.builder(
            padding: EdgeInsets.all(16.w),
            itemCount: productCtrl.products.length,
            itemBuilder: (ctx, i) => _ProductCard(
              product: productCtrl.products[i],
              isOwner: auth.isFournisseur && productCtrl.products[i].fournisseurId == auth.user?.id,
              onTap: () => Get.to(() => ProductDetailsScreen(product: productCtrl.products[i])),
              onEdit: () async {
                final updated = await Get.to(() => EditProductScreen(product: productCtrl.products[i]));
                if (updated == true) productCtrl.fetchProducts();
              },
              onDelete: () => _confirmDelete(context, productCtrl.products[i], productCtrl),
            ),
          ),
        );
      }),
    );
  }

  Future<void> _confirmClearAll(BuildContext context, AuthController auth, ProductController productCtrl) async {
    final total = productCtrl.products.length;
    if (total == 0) {
      Get.snackbar('Info', 'Aucun produit à supprimer');
      return;
    }
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Vider la liste'),
        content: Text('Supprimer les $total produit(s) ?'),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('Annuler')),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Vider'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      try {
        await productCtrl.clearAllProducts();
        if (context.mounted) Get.snackbar('Succès', 'Liste vidée');
      } catch (e) {
        if (context.mounted) Get.snackbar('Erreur', e.toString());
      }
    }
  }

  Future<void> _confirmDelete(BuildContext context, ProductModel product, ProductController productCtrl) async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Supprimer'),
        content: Text('Supprimer "${product.nom}" ?'),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('Annuler')),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      try {
        await productCtrl.deleteProduct(product.id);
        if (context.mounted) Get.snackbar('Succès', 'Produit supprimé');
      } catch (e) {
        if (context.mounted) Get.snackbar('Erreur', e.toString());
      }
    }
  }
}

class _ProductCard extends StatelessWidget {
  final ProductModel product;
  final bool isOwner;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _ProductCard({
    required this.product,
    this.isOwner = false,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = product.images.isNotEmpty ? '${ApiConfig.serverUrl}${product.images.first}' : null;

    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: imageUrl != null
                    ? Image.network(
                        imageUrl,
                        width: 90.w,
                        height: 90.w,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => _placeholder(90.w, 90.w),
                      )
                    : _placeholder(90.w, 90.w),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.nom,
                      style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      product.fournisseurDisplay,
                      style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade600),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    SizedBox(height: 6.h),
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 4.h,
                      children: [
                        _chip(Icons.inventory, '${product.quantite}', context),
                        _chip(Icons.attach_money, '${product.prixTND} TND', context),
                      ],
                    ),
                  ],
                ),
              ),
              if (isOwner)
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.delete_outline, size: 20.sp, color: Colors.red.shade600),
                      onPressed: onDelete,
                      tooltip: 'Supprimer',
                      style: IconButton.styleFrom(padding: EdgeInsets.all(8.w), minimumSize: Size(36.w, 36.w)),
                    ),
                    IconButton(
                      icon: Icon(Icons.edit_outlined, size: 20.sp, color: Theme.of(context).colorScheme.primary),
                      onPressed: onEdit,
                      tooltip: 'Modifier',
                      style: IconButton.styleFrom(padding: EdgeInsets.all(8.w), minimumSize: Size(36.w, 36.w)),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _placeholder(double w, double h) => Container(
        width: w,
        height: h,
        color: Colors.grey.shade200,
        child: Icon(Icons.image_outlined, size: 32.sp, color: Colors.grey.shade400),
      );

  Widget _chip(IconData icon, String text, BuildContext context) => Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14.sp),
            SizedBox(width: 4.w),
            Text(text, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500)),
          ],
        ),
      );
}
