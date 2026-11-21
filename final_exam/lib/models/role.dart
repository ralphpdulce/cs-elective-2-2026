class Role {
  final int id;
  final String role; // 'admin' or 'customer'
  final DateTime? createdAt;
  final String? encodedBy;

  const Role({
    required this.id,
    required this.role,
    this.createdAt,
    this.encodedBy,
  });

  factory Role.fromMap(Map<String, dynamic> map) {
    return Role(
      id: map['id'] is int ? map['id'] as int : int.tryParse(map['id']?.toString() ?? '0') ?? 0,
      role: (map['role'] as String?)?.toLowerCase() ?? 'customer',
      createdAt: map['created_at'] != null ? DateTime.tryParse(map['created_at'].toString()) : null,
      encodedBy: map['encoded_by'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'role': role,
      if (encodedBy != null) 'encoded_by': encodedBy,
    };
  }
}
