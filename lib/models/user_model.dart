class UserModel {
  final String id;
  final String name;
  final String email;
  final String? avatar;
  final bool admin;
  final DateTime created;
  final DateTime updated;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.avatar,
    required this.admin,
    required this.created,
    required this.updated,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      avatar: json['avatar'],
      admin: json['admin'] ?? false,
      created: DateTime.parse(json['created'] ?? DateTime.now().toIso8601String()),
      updated: DateTime.parse(json['updated'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatar': avatar,
      'admin': admin,
      'created': created.toIso8601String(),
      'updated': updated.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? avatar,
    bool? admin,
    DateTime? created,
    DateTime? updated,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
      admin: admin ?? this.admin,
      created: created ?? this.created,
      updated: updated ?? this.updated,
    );
  }

  // Get avatar URL
  String getAvatarUrl() {
    if (avatar == null || avatar!.isEmpty) {
      return '';
    }
    return 'https://grbk-production.up.railway.app/api/files/users/$id/$avatar';
  }
}