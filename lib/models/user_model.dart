class UserModel {
  final String id;
  final String name;
  final String email;
  final bool admin; // Changed from role to admin boolean
  final DateTime created;
  final DateTime updated;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.admin,
    required this.created,
    required this.updated,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      admin: json['admin'] ?? false, // Default to false if not specified
      created: DateTime.parse(json['created'] ?? DateTime.now().toIso8601String()),
      updated: DateTime.parse(json['updated'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'admin': admin,
      'created': created.toIso8601String(),
      'updated': updated.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    bool? admin,
    DateTime? created,
    DateTime? updated,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      admin: admin ?? this.admin,
      created: created ?? this.created,
      updated: updated ?? this.updated,
    );
  }
}
