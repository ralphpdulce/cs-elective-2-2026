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
    this.description = 'Item available in Paimon\'s Bargains.',
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
              'Item available in Paimon\'s Bargains.')
          as String,
    );
  }
}

/// Fallback comprehensive store catalog: Characters, Weapons, & Materials
/// Sourced from Genshin API & Enka Network CDN.
const List<Product> sampleProducts = [
  Product(
    id: 'char-zhongli',
    name: 'Zhongli',
    price: 1499.99,
    category: 'Geo',
    imageUrl: 'https://enka.network/ui/UI_AvatarIcon_Zhongli_Card.png',
    rating: 5.0,
    badge: '5★ ARCHON',
    description:
        'A mysterious expert contracted by the Wangsheng Funeral Parlor. Extremely knowledgeable in all things.',
  ),
  Product(
    id: 'char-raiden-shogun',
    name: 'Raiden Shogun',
    price: 1499.99,
    category: 'Electro',
    imageUrl: 'https://enka.network/ui/UI_AvatarIcon_Shougun_Card.png',
    rating: 5.0,
    badge: '5★ ARCHON',
    description:
        'Her Excellency, the Almighty Narukami Ogosho, who promised the people of Inazuma an unchanging Eternity.',
  ),
  Product(
    id: 'char-furina',
    name: 'Furina',
    price: 1499.99,
    category: 'Hydro',
    imageUrl: 'https://enka.network/ui/UI_AvatarIcon_Furina_Card.png',
    rating: 5.0,
    badge: '5★ ARCHON',
    description:
        'The absolute focus of the stage of judgment, until the final applause sounds.',
  ),
  Product(
    id: 'char-nahida',
    name: 'Nahida',
    price: 1499.99,
    category: 'Dendro',
    imageUrl: 'https://enka.network/ui/UI_AvatarIcon_Nahida_Card.png',
    rating: 5.0,
    badge: '5★ ARCHON',
    description:
        'A caged bird secluded within the confines of the Sanctuary of Surasthana who can only see the world in her dreams.',
  ),
  Product(
    id: 'char-venti',
    name: 'Venti',
    price: 1499.99,
    category: 'Anemo',
    imageUrl: 'https://enka.network/ui/UI_AvatarIcon_Venti_Card.png',
    rating: 5.0,
    badge: '5★ ARCHON',
    description:
        'One of the many bards of Mondstadt, who freely wanders the city\'s streets and alleys.',
  ),
  Product(
    id: 'char-hu-tao',
    name: 'Hu Tao',
    price: 1199.99,
    category: 'Pyro',
    imageUrl: 'https://enka.network/ui/UI_AvatarIcon_Hutao_Card.png',
    rating: 4.9,
    badge: '5★ LEGENDARY',
    description:
        'The 77th Director of the Wangsheng Funeral Parlor. She took over the business at a rather young age.',
  ),
  Product(
    id: 'char-neuvillette',
    name: 'Neuvillette',
    price: 1199.99,
    category: 'Hydro',
    imageUrl: 'https://enka.network/ui/UI_AvatarIcon_Neuvillette_Card.png',
    rating: 4.9,
    badge: '5★ LEGENDARY',
    description:
        'The Chief Justice of Fontaine, known as the Iudex, is renowned for his unassailable impartiality.',
  ),
  Product(
    id: 'char-kaedehara-kazuha',
    name: 'Kaedehara Kazuha',
    price: 1199.99,
    category: 'Anemo',
    imageUrl: 'https://enka.network/ui/UI_AvatarIcon_Kazuha_Card.png',
    rating: 4.9,
    badge: '5★ LEGENDARY',
    description:
        'A wandering samurai from Inazuma who is currently with Liyue\'s Crux Fleet. A gentle and carefree soul whose heart hides a great many burdens from the past.',
  ),
  Product(
    id: 'char-kamisato-ayaka',
    name: 'Kamisato Ayaka',
    price: 1199.99,
    category: 'Cryo',
    imageUrl: 'https://enka.network/ui/UI_AvatarIcon_Ayaka_Card.png',
    rating: 4.9,
    badge: '5★ LEGENDARY',
    description:
        'Daughter of the Yashiro Commission\'s Kamisato Clan. Dignified and elegant, as well as wise and strong.',
  ),
  Product(
    id: 'char-diluc',
    name: 'Diluc',
    price: 1199.99,
    category: 'Pyro',
    imageUrl: 'https://enka.network/ui/UI_AvatarIcon_Diluc_Card.png',
    rating: 4.9,
    badge: '5★ LEGENDARY',
    description:
        'The tycoon of a winery empire in Mondstadt, unmatched in every possible way.',
  ),
  Product(
    id: 'char-alhaitham',
    name: 'Alhaitham',
    price: 1199.99,
    category: 'Dendro',
    imageUrl: 'https://enka.network/ui/UI_AvatarIcon_Alhatham_Card.png',
    rating: 4.9,
    badge: '5★ LEGENDARY',
    description:
        'The current scribe of the Sumeru Akademiya, a man endowed with extraordinary intelligence and talent. He lives free — free from the searching eyes of ordinary people, anyway.',
  ),
  Product(
    id: 'char-navia',
    name: 'Navia',
    price: 1199.99,
    category: 'Geo',
    imageUrl: 'https://enka.network/ui/UI_AvatarIcon_Navia_Card.png',
    rating: 4.9,
    badge: '5★ LEGENDARY',
    description:
        'The current President of Spina di Rosula, who is lovely, dutiful, and a great boss.',
  ),
  Product(
    id: 'char-bennett',
    name: 'Bennett',
    price: 349.99,
    category: 'Pyro',
    imageUrl: 'https://enka.network/ui/UI_AvatarIcon_Bennett_Card.png',
    rating: 4.6,
    badge: '4★ FEATURED',
    description:
        'A good-natured adventurer from Mondstadt who\'s unfortunately extremely unlucky.',
  ),
  Product(
    id: 'char-xingqiu',
    name: 'Xingqiu',
    price: 349.99,
    category: 'Hydro',
    imageUrl: 'https://enka.network/ui/UI_AvatarIcon_Xingqiu_Card.png',
    rating: 4.6,
    badge: '4★ FEATURED',
    description:
        'A young man carrying a longsword who is frequently seen at book booths. He has a chivalrous heart and yearns for justice and fairness for all.',
  ),
  Product(
    id: 'char-xiangling',
    name: 'Xiangling',
    price: 349.99,
    category: 'Pyro',
    imageUrl: 'https://enka.network/ui/UI_AvatarIcon_Xiangling_Card.png',
    rating: 4.6,
    badge: '4★ FEATURED',
    description:
        'A renowned chef from Liyue. She\'s extremely passionate about cooking and excels at making her signature hot and spicy dishes.',
  ),
  Product(
    id: 'char-fischl',
    name: 'Fischl',
    price: 349.99,
    category: 'Electro',
    imageUrl: 'https://enka.network/ui/UI_AvatarIcon_Fischl_Card.png',
    rating: 4.6,
    badge: '4★ FEATURED',
    description:
        'A mysterious girl who calls herself "Prinzessin der Verurteilung" and travels with a night raven named Oz.',
  ),
  Product(
    id: 'char-gorou',
    name: 'Gorou',
    price: 349.99,
    category: 'Geo',
    imageUrl: 'https://enka.network/ui/UI_AvatarIcon_Gorou_Card.png',
    rating: 4.6,
    badge: '4★ FEATURED',
    description:
        'The great general of Watatsumi Island\'s forces. He is deeply trusted by his subordinates.',
  ),
  Product(
    id: 'char-sucrose',
    name: 'Sucrose',
    price: 349.99,
    category: 'Anemo',
    imageUrl: 'https://enka.network/ui/UI_AvatarIcon_Sucrose_Card.png',
    rating: 4.6,
    badge: '4★ FEATURED',
    description:
        'An alchemist filled with curiosity about all things. She researches bio-alchemy.',
  ),
  Product(
    id: 'char-ningguang',
    name: 'Ningguang',
    price: 349.99,
    category: 'Geo',
    imageUrl: 'https://enka.network/ui/UI_AvatarIcon_Ningguang_Card.png',
    rating: 4.6,
    badge: '4★ FEATURED',
    description:
        'The Tianquan of the Liyue Qixing. Her wealth is unsurpassed in all of Teyvat.',
  ),
  Product(
    id: 'char-ganyu',
    name: 'Ganyu',
    price: 1199.99,
    category: 'Cryo',
    imageUrl: 'https://enka.network/ui/UI_AvatarIcon_Ganyu_Card.png',
    rating: 4.9,
    badge: '5★ LEGENDARY',
    description:
        'The secretary at Yuehai Pavilion. The blood of the qilin, an illuminated beast, flows within her veins.',
  ),
  Product(
    id: 'char-gaming',
    name: 'Gaming',
    price: 349.99,
    category: 'Pyro',
    imageUrl: 'https://enka.network/ui/UI_AvatarIcon_Gaming_Card.png',
    rating: 4.6,
    badge: '4★ FEATURED',
    description:
        'Guard of the Sword and Strongbox Secure Transport Agency, and the head of the "Mighty Mythical Beasts" Wushou troupe.',
  ),
  Product(
    id: 'char-xiao',
    name: 'Xiao',
    price: 1199.99,
    category: 'Anemo',
    imageUrl: 'https://enka.network/ui/UI_AvatarIcon_Xiao_Card.png',
    rating: 4.9,
    badge: '5★ LEGENDARY',
    description:
        'A yaksha adeptus who defends Liyue. Also heralded as the "Conqueror of Demons" and "Vigilant Yaksha."',
  ),
  Product(
    id: 'char-yelan',
    name: 'Yelan',
    price: 1199.99,
    category: 'Hydro',
    imageUrl: 'https://enka.network/ui/UI_AvatarIcon_Yelan_Card.png',
    rating: 4.9,
    badge: '5★ LEGENDARY',
    description:
        'A mysterious person who claims to work for the Ministry of Civil Affairs, but is a "non-entity" on the Ministry of Civil Affairs\' list.',
  ),
  Product(
    id: 'char-klee',
    name: 'Klee',
    price: 1199.99,
    category: 'Pyro',
    imageUrl: 'https://enka.network/ui/UI_AvatarIcon_Klee_Card.png',
    rating: 4.9,
    badge: '5★ LEGENDARY',
    description:
        'An explosives expert and a regular at the Knights of Favonius\'s confinement room. Also known as Fleeing Sunlight.',
  ),
  Product(
    id: 'char-wriothesley',
    name: 'Wriothesley',
    price: 1199.99,
    category: 'Cryo',
    imageUrl: 'https://enka.network/ui/UI_AvatarIcon_Wriothesley_Card.png',
    rating: 4.9,
    badge: '5★ LEGENDARY',
    description:
        'Duke of the Fortress of Meropide, Lord Incognito of the murky depths.',
  ),
  Product(
    id: 'char-yae-miko',
    name: 'Yae Miko',
    price: 1199.99,
    category: 'Electro',
    imageUrl: 'https://enka.network/ui/UI_AvatarIcon_Yae_Card.png',
    rating: 4.9,
    badge: '5★ LEGENDARY',
    description:
        'Lady Guuji of the Grand Narukami Shrine. Also serves as the editor-in-chief of Yae Publishing House. Unimaginable intelligence and cunning are hidden under her beautiful appearance.',
  ),
  Product(
    id: 'char-kuki-shinobu',
    name: 'Kuki Shinobu',
    price: 349.99,
    category: 'Electro',
    imageUrl: 'https://enka.network/ui/UI_AvatarIcon_Shinobu_Card.png',
    rating: 4.6,
    badge: '4★ FEATURED',
    description:
        'The capable and reliable Arataki Gang deputy leader - Please note: capable and reliable are not appellations for the "Arataki Gang," but for their deputy leader in specific.',
  ),
  Product(
    id: 'char-jean',
    name: 'Jean',
    price: 1199.99,
    category: 'Anemo',
    imageUrl: 'https://enka.network/ui/UI_AvatarIcon_Qin_Card.png',
    rating: 4.9,
    badge: '5★ LEGENDARY',
    description:
        'The righteous and rigorous Dandelion Knight, and Acting Grand Master of Mondstadt\'s Knights of Favonius.',
  ),
  Product(
    id: 'char-sangonomiya-kokomi',
    name: 'Sangonomiya Kokomi',
    price: 1199.99,
    category: 'Hydro',
    imageUrl: 'https://enka.network/ui/UI_AvatarIcon_Kokomi_Card.png',
    rating: 4.9,
    badge: '5★ LEGENDARY',
    description:
        'The Divine Priestess of Watatsumi Island. All of the island\'s affairs are at this young lady\'s fingertips.',
  ),
  Product(
    id: 'char-yaoyao',
    name: 'Yaoyao',
    price: 349.99,
    category: 'Dendro',
    imageUrl: 'https://enka.network/ui/UI_AvatarIcon_Yaoyao_Card.png',
    rating: 4.6,
    badge: '4★ FEATURED',
    description:
        'Streetward Rambler\'s youngest disciple. A gentle and caring "little adult."',
  ),
  Product(
    id: 'weap-mistsplitter-reforged',
    name: 'Mistsplitter Reforged',
    price: 899.99,
    category: 'Weapons',
    imageUrl: 'https://enka.network/ui/UI_EquipIcon_Sword_Narukami.png',
    rating: 4.9,
    badge: '5★ WEAPON',
    description:
        'A sword that blazes with a fierce violet light. The name "Reforged" comes from it having been broken once before.',
  ),
  Product(
    id: 'weap-engulfing-lightning',
    name: 'Engulfing Lightning',
    price: 899.99,
    category: 'Weapons',
    imageUrl: 'https://enka.network/ui/UI_EquipIcon_Pole_Narukami.png',
    rating: 4.9,
    badge: '5★ WEAPON',
    description:
        'A naginata used to "cut grass." Any army that stands before this weapon will probably be likewise cut down...',
  ),
  Product(
    id: 'weap-everlasting-moonglow',
    name: 'Everlasting Moonglow',
    price: 899.99,
    category: 'Weapons',
    imageUrl: 'https://enka.network/ui/UI_EquipIcon_Catalyst_Kaleido.png',
    rating: 4.9,
    badge: '5★ WEAPON',
    description:
        'A string of lovely jasper from the deep sea. It shines with a pure radiance like that of the moon, and just as ever-distant.',
  ),
  Product(
    id: 'weap-song-of-broken-pines',
    name: 'Song of Broken Pines',
    price: 899.99,
    category: 'Weapons',
    imageUrl: 'https://enka.network/ui/UI_EquipIcon_Claymore_Widsith.png',
    rating: 4.9,
    badge: '5★ WEAPON',
    description:
        'A greatsword as light as the sigh of grass in the breeze, yet as merciless to the corrupt as a typhoon.',
  ),
  Product(
    id: 'weap-amos-bow',
    name: 'Amos\' Bow',
    price: 899.99,
    category: 'Weapons',
    imageUrl: 'https://enka.network/ui/UI_EquipIcon_Bow_Amos.png',
    rating: 4.9,
    badge: '5★ WEAPON',
    description:
        'An extremely ancient bow that has retained its power despite its original master being long gone. It draws power from everyone and everything in the world, and the further away you are from that which your heart desires, the more powerful it is.',
  ),
  Product(
    id: 'weap-aquila-favonia',
    name: 'Aquila Favonia',
    price: 899.99,
    category: 'Weapons',
    imageUrl: 'https://enka.network/ui/UI_EquipIcon_Sword_Falcon.png',
    rating: 4.9,
    badge: '5★ WEAPON',
    description:
        'The soul of the Knights of Favonius. Millennia later, it still calls on the winds of swift justice to vanquish all evil — just like the last heroine who wielded it.',
  ),
  Product(
    id: 'weap-"the-catch"',
    name: '"The Catch"',
    price: 199.99,
    category: 'Weapons',
    imageUrl: 'https://enka.network/ui/UI_EquipIcon_Pole_Mori.png',
    rating: 4.6,
    badge: '4★ WEAPON',
    description:
        'In the distant past, this was the beloved spear of a famed Inazuman bandit.',
  ),
  Product(
    id: 'weap-thrilling-tales-of-dragon-slayers',
    name: 'Thrilling Tales of Dragon Slayers',
    price: 199.99,
    category: 'Weapons',
    imageUrl: 'https://enka.network/ui/UI_EquipIcon_Catalyst_Pulpfic.png',
    rating: 4.6,
    badge: '3★ WEAPON',
    description:
        'A fictional story of a band of five heroes who go off on a dragon hunt. It is poorly written and structurally incoherent. Its value lies in the many lessons that can be learned from failure.',
  ),
  Product(
    id: 'weap-favonius-sword',
    name: 'Favonius Sword',
    price: 199.99,
    category: 'Weapons',
    imageUrl: 'https://enka.network/ui/UI_EquipIcon_Sword_Zephyrus.png',
    rating: 4.6,
    badge: '4★ WEAPON',
    description:
        'A standard-issue longsword of the Knights of Favonius. When you\'re armed with this agile and sharp weapon, channeling the power of the elements has never been so easy!',
  ),
  Product(
    id: 'weap-favonius-warbow',
    name: 'Favonius Warbow',
    price: 199.99,
    category: 'Weapons',
    imageUrl: 'https://enka.network/ui/UI_EquipIcon_Bow_Zephyrus.png',
    rating: 4.6,
    badge: '4★ WEAPON',
    description:
        'A standard-issue recurve bow of the Knights of Favonius. Only the best archers can unleash its full potential.',
  ),
  Product(
    id: 'weap-favonius-greatsword',
    name: 'Favonius Greatsword',
    price: 199.99,
    category: 'Weapons',
    imageUrl: 'https://enka.network/ui/UI_EquipIcon_Claymore_Zephyrus.png',
    rating: 4.6,
    badge: '4★ WEAPON',
    description:
        'A heavy ceremonial sword of the Knights of Favonius. It channels elemental power easily and is highly destructive.',
  ),
  Product(
    id: 'weap-lost-prayer-to-the-sacred-winds',
    name: 'Lost Prayer to the Sacred Winds',
    price: 899.99,
    category: 'Weapons',
    imageUrl: 'https://enka.network/ui/UI_EquipIcon_Catalyst_Fourwinds.png',
    rating: 4.9,
    badge: '5★ WEAPON',
    description:
        'An educational tome written by anonymous early inhabitants who worshiped the wind. It has been blessed by the wind for its faithfulness and influence over the millennia.',
  ),
  Product(
    id: 'weap-skyward-blade',
    name: 'Skyward Blade',
    price: 899.99,
    category: 'Weapons',
    imageUrl: 'https://enka.network/ui/UI_EquipIcon_Sword_Dvalin.png',
    rating: 4.9,
    badge: '5★ WEAPON',
    description:
        'The sword of a knight that symbolizes the restored honor of Dvalin. The blessings of the Anemo Archon rest on the fuller of the blade, imbuing the sword with the powers of the sky and the wind.',
  ),
  Product(
    id: 'weap-calamity-queller',
    name: 'Calamity Queller',
    price: 899.99,
    category: 'Weapons',
    imageUrl: 'https://enka.network/ui/UI_EquipIcon_Pole_Santika.png',
    rating: 4.9,
    badge: '5★ WEAPON',
    description:
        'A keenly honed weapon forged from some strange crystal. Its faint blue light seems to whisper of countless matters now past.',
  ),
  Product(
    id: 'weap-polar-star',
    name: 'Polar Star',
    price: 899.99,
    category: 'Weapons',
    imageUrl: 'https://enka.network/ui/UI_EquipIcon_Bow_Worldbane.png',
    rating: 4.9,
    badge: '5★ WEAPON',
    description:
        'A pristine bow that is as sharp as the glaciers of the far north.',
  ),
  Product(
    id: 'weap-amenoma-kageuchi',
    name: 'Amenoma Kageuchi',
    price: 199.99,
    category: 'Weapons',
    imageUrl: 'https://enka.network/ui/UI_EquipIcon_Sword_Bakufu.png',
    rating: 4.6,
    badge: '4★ WEAPON',
    description:
        'A blade custom made for a famed samurai who could strike down a tengu warrior, known for their incredible agility, in midair.',
  ),
  Product(
    id: 'weap-skyward-pride',
    name: 'Skyward Pride',
    price: 899.99,
    category: 'Weapons',
    imageUrl: 'https://enka.network/ui/UI_EquipIcon_Claymore_Dvalin.png',
    rating: 4.9,
    badge: '5★ WEAPON',
    description:
        'A claymore that symbolizes the pride of Dvalin soaring through the skies. When swung, it emits a deep hum as the full force of Dvalin\'s command of the sky and the wind is unleashed.',
  ),
  Product(
    id: 'weap-the-stringless',
    name: 'The Stringless',
    price: 199.99,
    category: 'Weapons',
    imageUrl: 'https://enka.network/ui/UI_EquipIcon_Bow_Troupe.png',
    rating: 4.6,
    badge: '4★ WEAPON',
    description:
        'A bow that once served as an extraordinary instrument. It is no longer capable of getting people up and dancing.',
  ),
  Product(
    id: 'weap-the-widsith',
    name: 'The Widsith',
    price: 199.99,
    category: 'Weapons',
    imageUrl: 'https://enka.network/ui/UI_EquipIcon_Catalyst_Troupe.png',
    rating: 4.6,
    badge: '4★ WEAPON',
    description:
        'A heavy notebook filled with musical scores. Though suffering from moth damage and heavy wear-and-tear, there is still much power to be found among the hand-written words within.',
  ),
  Product(
    id: 'weap-dragons-bane',
    name: 'Dragon\'s Bane',
    price: 199.99,
    category: 'Weapons',
    imageUrl: 'https://enka.network/ui/UI_EquipIcon_Pole_Stardust.png',
    rating: 4.6,
    badge: '4★ WEAPON',
    description:
        'A polearm decorated with an entwining golden dragon. Light and sharp, this weapon may very well kill dragons with ease.',
  ),
  Product(
    id: 'mat-prithiva-topaz-gemstone',
    name: 'Prithiva Topaz Gemstone',
    price: 149.99,
    category: 'Materials',
    imageUrl: 'https://enka.network/ui/UI_ItemIcon_104174.png',
    rating: 4.8,
    badge: 'GEMSTONE',
    description:
        'Character Ascension material. "The currencies that flow through this land are my flesh and blood. For thus did I become the guarantor of the people\'s hard work, wisdom, and future. This is the trust I have placed in them. Betray it, and you taint my blood."',
  ),
  Product(
    id: 'mat-shivada-jade-gemstone',
    name: 'Shivada Jade Gemstone',
    price: 149.99,
    category: 'Materials',
    imageUrl: 'https://enka.network/ui/UI_ItemIcon_104164.png',
    rating: 4.8,
    badge: 'GEMSTONE',
    description:
        'Character Ascension material. "Sorry... to also have you shoulder the grievances of the world. "Since you could endure my bitter cold, you must have the desire to burn? "Then, burn away the old world for me."',
  ),
  Product(
    id: 'mat-vayuda-turquoise-gemstone',
    name: 'Vayuda Turquoise Gemstone',
    price: 149.99,
    category: 'Materials',
    imageUrl: 'https://enka.network/ui/UI_ItemIcon_104154.png',
    rating: 4.8,
    badge: 'GEMSTONE',
    description:
        'Character Ascension material. "Still, the winds change direction. "Someday, they will blow towards a brighter future... "Take my blessings and live leisurely from this day onward."',
  ),
  Product(
    id: 'mat-vajrada-amethyst-gemstone',
    name: 'Vajrada Amethyst Gemstone',
    price: 149.99,
    category: 'Materials',
    imageUrl: 'https://enka.network/ui/UI_ItemIcon_104144.png',
    rating: 4.8,
    badge: 'GEMSTONE',
    description:
        'Character Ascension material. "This body is the noblest and most eminent of all in this world. "It should hold absolute control over this world. "It once promised its people a dream: the never-changing \'eternity.\'"',
  ),
  Product(
    id: 'mat-nagadus-emerald-gemstone',
    name: 'Nagadus Emerald Gemstone',
    price: 149.99,
    category: 'Materials',
    imageUrl: 'https://enka.network/ui/UI_ItemIcon_104134.png',
    rating: 4.8,
    badge: 'GEMSTONE',
    description:
        'Character Ascension material. "I had a very, very long dream..." "In it, people were holding hands, dancing in a circle, be they sages or fools, dancers or warriors, puppets or statues of gods..." "That dancing circle embodied everything about the universe. Life has always been the end, while it is wisdom that shall be the means."',
  ),
  Product(
    id: 'mat-varunada-lazurite-gemstone',
    name: 'Varunada Lazurite Gemstone',
    price: 149.99,
    category: 'Materials',
    imageUrl: 'https://enka.network/ui/UI_ItemIcon_104124.png',
    rating: 4.8,
    badge: 'GEMSTONE',
    description:
        'Character Ascension material. "My ideals have no stains. I must correct you. People here bear no sins in the eyes of the gods... Only laws and the Tribunal can judge someone. They can judge even me. So praise my magnificence and purity."',
  ),
  Product(
    id: 'mat-agnidus-agate-gemstone',
    name: 'Agnidus Agate Gemstone',
    price: 149.99,
    category: 'Materials',
    imageUrl: 'https://enka.network/ui/UI_ItemIcon_104114.png',
    rating: 4.8,
    badge: 'GEMSTONE',
    description:
        'Character Ascension material. "A pilgrimage for a wish; a battle to earn a name... Burnt to cinders for a dream. If the intention yet remains, achieved ██\'s truth he has."',
  ),
  Product(
    id: 'mat-brilliant-diamond-gemstone',
    name: 'Brilliant Diamond Gemstone',
    price: 149.99,
    category: 'Materials',
    imageUrl: 'https://enka.network/ui/UI_ItemIcon_104104.png',
    rating: 4.8,
    badge: 'GEMSTONE',
    description:
        'Character Ascension material. "Welcome to this world."',
  ),
  Product(
    id: 'mat-philosophies-of-ingenuity',
    name: 'Philosophies of Ingenuity',
    price: 69.99,
    category: 'Materials',
    imageUrl: 'https://enka.network/ui/UI_ItemIcon_104334.png',
    rating: 4.8,
    badge: 'TALENT BOOK',
    description:
        'Talent Level-Up material. Ingenuity is the leaf-veins of the nation of wisdom. Ingenuity is completed by harmonious conduct. What is done completes what is thought. Wisdom blooms where the mind, words, and practice converge.',
  ),
  Product(
    id: 'mat-philosophies-of-light',
    name: 'Philosophies of Light',
    price: 69.99,
    category: 'Materials',
    imageUrl: 'https://enka.network/ui/UI_ItemIcon_104328.png',
    rating: 4.8,
    badge: 'TALENT BOOK',
    description:
        'Talent Level-Up material. Light is the yearning of the land of thunder. Though they must live forever on the earth, humanity will always reach for the light. Mortals will pursue and surpass, and they will never stop. A sealed eternity may, perhaps, look magnificent, but its essence is death.',
  ),
  Product(
    id: 'mat-teachings-of-gold',
    name: 'Teachings of Gold',
    price: 69.99,
    category: 'Materials',
    imageUrl: 'https://enka.network/ui/UI_ItemIcon_104316.png',
    rating: 4.8,
    badge: 'ASCENSION',
    description:
        'Talent Level-Up material. Gold is the symbol of the land of Geo. Gold is the blood that flows deep within Liyue\'s veins, the muscle that makes up Liyue\'s beating heart, and the bones that make Liyue stand proud.',
  ),
  Product(
    id: 'mat-teachings-of-diligence',
    name: 'Teachings of Diligence',
    price: 69.99,
    category: 'Materials',
    imageUrl: 'https://enka.network/ui/UI_ItemIcon_104313.png',
    rating: 4.8,
    badge: 'ASCENSION',
    description:
        'Talent Level-Up material. Industriousness is the foundation of the land of Geo. Diligence is having the bravery and the strength to conquer mountains and seas and to pursue gold and prosperity through honest, hard work.',
  ),
  Product(
    id: 'mat-teachings-of-resistance',
    name: 'Teachings of Resistance',
    price: 69.99,
    category: 'Materials',
    imageUrl: 'https://enka.network/ui/UI_ItemIcon_104304.png',
    rating: 4.8,
    badge: 'ASCENSION',
    description:
        'Talent Level-Up material. Resistance is the backbone of the land of the wind. The history of Mondstadt is one of resistances. People rose up to prevent past conflicts from ever being forgotten, like sprouts breaking through the soil, like the eternal wind eroding through stone walls.',
  ),
  Product(
    id: 'mat-teachings-of-ballad',
    name: 'Teachings of Ballad',
    price: 69.99,
    category: 'Materials',
    imageUrl: 'https://enka.network/ui/UI_ItemIcon_104307.png',
    rating: 4.8,
    badge: 'ASCENSION',
    description:
        'Talent Level-Up material. Poetry is the soul of the land of the wind. Poetry is the manifestations of beautiful feelings. On a beautiful day, the breezes carry with them poetry that touches the heart of people like the wind caressing the leaves.',
  ),
  Product(
    id: 'mat-teachings-of-prosperity',
    name: 'Teachings of Prosperity',
    price: 69.99,
    category: 'Materials',
    imageUrl: 'https://enka.network/ui/UI_ItemIcon_104310.png',
    rating: 4.8,
    badge: 'ASCENSION',
    description:
        'Talent Level-Up material. Prosperity is the people\'s pursuit in the land of Geo. Prosperity is the blessing of Liyue, it is the foundation of the great city built by the gods and the people of Liyue, and it is the source of the peace and safety of the land.',
  ),
  Product(
    id: 'mat-dvalins-plume',
    name: 'Dvalin\'s Plume',
    price: 149.99,
    category: 'Materials',
    imageUrl: 'https://enka.network/ui/UI_ItemIcon_113003.png',
    rating: 4.8,
    badge: 'ASCENSION',
    description:
        'A feather from the tail of the Dragon of the East. As a dragon\'s feather it has experienced more than a thousand years\' worth of winds. One senses within it a yearning for freedom so strong that it could whip up a light breeze to rescue it from its current confines. Its former owner\'s recognition of you is what makes it content to stay in your hands.',
  ),
  Product(
    id: 'mat-dvalins-claw',
    name: 'Dvalin\'s Claw',
    price: 149.99,
    category: 'Materials',
    imageUrl: 'https://enka.network/ui/UI_ItemIcon_113004.png',
    rating: 4.8,
    badge: 'ASCENSION',
    description:
        'A claw from the Dragon of the East. It once contained the shadow dragon Durin\'s vile poison, having torn through the latter\'s flesh in battle. Thanks to your purification and healing, it is no longer toxic.',
  ),
  Product(
    id: 'mat-dvalins-sigh',
    name: 'Dvalin\'s Sigh',
    price: 149.99,
    category: 'Materials',
    imageUrl: 'https://enka.network/ui/UI_ItemIcon_113005.png',
    rating: 4.8,
    badge: 'ASCENSION',
    description:
        'A bit of power taken from the whirlwinds evoked by the Dragon of the East. Beautiful and transparent, both trade winds and tornadoes will work in his name. The winds move as his companion, his voice, and his freedom. His enemies are the thousands who stand against the wind.',
  ),
  Product(
    id: 'mat-tail-of-boreas',
    name: 'Tail of Boreas',
    price: 149.99,
    category: 'Materials',
    imageUrl: 'https://enka.network/ui/UI_ItemIcon_113006.png',
    rating: 4.8,
    badge: 'ASCENSION',
    description:
        'A handful of tail scales from the Great Wolf King of the North. Even without his physical body and beyond death, Boreas still possesses extraordinary powers. He took a form comprised of ice and wind to embrace a new challenge, but even such a form could not house all of his power. The ice scales that fell during the battle still retain some of their spiritual energy.',
  ),
  Product(
    id: 'mat-ring-of-boreas',
    name: 'Ring of Boreas',
    price: 149.99,
    category: 'Materials',
    imageUrl: 'https://enka.network/ui/UI_ItemIcon_113007.png',
    rating: 4.8,
    badge: 'ASCENSION',
    description:
        'A bit of crystallized ice from the Great Wolf King of the North. This land was once a realm of freezing-cold blizzards and ice storms filled with razor-sharp ice shards, all at the command of Boreas. Though his power may have diminished, he could still freeze the land in an instant.',
  ),
];
