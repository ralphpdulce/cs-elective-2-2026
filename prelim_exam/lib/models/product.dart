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
    description: 'A fictional story of a band of five heroes who go off on a dragon hunt. It is poorly written and structurally incoherent. Its value lies in the many lessons that can be learned from failure.',
  ),
  Product(
    id: '2',
    name: 'Wind-Powered Wind Generator',
    price: 399.99,
    category: 'Gadgets',
    imageUrl: 'assets/images/wind-powered-wind-generator-banner.png',
    rating: 4.6,
    badge: 'NEW',
    description: 'A wind generating device developed by Refait, senior researcher from Fontaine Research Institute of Kinetic Energy Engineering. In Mondstadt, it is necessary to pass an exam and obtain a license before using a wind glider for travel. The relevant laws and regulations in Fontaine are quite developed, with even clearer rules, and a much stricter process. It would be even better if someone were to enforce them.',
  ),
  Product(
    id: '3',
    name: 'Kagura\'s Verity',
    price: 899.99,
    category: 'Weapons',
    imageUrl: 'assets/images/kaguras-verity-banner.png',
    rating: 4.9,
    description: 'Where once there were dances before the throne, the sounds of the bells still linger. The white silhouette, once something to pursue, never returned, yet it remains an unceasing dream from which one cannot wake...',
  ),
  Product(
    id: '4',
    name: '"The Boon of the Elder Tree"',
    price: 299.99,
    category: 'Gadgets',
    imageUrl: 'assets/images/the-boon-of-the-elder-tree.png',
    rating: 4.4,
    description: 'Talismans of this kind are often seen in the forests in Sumeru. They possess the ability to gather the power of grass and trees. To prevent the erosion of the forest and, in darker times, to resist the invasion of vicious monsters, trees and vines would form impregnable shelters together. Lord Rukkhadevata would grant these talismans to people, giving them unfettered access to walk amidst the forest under the guidance of streams and moonlight. Of course, when Lord Rukkhadevata and the Lord of the Forest died, the labyrinth disappeared, and the forest lost its intellect. Even so, the people of Sumeru take these talismans as symbols of the forest\'s protection — and the forest answers the request of such talismans and gives its power.',
  ),
  Product(
    id: '5',
    name: 'Prithiva Topaz Gemstone',
    price: 1499.99,
    category: 'Gemstones',
    imageUrl: 'assets/images/prithiva-topaz-gemstone.png',
    rating: 5.0,
    badge: 'SALE 15%',
    description: 'Character Ascension material. "The currencies that flow through this land are my flesh and blood. For thus did I become the guarantor of the people\'s hard work, wisdom, and future. This is the trust I have placed in them. Betray it, and you taint my blood."'
  ),
  Product(
    id: '6',
    name: 'Windsong Lyre',
    price: 39.99,
    category: 'Gadgets',
    imageUrl: 'assets/images/windsong-lyre.png',
    rating: 4.3,
    description: 'Use this traditional instrument from Mondstadt to play songs. An instrument of incredible workmanship, it will surely produce moving music when played by able hands.',
  ),
  Product(
    id: '7',
    name: 'Philosophies of Justice',
    price: 499.99,
    category: 'Talent Books',
    imageUrl: 'assets/images/philosophies-of-justice.png',
    rating: 4.7,
    description: 'A comprehensive guide to the principles of justice and fairness.',
  ),
  Product(
    id: '8',
    name: 'Vajrada Amethyst Gemstone',
    price: 1499.99,
    category: 'Gemstones',
    imageUrl: 'assets/images/vajrada-amethyst-gemstone.png',
    rating: 4.2,
    description: 'Character Ascension material. "This body is the noblest and most eminent of all in this world. "It should hold absolute control over this world. "It once promised its people a dream: the never-changing \'eternity.\'"',
  ),
    Product(
    id: '9',
    name: 'The Catch',
    price: 499.99,
    category: 'Weapons',
    imageUrl: 'assets/images/the-catch-banner.png',
    rating: 4.2,
    description: 'The favored barbed spear of a famous Inazuman bandit. It was originally a harpoon used to catch fish, but it was also very handy in battle. They say that he even pierced the enchanted, sword-armed puppet before carrying it off.',
  ),
];