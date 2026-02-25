class ProductModel {
  final String id;
  final String nom;
  final String fournisseurNom;
  final String fournisseurPrenom;
  final String? fournisseurId;
  final List<String> images;
  final int quantite;
  final double prixTND;
  final DateTime? createdAt;

  ProductModel({
    required this.id,
    required this.nom,
    required this.fournisseurNom,
    required this.fournisseurPrenom,
    this.fournisseurId,
    this.images = const [],
    required this.quantite,
    required this.prixTND,
    this.createdAt,
  });

  String get fournisseurDisplay => '$fournisseurPrenom $fournisseurNom'.trim();

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final imgs = json['images'];
    final list = imgs is List
        ? (imgs).map((e) => e?.toString() ?? '').where((e) => e.isNotEmpty).toList()
        : <String>[];
    return ProductModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      nom: json['nom'] ?? '',
      fournisseurNom: json['fournisseurNom'] ?? '',
      fournisseurPrenom: json['fournisseurPrenom'] ?? '',
      fournisseurId: json['fournisseurId']?.toString(),
      images: list,
      quantite: json['quantite'] is int
          ? json['quantite'] as int
          : (int.tryParse(json['quantite']?.toString() ?? '0') ?? 0),
      prixTND: json['prixTND'] != null
          ? (json['prixTND'] is num ? json['prixTND'].toDouble() : double.tryParse(json['prixTND'].toString()) ?? 0.0)
          : 0.0,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
    );
  }
}
