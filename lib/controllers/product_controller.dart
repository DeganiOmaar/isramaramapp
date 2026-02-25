import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../models/product_model.dart';
import '../services/product_service.dart';

class ProductController extends GetxController {
  final ProductService _productService = ProductService();

  final RxList<ProductModel> products = <ProductModel>[].obs;
  final _isLoading = false.obs;

  bool get isLoading => _isLoading.value;

  @override
  void onInit() {
    super.onInit();
    fetchProducts();
  }

  Future<void> deleteProduct(String id) async {
    await _productService.deleteProduct(id);
    products.removeWhere((p) => p.id == id);
  }

  Future<void> clearAllMyProducts() async {
    await _productService.deleteAllMyProducts();
    await fetchProducts();
  }

  Future<void> clearAllProducts() async {
    await _productService.deleteAllProducts();
    await fetchProducts();
  }

  Future<void> fetchProducts() async {
    _isLoading.value = true;
    debugPrint('[PRODUCT_CTRL] fetchProducts started');
    try {
      final list = await _productService.getProducts();
      products.assignAll(list);
      debugPrint('[PRODUCT_CTRL] Loaded ${list.length} products');
    } catch (e, st) {
      debugPrint('[PRODUCT_CTRL] Error: $e');
      debugPrint('[PRODUCT_CTRL] Stack: $st');
      products.clear();
    }
    _isLoading.value = false;
  }
}
