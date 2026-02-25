import 'package:flutter/foundation.dart';
import '../models/product_model.dart';
import '../services/api_service.dart';

class ProductService {
  final ApiService _api = ApiService();

  Future<List<ProductModel>> getProducts() async {
    debugPrint('[PRODUCT_SERVICE] GET /products');
    final res = await _api.get('/products');
    final list = res['products'] as List? ?? [];
    debugPrint('[PRODUCT_SERVICE] Received ${list.length} products');
    return list.map((e) => ProductModel.fromJson(Map<String, dynamic>.from(e))).toList();
  }

  Future<void> updateProduct(String id, {required String nom, required int quantite, required double prixTND}) async {
    await _api.put('/products/$id', {'nom': nom, 'quantite': quantite, 'prixTND': prixTND});
  }

  Future<void> deleteProduct(String id) async {
    await _api.delete('/products/$id');
  }

  Future<void> deleteAllMyProducts() async {
    await _api.delete('/products/mine');
  }

  Future<void> deleteAllProducts() async {
    await _api.delete('/products/all');
  }
}
