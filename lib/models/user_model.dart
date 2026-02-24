class UserModel {
  final String id;
  final String email;
  final String? nom;
  final String? prenom;
  final String? role;
  final bool registrationComplete;
  final String? societeNom;
  final String? produitAVendre;
  final String? descriptionActivite;

  UserModel({
    required this.id,
    required this.email,
    this.nom,
    this.prenom,
    this.role,
    this.registrationComplete = false,
    this.societeNom,
    this.produitAVendre,
    this.descriptionActivite,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      email: json['email'] ?? '',
      nom: json['nom'],
      prenom: json['prenom'],
      role: json['role'],
      registrationComplete: json['registrationComplete'] ?? false,
      societeNom: json['societeNom'],
      produitAVendre: json['produitAVendre'],
      descriptionActivite: json['descriptionActivite'],
    );
  }

  String get displayName {
    if (nom != null && prenom != null) return '$prenom $nom';
    if (nom != null) return nom!;
    if (prenom != null) return prenom!;
    return email;
  }
}
