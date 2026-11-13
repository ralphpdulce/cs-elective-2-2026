class Product {
  final String id;
  final String name;
  final double price;
  final String category;
  final String? imageUrl;
  final double rating;
  final String? badge;
  final String description;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    this.imageUrl,
    required this.rating,
    this.badge,
    this.description = 'Character available in Paimon\'s Bargains.',
  });

  Product copyWith({
    String? id,
    String? name,
    double? price,
    String? category,
    String? imageUrl,
    double? rating,
    String? badge,
    String? description,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      rating: rating ?? this.rating,
      badge: badge ?? this.badge,
      description: description ?? this.description,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'category': category,
      'image_url': imageUrl,
      'rating': rating,
      'badge': badge,
      'description': description,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: (map['id'] ?? '').toString(),
      name: (map['name'] ?? '') as String,
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      category: (map['category'] ?? 'Anemo') as String,
      imageUrl: (map['image_url'] ?? map['imageUrl']) as String?,
      rating: (map['rating'] as num?)?.toDouble() ?? 4.5,
      badge: map['badge'] as String?,
      description: (map['description'] ??
              'Character available in Paimon\'s Bargains.')
          as String,
    );
  }
}

/// Fallback character catalog used when offline, in unit tests, or before initial API sync.
/// Characters are sourced from Devesh Anand's Genshin Impact API (Railway & Cloudflare R2).
const List<Product> sampleProducts = [
  Product(
    id: 'zhongli',
    name: 'Zhongli',
    price: 1499.99,
    category: 'Geo',
    imageUrl: 'https://pub-1ad979b6618d4a07ab871591a84b954c.r2.dev/zhongli/card.png',
    rating: 5.0,
    badge: '5★ ARCHON',
    description:
        '"Vago Mundo". Zhongli is a 5★ Geo character from Liyue, wielding a Polearm. A consultant of the Wangsheng Funeral Parlor with profound ancient wisdom.',
  ),
  Product(
    id: 'raiden',
    name: 'Raiden Shogun',
    price: 1449.99,
    category: 'Electro',
    imageUrl: 'https://pub-1ad979b6618d4a07ab871591a84b954c.r2.dev/raiden/card.png',
    rating: 5.0,
    badge: '5★ ARCHON',
    description:
        '"Plane of Euthymia". Raiden Shogun is a 5★ Electro character from Inazuma, wielding a Polearm. The supreme ruler of the Inazuma Shogunate who pursues eternity.',
  ),
  Product(
    id: 'furina',
    name: 'Furina',
    price: 1399.99,
    category: 'Hydro',
    imageUrl: 'https://pub-1ad979b6618d4a07ab871591a84b954c.r2.dev/furina/card.png',
    rating: 4.9,
    badge: '5★ ARCHON',
    description:
        '"Endless Solo of Solitude". Furina is a 5★ Hydro character from Fontaine, wielding a Sword. The beloved former Hydro Archon and supreme drama queen of Fontaine.',
  ),
  Product(
    id: 'nahida',
    name: 'Nahida',
    price: 1499.99,
    category: 'Dendro',
    imageUrl: 'https://pub-1ad979b6618d4a07ab871591a84b954c.r2.dev/nahida/card.png',
    rating: 5.0,
    badge: '5★ ARCHON',
    description:
        '"Physic of Purity". Nahida is a 5★ Dendro character from Sumeru, wielding a Catalyst. Lesser Lord Kusanali, who guides her people with boundless curiosity and empathy.',
  ),
  Product(
    id: 'venti',
    name: 'Venti',
    price: 1349.99,
    category: 'Anemo',
    imageUrl: 'https://pub-1ad979b6618d4a07ab871591a84b954c.r2.dev/venti/card.png',
    rating: 4.9,
    badge: '5★ ARCHON',
    description:
        '"Windborne Bard". Venti is a 5★ Anemo character from Mondstadt, wielding a Bow. A carefree bard who loves dandelion wine and wanders the winds of freedom.',
  ),
  Product(
    id: 'hu-tao',
    name: 'Hu Tao',
    price: 1299.99,
    category: 'Pyro',
    imageUrl: 'https://pub-1ad979b6618d4a07ab871591a84b954c.r2.dev/hu-tao/card.png',
    rating: 4.9,
    badge: '5★ LEGENDARY',
    description:
        '"Fragrance in Thaw". Hu Tao is a 5★ Pyro character from Liyue, wielding a Polearm. The 77th Director of the Wangsheng Funeral Parlor, playful yet revered.',
  ),
  Product(
    id: 'neuvillette',
    name: 'Neuvillette',
    price: 1299.99,
    category: 'Hydro',
    imageUrl: 'https://pub-1ad979b6618d4a07ab871591a84b954c.r2.dev/neuvillette/card.png',
    rating: 5.0,
    badge: '5★ LEGENDARY',
    description:
        '"Ordainer of Inexorable Judgment". Neuvillette is a 5★ Hydro character from Fontaine, wielding a Catalyst. The Iudex of Fontaine whose authority echoes through justice.',
  ),
  Product(
    id: 'kazuha',
    name: 'Kaedehara Kazuha',
    price: 1249.99,
    category: 'Anemo',
    imageUrl: 'https://pub-1ad979b6618d4a07ab871591a84b954c.r2.dev/kazuha/card.png',
    rating: 4.9,
    badge: '5★ LEGENDARY',
    description:
        '"Scarlet Leaves Pursue Wild Waves". Kaedehara Kazuha is a 5★ Anemo character from Inazuma, wielding a Sword. A gentle wandering samurai attuned to nature\'s melody.',
  ),
  Product(
    id: 'ayaka',
    name: 'Kamisato Ayaka',
    price: 1199.99,
    category: 'Cryo',
    imageUrl: 'https://pub-1ad979b6618d4a07ab871591a84b954c.r2.dev/ayaka/card.png',
    rating: 4.9,
    badge: '5★ LEGENDARY',
    description:
        '"Frostflake Heron". Kamisato Ayaka is a 5★ Cryo character from Inazuma, wielding a Sword. The noble and elegant Shirasagi Himegimi of the Yashiro Commission.',
  ),
  Product(
    id: 'diluc',
    name: 'Diluc',
    price: 999.99,
    category: 'Pyro',
    imageUrl: 'https://pub-1ad979b6618d4a07ab871591a84b954c.r2.dev/diluc/card.png',
    rating: 4.8,
    badge: '5★ LEGENDARY',
    description:
        '"The Darknight Hero". Diluc is a 5★ Pyro character from Mondstadt, wielding a Claymore. The tycoon of Dawn Winery protecting Mondstadt from the shadows.',
  ),
  Product(
    id: 'alhaitham',
    name: 'Alhaitham',
    price: 1149.99,
    category: 'Dendro',
    imageUrl: 'https://pub-1ad979b6618d4a07ab871591a84b954c.r2.dev/alhaitham/card.png',
    rating: 4.9,
    badge: '5★ LEGENDARY',
    description:
        '"Admonishing Instruction". Alhaitham is a 5★ Dendro character from Sumeru, wielding a Sword. The sharp-minded Scribe of the Sumeru Akademiya.',
  ),
  Product(
    id: 'navia',
    name: 'Navia',
    price: 1099.99,
    category: 'Geo',
    imageUrl: 'https://pub-1ad979b6618d4a07ab871591a84b954c.r2.dev/navia/card.png',
    rating: 4.8,
    badge: '5★ LEGENDARY',
    description:
        '"Helm of the Radiant Rose". Navia is a 5★ Geo character from Fontaine, wielding a Claymore. The resilient and charismatic President of Spina di Rosula.',
  ),
  Product(
    id: 'bennett',
    name: 'Bennett',
    price: 349.99,
    category: 'Pyro',
    imageUrl: 'https://pub-1ad979b6618d4a07ab871591a84b954c.r2.dev/bennett/card.png',
    rating: 4.7,
    badge: '4★ FEATURED',
    description:
        '"Trial by Fire". Bennett is a 4★ Pyro character from Mondstadt, wielding a Sword. The righteous leader of Benny\'s Adventure Team whose optimism defies misfortune.',
  ),
  Product(
    id: 'xingqiu',
    name: 'Xingqiu',
    price: 389.99,
    category: 'Hydro',
    imageUrl: 'https://pub-1ad979b6618d4a07ab871591a84b954c.r2.dev/xingqiu/card.png',
    rating: 4.7,
    badge: '4★ FEATURED',
    description:
        '"Juvenile Galant". Xingqiu is a 4★ Hydro character from Liyue, wielding a Sword. Second son of the Feiyun Commerce Guild and a master of the Guhua sword arts.',
  ),
  Product(
    id: 'xiangling',
    name: 'Xiangling',
    price: 329.99,
    category: 'Pyro',
    imageUrl: 'https://pub-1ad979b6618d4a07ab871591a84b954c.r2.dev/xiangling/card.png',
    rating: 4.6,
    badge: '4★ FEATURED',
    description:
        '"Exquisite Delicacy". Xiangling is a 4★ Pyro character from Liyue, wielding a Polearm. The head chef at Wanmin Restaurant accompanied by the fiery god Guoba.',
  ),
  Product(
    id: 'fischl',
    name: 'Fischl',
    price: 369.99,
    category: 'Electro',
    imageUrl: 'https://pub-1ad979b6618d4a07ab871591a84b954c.r2.dev/fischl/card.png',
    rating: 4.6,
    badge: '4★ FEATURED',
    description:
        '"Prinzessin der Verurteilung!". Fischl is a 4★ Electro character from Mondstadt, wielding a Bow. The investigator of the Adventurers\' Guild guided by Oz the night raven.',
  ),
  Product(
    id: 'sucrose',
    name: 'Sucrose',
    price: 299.99,
    category: 'Anemo',
    imageUrl: 'https://pub-1ad979b6618d4a07ab871591a84b954c.r2.dev/sucrose/card.png',
    rating: 4.5,
    badge: '4★ FEATURED',
    description:
        '"Harmless Sweetie". Sucrose is a 4★ Anemo character from Mondstadt, wielding a Catalyst. An alchemist specializing in bio-alchemy with insatiable curiosity.',
  ),
  Product(
    id: 'ningguang',
    name: 'Ningguang',
    price: 419.99,
    category: 'Geo',
    imageUrl: 'https://pub-1ad979b6618d4a07ab871591a84b954c.r2.dev/ningguang/card.png',
    rating: 4.7,
    badge: '4★ FEATURED',
    description:
        '"Eclipsing Star". Ningguang is a 4★ Geo character from Liyue, wielding a Catalyst. The Tianquan of the Liyue Qixing who commands the floating Jade Chamber.',
  ),
  Product(
    id: 'ganyu',
    name: 'Ganyu',
    price: 1199.99,
    category: 'Cryo',
    imageUrl: 'https://pub-1ad979b6618d4a07ab871591a84b954c.r2.dev/ganyu/card.png',
    rating: 4.9,
    badge: '5★ LEGENDARY',
    description:
        '"Plenilune Gaze". Ganyu is a 5★ Cryo character from Liyue, wielding a Bow. The half-qilin general secretary for the Yuehai Pavilion serving Liyue for millennia.',
  ),
  Product(
    id: 'gaming',
    name: 'Gaming',
    price: 279.99,
    category: 'Pyro',
    imageUrl: 'https://pub-1ad979b6618d4a07ab871591a84b954c.r2.dev/gaming/card.png',
    rating: 4.5,
    badge: '4★ FEATURED',
    description:
        '"Leonine Vanguard". Gaming is a 4★ Pyro character from Liyue, wielding a Claymore. A transport guard for the Sword and Strongbox Secure Transport Agency and Wushou dance artist.',
  ),
];
