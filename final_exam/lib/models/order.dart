class OrderItem {
  final int id;
  final int orderId;
  final int? productId;
  final String productName;
  final double unitPrice;
  final int quantity;
  final DateTime? createdAt;

  const OrderItem({
    required this.id,
    required this.orderId,
    this.productId,
    required this.productName,
    required this.unitPrice,
    required this.quantity,
    this.createdAt,
  });

  double get subtotal => unitPrice * quantity;

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      id: map['id'] is int ? map['id'] as int : int.tryParse(map['id']?.toString() ?? '0') ?? 0,
      orderId: map['order_id'] is int ? map['order_id'] as int : int.tryParse(map['order_id']?.toString() ?? '0') ?? 0,
      productId: map['product_id'] is int ? map['product_id'] as int : int.tryParse(map['product_id']?.toString() ?? ''),
      productName: (map['product_name'] ?? 'Product') as String,
      unitPrice: (map['unit_price'] as num?)?.toDouble() ?? 0.0,
      quantity: (map['quantity'] as num?)?.toInt() ?? 1,
      createdAt: map['created_at'] != null ? DateTime.tryParse(map['created_at'].toString()) : null,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'order_id': orderId,
    'product_id': productId,
    'product_name': productName,
    'unit_price': unitPrice,
    'quantity': quantity,
  };
}

class Order {
  final int id;
  final String userId;
  final String status; // 'done', 'pending', etc.
  final double total;
  final DateTime? createdAt;
  final List<OrderItem> items;
  final String? customerEmail;
  final String? customerName;

  const Order({
    required this.id,
    required this.userId,
    this.status = 'done',
    required this.total,
    this.createdAt,
    this.items = const [],
    this.customerEmail,
    this.customerName,
  });

  int get totalItemCount => items.fold(0, (sum, item) => sum + item.quantity);

  factory Order.fromMap(Map<String, dynamic> map) {
    final rawItems = map['order_items'] as List<dynamic>? ?? [];
    final parsedItems = rawItems
        .map((item) => OrderItem.fromMap(Map<String, dynamic>.from(item as Map)))
        .toList();

    String? email;
    String? name;
    final profileData = map['profiles'];
    if (profileData is Map) {
      email = profileData['email'] as String?;
      final first = profileData['firstname'] as String? ?? '';
      final last = profileData['lastname'] as String? ?? '';
      final combined = '$first $last'.trim();
      if (combined.isNotEmpty) name = combined;
    }

    return Order(
      id: map['id'] is int ? map['id'] as int : int.tryParse(map['id']?.toString() ?? '0') ?? 0,
      userId: map['user_id']?.toString() ?? '',
      status: (map['status'] ?? 'done') as String,
      total: (map['total'] as num?)?.toDouble() ?? 0.0,
      createdAt: map['created_at'] != null ? DateTime.tryParse(map['created_at'].toString()) : null,
      items: parsedItems,
      customerEmail: email,
      customerName: name,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'user_id': userId,
    'status': status,
    'total': total,
  };
}
