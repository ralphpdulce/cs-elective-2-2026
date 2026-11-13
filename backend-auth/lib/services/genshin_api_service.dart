import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/product.dart';

/// Service responsible for fetching character data from Devesh Anand's Genshin Impact API
/// and converting raw character entries into store [Product] models with realistic calculated prices.
class GenshinApiService {
  static const String apiBaseUrl = 'https://genshin-impact.up.railway.app';
  static const String charactersEndpoint = '$apiBaseUrl/characters?details=true';
  static const String repositoryUrl = 'https://github.com/devesh-anand/genshin-api';
  static const String creditText =
      'Character data and illustrations courtesy of Devesh Anand\'s Genshin Impact API.';
  static const String copyrightDisclaimer =
      'Genshin Impact and all character names, assets, and lore are copyright © HoYoverse / COGNOSPHERE PTE. LTD. This project is built solely for educational purposes.';

  // Known Archons for unique badges
  static const Set<String> _archons = {
    'venti',
    'zhongli',
    'raiden',
    'nahida',
    'furina',
    'mavuika',
  };

  final http.Client _client;

  GenshinApiService({http.Client? client}) : _client = client ?? http.Client();

  /// Fetches characters from the Genshin Impact API.
  /// Falls back to [fallbackProducts] if the request fails or times out.
  Future<List<Product>> fetchCharacters({
    List<Product>? fallbackProducts,
    Duration timeout = const Duration(seconds: 10),
  }) async {
    try {
      final uri = Uri.parse(charactersEndpoint);
      final response = await _client.get(uri).timeout(timeout);

      if (response.statusCode == 200) {
        final decoded = json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        final List rawChars = (decoded['characters'] as List?) ?? [];

        final List<Product> products = [];
        for (final item in rawChars) {
          if (item is Map<String, dynamic>) {
            final product = mapCharacterToProduct(item);
            if (product != null) {
              products.add(product);
            }
          }
        }

        if (products.isNotEmpty) {
          debugPrint('[GenshinApiService] Successfully loaded ${products.length} characters from API.');
          return products;
        }
      } else {
        debugPrint('[GenshinApiService] HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      debugPrint('[GenshinApiService] Fetch error: $e');
    }

    debugPrint('[GenshinApiService] Returning fallback character dataset.');
    return fallbackProducts ?? sampleProducts;
  }

  /// Converts a single raw character API map into a [Product] model with calculated store attributes.
  static Product? mapCharacterToProduct(Map<String, dynamic> char) {
    final String key = (char['key'] ?? '').toString().trim();
    if (key.isEmpty) return null;

    final String rawName = (char['name'] ?? key).toString();
    final String vision = (char['vision'] ?? 'Anemo').toString();
    final int rarity = (char['rarity'] as num?)?.toInt() ?? 4;
    final String title = (char['title'] ?? '').toString();
    final String weapon = (char['weapon'] ?? 'Sword').toString();
    final String nation = (char['nation'] ?? 'Teyvat').toString();

    // Map name: if generic Traveler, distinguish by vision
    final String name = (rawName.toLowerCase() == 'traveler') ? 'Traveler ($vision)' : rawName;

    // Resolve Image URL (Prefer card, fallback to portrait -> banner -> icon)
    final imgMap = char['img'];
    String? imageUrl;
    if (imgMap is Map) {
      imageUrl = imgMap['card'] ?? imgMap['portrait'] ?? imgMap['banner'] ?? imgMap['icon'];
    }
    imageUrl ??= 'https://pub-1ad979b6618d4a07ab871591a84b954c.r2.dev/$key/card.png';

    // Compute realistic store price based on rarity and deterministic hash
    final int hash = _hashString(key);
    double price;
    double rating;
    String badge;

    if (rarity >= 5) {
      // 5-Star Character: $899.99 - $1,499.99
      price = 899.99 + ((hash % 13) * 50.0);
      rating = 4.8 + ((hash % 3) * 0.1);
      badge = _archons.contains(key) ? '5★ ARCHON' : '5★ LEGENDARY';
    } else {
      // 4-Star Character: $249.99 - $564.99
      price = 249.99 + ((hash % 8) * 45.0);
      rating = 4.3 + ((hash % 5) * 0.1);
      badge = '4★ FEATURED';
    }

    // Build rich lore description
    final StringBuffer desc = StringBuffer();
    if (title.isNotEmpty) {
      desc.write('"$title". ');
    }
    desc.write('$name is a $rarity★ $vision character from $nation, wielding a $weapon. ');
    desc.write('Available now in Paimon\'s Bargains for your party adventure.');

    return Product(
      id: key,
      name: name,
      price: double.parse(price.toStringAsFixed(2)),
      category: vision,
      imageUrl: imageUrl,
      rating: double.parse(rating.toStringAsFixed(1)),
      badge: badge,
      description: desc.toString(),
    );
  }

  static int _hashString(String str) {
    int hash = 0;
    for (int i = 0; i < str.length; i++) {
      hash = (hash * 31 + str.codeUnitAt(i)) & 0x7FFFFFFF;
    }
    return hash;
  }
}

