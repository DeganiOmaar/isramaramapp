import 'dart:convert';

import 'package:get/get.dart';

import '../models/cart_item_model.dart';
import '../models/product_model.dart';
import '../services/storage_service.dart';

class CartController extends GetxController {
  final RxList<CartItemModel> _items = <CartItemModel>[].obs;

  List<CartItemModel> get items => _items;

  int get itemCount => _items.fold<int>(0, (sum, i) => sum + i.quantite);

  double get totalAmount => _items.fold<double>(0, (sum, i) => sum + i.sousTotal);

  @override
  void onInit() {
    super.onInit();
    _loadCart();
  }

  Future<void> _loadCart() async {
    final json = await StorageService.getCartJson();
    if (json == null || json.isEmpty) return;
    try {
      final list = jsonDecode(json) as List<dynamic>?;
      if (list == null) return;
      _items.assignAll(
        list
            .whereType<Map<String, dynamic>>()
            .map((m) => CartItemModel.fromJson(m))
            .toList(),
      );
    } catch (_) {
      _items.clear();
    }
  }

  Future<void> _persistCart() async {
    final list = _items.map((i) => i.toJson()).toList();
    await StorageService.saveCartJson(jsonEncode(list));
  }

  void addToCart(ProductModel product, int quantite) {
    if (quantite < 1) return;
    final idx = _items.indexWhere((i) => i.product.id == product.id);
    if (idx >= 0) {
      final existing = _items[idx];
      final newQty = existing.quantite + quantite;
      final maxQty = product.quantite;
      _items[idx] = CartItemModel(
        product: product,
        quantite: newQty > maxQty ? maxQty : newQty,
      );
    } else {
      final maxQty = product.quantite;
      _items.add(CartItemModel(
        product: product,
        quantite: quantite > maxQty ? maxQty : quantite,
      ));
    }
    _persistCart();
  }

  void updateQuantity(String productId, int quantite) {
    if (quantite < 1) {
      removeFromCart(productId);
      return;
    }
    final idx = _items.indexWhere((i) => i.product.id == productId);
    if (idx < 0) return;
    final item = _items[idx];
    final maxQty = item.product.quantite;
    _items[idx] = CartItemModel(
      product: item.product,
      quantite: quantite > maxQty ? maxQty : quantite,
    );
    _persistCart();
  }

  void removeFromCart(String productId) {
    _items.removeWhere((i) => i.product.id == productId);
    _persistCart();
  }

  void clearCart() {
    _items.clear();
    _persistCart();
  }
}
