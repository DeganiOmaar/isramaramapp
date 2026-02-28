class OrderItemModel {
  final String productId;
  final String productNom;
  final String fournisseurId;
  final int quantite;
  final double prixUnitaireTND;

  OrderItemModel({
    required this.productId,
    required this.productNom,
    required this.fournisseurId,
    required this.quantite,
    required this.prixUnitaireTND,
  });

  double get sousTotal => quantite * prixUnitaireTND;

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      productId: json['productId']?.toString() ?? '',
      productNom: json['productNom'] ?? '',
      fournisseurId: json['fournisseurId']?.toString() ?? '',
      quantite: json['quantite'] is int ? json['quantite'] as int : int.tryParse(json['quantite']?.toString() ?? '0') ?? 0,
      prixUnitaireTND: json['prixUnitaireTND'] != null
          ? (json['prixUnitaireTND'] is num ? (json['prixUnitaireTND'] as num).toDouble() : double.tryParse(json['prixUnitaireTND'].toString()) ?? 0)
          : 0,
    );
  }
}

class OrderModel {
  final String id;
  final String clientId;
  final String? clientNom;
  final String? clientPrenom;
  final List<OrderItemModel> items;
  final double montantTotalTND;
  final String status; // nouvelle, pending, refusee
  final String fournisseurId;
  final DateTime? createdAt;
  final String? fournisseurNom;
  final String? fournisseurPrenom;

  OrderModel({
    required this.id,
    required this.clientId,
    this.clientNom,
    this.clientPrenom,
    required this.items,
    required this.montantTotalTND,
    required this.status,
    required this.fournisseurId,
    this.createdAt,
    this.fournisseurNom,
    this.fournisseurPrenom,
  });

  String get statusDisplay {
    switch (status) {
      case 'nouvelle':
        return 'En attente';
      case 'pending':
        return 'Acceptée (en cours)';
      case 'refusee':
        return 'Refusée';
      default:
        return status;
    }
  }

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final itemsList = json['items'];
    final items = itemsList is List
        ? itemsList.map((e) => OrderItemModel.fromJson(Map<String, dynamic>.from(e as Map))).toList()
        : <OrderItemModel>[];
    return OrderModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      clientId: json['clientId']?.toString() ?? '',
      clientNom: json['clientNom']?.toString(),
      clientPrenom: json['clientPrenom']?.toString(),
      items: items,
      montantTotalTND: json['montantTotalTND'] != null
          ? (json['montantTotalTND'] is num ? (json['montantTotalTND'] as num).toDouble() : double.tryParse(json['montantTotalTND'].toString()) ?? 0)
          : 0,
      status: json['status'] ?? 'nouvelle',
      fournisseurId: json['fournisseurId']?.toString() ?? '',
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
      fournisseurNom: json['fournisseurNom']?.toString(),
      fournisseurPrenom: json['fournisseurPrenom']?.toString(),
    );
  }
}
