import 'dart:convert';

class Product {
  final int id;
  final String name;
  final double price;
  final int stock;
  final int? categoryId;
  final String? categoryName;
  final String? imageUrl;
  final double rating;
  final String? badge;
  final String description;
  final DateTime? createdAt;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    this.stock = 10,
    this.categoryId,
    this.categoryName,
    this.imageUrl,
    this.rating = 4.8,
    this.badge,
    this.description = 'Item available in Paimon\'s Bargains.',
    this.createdAt,
  });

  bool get isOutOfStock => stock <= 0;

  Product copyWith({
    int? id,
    String? name,
    double? price,
    int? stock,
    int? categoryId,
    String? categoryName,
    String? imageUrl,
    double? rating,
    String? badge,
    String? description,
    DateTime? createdAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      imageUrl: imageUrl ?? this.imageUrl,
      rating: rating ?? this.rating,
      badge: badge ?? this.badge,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap({bool includeId = true}) {
    // Embed metadata tag into description so rating and badge are persisted cleanly in PostgreSQL
    final meta = <String, dynamic>{
      'rating': rating,
      if (badge != null && badge!.isNotEmpty) 'badge': badge,
    };
    final cleanDesc = description.replaceAll(RegExp(r'\n?<!--meta:.*?-->'), '').trim();
    final encodedDesc = '$cleanDesc\n<!--meta:${jsonEncode(meta)}-->';

    final map = <String, dynamic>{
      'name': name,
      'price': price,
      'stock': stock,
      'category_id': categoryId,
      'image_url': imageUrl,
      'description': encodedDesc,
    };
    if (includeId && id > 0) {
      map['id'] = id;
    }
    return map;
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    int parsedId = 0;
    final rawId = map['id'];
    if (rawId is int) {
      parsedId = rawId;
    } else if (rawId != null) {
      parsedId = int.tryParse(rawId.toString()) ?? 0;
    }

    int? parsedCatId;
    final rawCatId = map['category_id'];
    if (rawCatId is int) {
      parsedCatId = rawCatId;
    } else if (rawCatId != null) {
      parsedCatId = int.tryParse(rawCatId.toString());
    }

    String? catName = map['category'] as String?;
    final categoriesData = map['categories'];
    if (categoriesData is Map && categoriesData['name'] != null) {
      catName = categoriesData['name'] as String;
    }

    double parsedRating = 4.8;
    String? parsedBadge = map['badge'] as String?;
    String cleanDesc = (map['description'] ?? 'Item available in Paimon\'s Bargains.') as String;

    if (map['rating'] != null) {
      parsedRating = (map['rating'] as num).toDouble();
    }

    // Extract embedded metadata from description comment if present
    final metaRegex = RegExp(r'\n?<!--meta:(.*?)-->');
    final match = metaRegex.firstMatch(cleanDesc);
    if (match != null) {
      try {
        final jsonStr = match.group(1);
        if (jsonStr != null) {
          final decoded = jsonDecode(jsonStr);
          if (decoded is Map) {
            if (map['rating'] == null && decoded['rating'] != null) {
              parsedRating = (decoded['rating'] as num).toDouble();
            }
            if (parsedBadge == null && decoded['badge'] != null) {
              parsedBadge = decoded['badge'].toString();
            }
          }
        }
      } catch (_) {}
      cleanDesc = cleanDesc.replaceAll(metaRegex, '').trim();
    }

    return Product(
      id: parsedId,
      name: (map['name'] ?? '') as String,
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      stock: (map['stock'] as num?)?.toInt() ?? 0,
      categoryId: parsedCatId,
      categoryName: catName ?? 'General',
      imageUrl: (map['image_url'] ?? map['imageUrl']) as String?,
      rating: parsedRating,
      badge: parsedBadge,
      description: cleanDesc,
      createdAt: map['created_at'] != null ? DateTime.tryParse(map['created_at'].toString()) : null,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Product && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Fallback catalog seeded with Genshin Impact lore & assets
const List<Product> sampleFinalExamProducts = [
  Product(
    id: 1,
    name: 'Zhongli',
    price: 1499.99,
    stock: 25,
    categoryId: 10,
    categoryName: 'Geo',
    imageUrl: 'https://enka.network/ui/UI_AvatarIcon_Zhongli_Card.png',
    rating: 5.0,
    badge: '5★ ARCHON',
    description: 'A mysterious expert contracted by the Wangsheng Funeral Parlor. Extremely knowledgeable in all things.',
  ),
  Product(
    id: 2,
    name: 'Raiden Shogun',
    price: 1499.99,
    stock: 30,
    categoryId: 7,
    categoryName: 'Electro',
    imageUrl: 'https://enka.network/ui/UI_AvatarIcon_Shougun_Card.png',
    rating: 5.0,
    badge: '5★ ARCHON',
    description: 'Her Excellency, the Almighty Narukami Ogosho, who promised the people of Inazuma an unchanging Eternity.',
  ),
  Product(
    id: 3,
    name: 'Furina',
    price: 1499.99,
    stock: 20,
    categoryId: 5,
    categoryName: 'Hydro',
    imageUrl: 'https://enka.network/ui/UI_AvatarIcon_Furina_Card.png',
    rating: 5.0,
    badge: '5★ ARCHON',
    description: 'The absolute focus of the stage of judgment, until the final applause sounds.',
  ),
  Product(
    id: 4,
    name: 'Nahida',
    price: 1499.99,
    stock: 22,
    categoryId: 8,
    categoryName: 'Dendro',
    imageUrl: 'https://enka.network/ui/UI_AvatarIcon_Nahida_Card.png',
    rating: 5.0,
    badge: '5★ ARCHON',
    description: 'A caged bird secluded within the confines of the Sanctuary of Surasthana who can only see the world in her dreams.',
  ),
  Product(
    id: 5,
    name: 'Venti',
    price: 1499.99,
    stock: 18,
    categoryId: 6,
    categoryName: 'Anemo',
    imageUrl: 'https://enka.network/ui/UI_AvatarIcon_Venti_Card.png',
    rating: 5.0,
    badge: '5★ ARCHON',
    description: 'One of the many bards of Mondstadt, who freely wanders the city streets and alleys.',
  ),
  Product(
    id: 6,
    name: 'Hu Tao',
    price: 1199.99,
    stock: 15,
    categoryId: 4,
    categoryName: 'Pyro',
    imageUrl: 'https://enka.network/ui/UI_AvatarIcon_Hutao_Card.png',
    rating: 4.9,
    badge: '5★ LEGENDARY',
    description: 'The 77th Director of the Wangsheng Funeral Parlor. She took over the business at a rather young age.',
  ),
  Product(
    id: 7,
    name: 'Neuvillette',
    price: 1199.99,
    stock: 28,
    categoryId: 5,
    categoryName: 'Hydro',
    imageUrl: 'https://enka.network/ui/UI_AvatarIcon_Neuvillette_Card.png',
    rating: 4.9,
    badge: '5★ LEGENDARY',
    description: 'The Chief Justice of Fontaine, known as the Iudex, is renowned for his unassailable impartiality.',
  ),
  Product(
    id: 8,
    name: 'Kaedehara Kazuha',
    price: 1199.99,
    stock: 14,
    categoryId: 6,
    categoryName: 'Anemo',
    imageUrl: 'https://enka.network/ui/UI_AvatarIcon_Kazuha_Card.png',
    rating: 4.9,
    badge: '5★ LEGENDARY',
    description: 'A wandering samurai from Inazuma who is currently with Liyue Crux Fleet.',
  ),
  Product(
    id: 9,
    name: 'Kamisato Ayaka',
    price: 1199.99,
    stock: 12,
    categoryId: 9,
    categoryName: 'Cryo',
    imageUrl: 'https://enka.network/ui/UI_AvatarIcon_Ayaka_Card.png',
    rating: 4.9,
    badge: '5★ LEGENDARY',
    description: 'Daughter of the Yashiro Commission Kamisato Clan. Dignified and elegant.',
  ),
  Product(
    id: 10,
    name: 'Diluc',
    price: 1199.99,
    stock: 10,
    categoryId: 4,
    categoryName: 'Pyro',
    imageUrl: 'https://enka.network/ui/UI_AvatarIcon_Diluc_Card.png',
    rating: 4.9,
    badge: '5★ LEGENDARY',
    description: 'The tycoon of a winery empire in Mondstadt, unmatched in every possible way.',
  ),
  Product(
    id: 11,
    name: 'Alhaitham',
    price: 1199.99,
    stock: 16,
    categoryId: 8,
    categoryName: 'Dendro',
    imageUrl: 'https://enka.network/ui/UI_AvatarIcon_Alhatham_Card.png',
    rating: 4.9,
    badge: '5★ LEGENDARY',
    description: 'The current scribe of the Sumeru Akademiya, endowed with extraordinary intelligence.',
  ),
  Product(
    id: 12,
    name: 'Navia',
    price: 1199.99,
    stock: 19,
    categoryId: 10,
    categoryName: 'Geo',
    imageUrl: 'https://enka.network/ui/UI_AvatarIcon_Navia_Card.png',
    rating: 4.9,
    badge: '5★ LEGENDARY',
    description: 'The current President of Spina di Rosula, lovely, dutiful, and a great boss.',
  ),
  Product(
    id: 13,
    name: 'Bennett',
    price: 349.99,
    stock: 40,
    categoryId: 4,
    categoryName: 'Pyro',
    imageUrl: 'https://enka.network/ui/UI_AvatarIcon_Bennett_Card.png',
    rating: 4.6,
    badge: '4★ FEATURED',
    description: 'A good-natured adventurer from Mondstadt who is unfortunately extremely unlucky.',
  ),
  Product(
    id: 14,
    name: 'Xingqiu',
    price: 349.99,
    stock: 35,
    categoryId: 5,
    categoryName: 'Hydro',
    imageUrl: 'https://enka.network/ui/UI_AvatarIcon_Xingqiu_Card.png',
    rating: 4.6,
    badge: '4★ FEATURED',
    description: 'A young man carrying a longsword frequently seen at book booths in Liyue.',
  ),
  Product(
    id: 15,
    name: 'Xiangling',
    price: 349.99,
    stock: 50,
    categoryId: 4,
    categoryName: 'Pyro',
    imageUrl: 'https://enka.network/ui/UI_AvatarIcon_Xiangling_Card.png',
    rating: 4.6,
    badge: '4★ FEATURED',
    description: 'A renowned chef from Liyue passionate about hot and spicy culinary wonders.',
  ),
  Product(
    id: 16,
    name: 'Mistsplitter Reforged',
    price: 899.99,
    stock: 8,
    categoryId: 2,
    categoryName: 'Weapons',
    imageUrl: 'https://enka.network/ui/UI_EquipIcon_Sword_Narukami.png',
    rating: 4.9,
    badge: '5★ WEAPON',
    description: 'A sword that blazes with a fierce violet light. One of the finest weapons in Teyvat.',
  ),
  Product(
    id: 17,
    name: 'Engulfing Lightning',
    price: 899.99,
    stock: 10,
    categoryId: 2,
    categoryName: 'Weapons',
    imageUrl: 'https://enka.network/ui/UI_EquipIcon_Pole_Narukami.png',
    rating: 4.9,
    badge: '5★ WEAPON',
    description: 'A naginata used to cut grass. Any army that stands before it will be cut down.',
  ),
  Product(
    id: 18,
    name: 'Amos Bow',
    price: 899.99,
    stock: 6,
    categoryId: 2,
    categoryName: 'Weapons',
    imageUrl: 'https://enka.network/ui/UI_EquipIcon_Bow_Amos.png',
    rating: 4.9,
    badge: '5★ WEAPON',
    description: 'An ancient bow that draws power from everyone and everything in the world.',
  ),
  Product(
    id: 19,
    name: 'Prithiva Topaz Gemstone',
    price: 149.99,
    stock: 100,
    categoryId: 3,
    categoryName: 'Materials',
    imageUrl: 'https://enka.network/ui/UI_ItemIcon_104174.png',
    rating: 4.8,
    badge: 'GEMSTONE',
    description: 'Character Ascension material. The currencies that flow through this land are my flesh and blood.',
  ),
  Product(
    id: 20,
    name: 'Shivada Jade Gemstone',
    price: 149.99,
    stock: 85,
    categoryId: 3,
    categoryName: 'Materials',
    imageUrl: 'https://enka.network/ui/UI_ItemIcon_104164.png',
    rating: 4.8,
    badge: 'GEMSTONE',
    description: 'Character Ascension material. Since you could endure my bitter cold, burn away the old world for me.',
  ),
];
