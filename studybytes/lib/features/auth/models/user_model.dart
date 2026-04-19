class UserModel {
  final String id;
  final String email;
  final String name;
  final String? photoUrl;
  final bool isPremium;
  final DateTime createdAt;
  final DateTime? premiumUntil;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.photoUrl,
    this.isPremium = false,
    required this.createdAt,
    this.premiumUntil,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      photoUrl: json['photoUrl'],
      isPremium: json['isPremium'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      premiumUntil: json['premiumUntil'] != null
          ? DateTime.parse(json['premiumUntil'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'name': name,
        'photoUrl': photoUrl,
        'isPremium': isPremium,
        'createdAt': createdAt.toIso8601String(),
        'premiumUntil': premiumUntil?.toIso8601String(),
      };

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? photoUrl,
    bool? isPremium,
    DateTime? createdAt,
    DateTime? premiumUntil,
  }) =>
      UserModel(
        id: id ?? this.id,
        email: email ?? this.email,
        name: name ?? this.name,
        photoUrl: photoUrl ?? this.photoUrl,
        isPremium: isPremium ?? this.isPremium,
        createdAt: createdAt ?? this.createdAt,
        premiumUntil: premiumUntil ?? this.premiumUntil,
      );
}
