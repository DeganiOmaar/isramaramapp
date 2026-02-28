import 'product_model.dart';

class CartItemModel {
  final ProductModel product;
  final int quantite;

  CartItemModel({required this.product, required this.quantite});

  double get sousTotal => product.prixTND * quantite;

  Map<String, dynamic> toJson() => {
        'product': {
          'id': product.id,
          'nom': product.nom,
          'fournisseurNom': product.fournisseurNom,
          'fournisseurPrenom': product.fournisseurPrenom,
          'fournisseurId': product.fournisseurId,
          'images': product.images,
          'quantite': product.quantite,
          'prixTND': product.prixTND,
        },
        'quantite': quantite,
      };

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    final p = json['product'];
    if (p == null || p is! Map<String, dynamic>) {
      throw ArgumentError('Invalid cart item: product required');
    }
    return CartItemModel(
      product: ProductModel.fromJson(Map<String, dynamic>.from(p)),
      quantite: (json['quantite'] is int)
          ? json['quantite'] as int
          : (int.tryParse(json['quantite']?.toString() ?? '1') ?? 1),
    );
  }
}
