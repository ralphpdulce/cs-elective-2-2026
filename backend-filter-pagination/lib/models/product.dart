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
    this.description = 'High quality Jiafei Products for your everyday needs.',
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
      category: (map['category'] ?? 'General') as String,
      imageUrl: (map['image_url'] ?? map['imageUrl']) as String?,
      rating: (map['rating'] as num?)?.toDouble() ?? 4.5,
      badge: map['badge'] as String?,
      description: (map['description'] ??
              'High quality Jiafei Products for your everyday needs.')
          as String,
    );
  }
}

const List<Product> sampleProducts = [
  Product(
    id: '1',
    name: 'Thrilling Tales of Dragon Slayers',
    price: 99.99,
    category: 'Weapons',
    imageUrl: 'assets/images/thrilling-tales-of-dragon-slayers-banner.png',
    rating: 4.8,
    badge: 'BESTSELLER',
    description:
        'A fictional story of a band of five heroes who go off on a dragon hunt. It is poorly written and structurally incoherent. Its value lies in the many lessons that can be learned from failure.',
  ),
  Product(
    id: '2',
    name: 'Wind-Powered Wind Generator',
    price: 399.99,
    category: 'Gadgets',
    imageUrl: 'assets/images/wind-powered-wind-generator-banner.png',
    rating: 4.6,
    badge: 'NEW',
    description:
        'A wind generating device developed by Refait, senior researcher from Fontaine Research Institute of Kinetic Energy Engineering.',
  ),
  Product(
    id: '3',
    name: "Kagura's Verity",
    price: 899.99,
    category: 'Weapons',
    imageUrl: 'assets/images/kaguras-verity-banner.png',
    rating: 4.9,
    description:
        'Where once there were dances before the throne, the sounds of the bells still linger. The white silhouette, once something to pursue, never returned, yet it remains an unceasing dream.',
  ),
  Product(
    id: '4',
    name: '"The Boon of the Elder Tree"',
    price: 299.99,
    category: 'Gadgets',
    imageUrl: 'assets/images/the-boon-of-the-elder-tree.png',
    rating: 4.4,
    description:
        'Talismans of this kind are often seen in the forests in Sumeru. They possess the ability to gather the power of grass and trees.',
  ),
  Product(
    id: '5',
    name: 'Prithiva Topaz Gemstone',
    price: 1499.99,
    category: 'Gemstones',
    imageUrl: 'assets/images/prithiva-topaz-gemstone.png',
    rating: 5.0,
    badge: 'SALE 15%',
    description:
        'Character Ascension material. "The currencies that flow through this land are my flesh and blood. For thus did I become the guarantor of the people\'s hard work, wisdom, and future."',
  ),
  Product(
    id: '6',
    name: 'Windsong Lyre',
    price: 39.99,
    category: 'Gadgets',
    imageUrl: 'assets/images/windsong-lyre.png',
    rating: 4.3,
    description:
        'Use this traditional instrument from Mondstadt to play songs. An instrument of incredible workmanship, it will surely produce moving music when played by able hands.',
  ),
  Product(
    id: '7',
    name: 'Philosophies of Justice',
    price: 499.99,
    category: 'Talent Books',
    imageUrl: 'assets/images/philosophies-of-justice.png',
    rating: 4.7,
    description:
        'A comprehensive guide to the principles of justice and fairness in the court of Fontaine.',
  ),
  Product(
    id: '8',
    name: 'Vajrada Amethyst Gemstone',
    price: 1499.99,
    category: 'Gemstones',
    imageUrl: 'assets/images/vajrada-amethyst-gemstone.png',
    rating: 4.2,
    description:
        'Character Ascension material. "This body is the noblest and most eminent of all in this world. It should hold absolute control over this world."',
  ),
  Product(
    id: '9',
    name: 'The Catch',
    price: 499.99,
    category: 'Weapons',
    imageUrl: 'assets/images/the-catch-banner.png',
    rating: 4.2,
    badge: 'HOT',
    description:
        'The favored barbed spear of a famous Inazuman bandit. It was originally a harpoon used to catch fish, but it was also very handy in battle.',
  ),
  Product(
    id: '10',
    name: 'Electro Treasure Compass',
    price: 249.99,
    category: 'Gadgets',
    imageUrl: 'assets/images/electro-treasure-compass-banner.png',
    rating: 4.5,
    description:
        'A handy tool used in Inazuma to search for nearby chests. Points toward the closest chest in the vicinity.',
  ),
  Product(
    id: '11',
    name: 'Philosophies of Transience',
    price: 549.99,
    category: 'Talent Books',
    imageUrl: 'assets/images/philosophies-of-transience.png',
    rating: 4.8,
    description:
        'Transience is the dream of the nation of thunder. Fleeting youth and fleeting beauty must be treasured.',
  ),
  Product(
    id: '12',
    name: 'Ultra-Hot Burner Lamp (Test Model)',
    price: 189.99,
    category: 'Gadgets',
    imageUrl: 'assets/images/ultra-hot-burner-lamp-test-model.png',
    rating: 4.1,
    description:
        'An experimental burner device that accelerates food processing efficiency through high-temperature ore fuel.',
  ),
  Product(
    id: '13',
    name: 'A Thousand Floating Dreams',
    price: 1099.99,
    category: 'Weapons',
    imageUrl: 'assets/images/kaguras-verity-banner.png',
    rating: 4.9,
    badge: 'BESTSELLER',
    description:
        'A lamp that shines with the light of dreams of a thousand nights, passed down through the ages.',
  ),
  Product(
    id: '14',
    name: 'Vayuda Turquoise Gemstone',
    price: 1399.99,
    category: 'Gemstones',
    imageUrl: 'assets/images/prithiva-topaz-gemstone.png',
    rating: 4.7,
    description:
        'Character Ascension material. "Still, the winds change direction. Someday, they will blow towards a brighter future."',
  ),
  Product(
    id: '15',
    name: 'Shivada Jade Gemstone',
    price: 1450.00,
    category: 'Gemstones',
    imageUrl: 'assets/images/vajrada-amethyst-gemstone.png',
    rating: 4.6,
    description:
        'Character Ascension material. "Sorry... to also have you shoulder the grievances of the world."',
  ),
  Product(
    id: '16',
    name: 'Philosophies of Diligence',
    price: 450.00,
    category: 'Talent Books',
    imageUrl: 'assets/images/philosophies-of-justice.png',
    rating: 4.5,
    description:
        'Diligence is the foundation of the city of rock. Industry and perseverance pave the road to prosperity.',
  ),
];

