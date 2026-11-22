class Profile {
  final String id;
  final String email;
  final String firstname;
  final String lastname;
  final int roleId;
  final String roleName; // 'customer' or 'admin'
  final DateTime? createdAt;

  const Profile({
    required this.id,
    required this.email,
    this.firstname = '',
    this.lastname = '',
    required this.roleId,
    this.roleName = 'customer',
    this.createdAt,
  });

  String get fullName {
    final combined = '$firstname $lastname'.trim();
    if (combined.isNotEmpty) return combined;
    if (email.contains('@')) return email.split('@').first;
    return 'Traveler';
  }

  bool get isAdmin => roleName.toLowerCase() == 'admin' || roleId == 2;
  bool get isCustomer => !isAdmin;

  factory Profile.fromMap(Map<String, dynamic> map) {
    String resolvedRole = 'customer';
    final roleData = map['roles'] ?? map['role'];
    if (roleData is Map) {
      resolvedRole = (roleData['role'] as String?)?.toLowerCase() ?? 'customer';
    } else if (map['role_name'] != null) {
      resolvedRole = (map['role_name'] as String).toLowerCase();
    } else if (map['role'] is String) {
      resolvedRole = (map['role'] as String).toLowerCase();
    }

    final rawRoleId = map['role_id'];
    int parsedRoleId = 1;
    if (rawRoleId is int) {
      parsedRoleId = rawRoleId;
    } else if (rawRoleId != null) {
      parsedRoleId = int.tryParse(rawRoleId.toString()) ?? 1;
    }

    if (resolvedRole == 'admin' && parsedRoleId != 2) {
      parsedRoleId = 2;
    }

    return Profile(
      id: map['id']?.toString() ?? '',
      email: map['email'] as String? ?? '',
      firstname: map['firstname'] as String? ?? '',
      lastname: map['lastname'] as String? ?? '',
      roleId: parsedRoleId,
      roleName: resolvedRole,
      createdAt: map['created_at'] != null ? DateTime.tryParse(map['created_at'].toString()) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'firstname': firstname,
      'lastname': lastname,
      'role_id': roleId,
    };
  }

  Profile copyWith({
    String? id,
    String? email,
    String? firstname,
    String? lastname,
    int? roleId,
    String? roleName,
    DateTime? createdAt,
  }) {
    return Profile(
      id: id ?? this.id,
      email: email ?? this.email,
      firstname: firstname ?? this.firstname,
      lastname: lastname ?? this.lastname,
      roleId: roleId ?? this.roleId,
      roleName: roleName ?? this.roleName,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
