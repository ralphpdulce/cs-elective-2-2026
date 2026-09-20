import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FruitItem {
  final String name;
  final String slug;
  final String emoji;
  final String description;
  final Color color;

  const FruitItem({
    required this.name,
    required this.slug,
    required this.emoji,
    required this.description,
    required this.color,
  });
}

const List<FruitItem> sampleFruits = [
  FruitItem(
    name: 'Mango',
    slug: 'mango',
    emoji: '🥭',
    description: 'A sweet, juicy tropical fruit with bright orange flesh. Goes well with graham crackers and whipped cream!',
    color: Color(0xFFFFF3E0),
  ),
  FruitItem(
    name: 'Pineapple',
    slug: 'pineapple',
    emoji: '🍍',
    description: 'A tropical fruit with a sweet and slightly tangy flavor. Great for making your own pineapple juice!',
    color: Color(0xFFFFFDE7),
  ),
  FruitItem(
    name: 'Kiwi',
    slug: 'kiwi',
    emoji: '🥝',
    description: 'A small fruit with fuzzy skin and bright green flesh. Already good on its own!',
    color: Color(0xFFF1F8E9),
  ),
  FruitItem(
    name: 'Blueberry',
    slug: 'blueberry',
    emoji: '🫐',
    description: 'A small blue-colored berry rich in flavor and antioxidants. Best put in oatmeal and desserts!',
    color: Color(0xFFEDE7F6),
  ),
  FruitItem(
    name: 'Peach',
    slug: 'peach',
    emoji: '🍑',
    description: 'A soft, fragrant fruit with a sweet and juicy flesh. Perfect for peach cobbler!',
    color: Color(0xFFFCE4EC),
  ),
  FruitItem(
    name: 'Coconut',
    slug: 'coconut',
    emoji: '🥥',
    description: 'A tropical fruit filled with a nutty flesh and refreshing coconut water. Great for kakanin!',
    color: Color(0xFFEFEBE9),
  ),
  FruitItem(
    name: 'Pear',
    slug: 'pear',
    emoji: '🍐',
    description: 'A sweet, juicy fruit with a distinctive shape and mild flavor. Good for making your kimchi paste!',
    color: Color(0xFFEFEBE9),
  ),
];

class FruitListPage extends StatelessWidget {
  const FruitListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fruit Explorer'),
        centerTitle: true,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: sampleFruits.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final fruit = sampleFruits[index];

          return Card(
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              leading: Text(
                fruit.emoji,
                style: const TextStyle(fontSize: 36),
              ),
              title: Text(
                fruit.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              subtitle: Text(
                fruit.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                final encodedSlug = Uri.encodeComponent(fruit.slug);
                context.push('/fruit/$encodedSlug');
              },
            ),
          );
        },
      ),
    );
  }
}

class FruitDetailPage extends StatelessWidget {
  final String fruitSlug;

  const FruitDetailPage({
    super.key,
    required this.fruitSlug,
  });

  @override
  Widget build(BuildContext context) {
    final fruit = sampleFruits.firstWhere(
      (item) => item.slug == fruitSlug,
      orElse: () => FruitItem(
        name: 'Unknown Fruit',
        slug: fruitSlug,
        emoji: '🍎',
        description: 'This fruit could not be found.',
        color: Colors.grey.shade200,
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(fruit.name),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                color: fruit.color,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                fruit.emoji,
                style: const TextStyle(fontSize: 96),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              fruit.name,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              fruit.description,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Back to Fruit List'),
            ),
          ],
        ),
      ),
    );
  }
}