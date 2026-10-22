import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/pokemon_provider.dart';
import 'nickname_editor_dialog.dart';

class FavoritesPanel extends ConsumerWidget {
  const FavoritesPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isExpanded = ref.watch(favoritesPanelExpandedProvider);
    final favoritePokemon = ref.watch(favoritePokemonProvider);
    final nicknames = ref.watch(nicknamesProvider);

    return AnimatedCrossFade(
      firstChild: const SizedBox(width: double.infinity, height: 0),
      secondChild: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Color(0xFF1B1B1B),
          border: Border(
            bottom: BorderSide(color: Color(0xFFE3350D), width: 3),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black45,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header: Title + Collapse Action
            Row(
              children: [
                const Icon(
                  Icons.favorite,
                  color: Color(0xFFE3350D),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'FAVORITE SQUAD (${favoritePokemon.length})',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                    fontSize: 13,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white70, size: 20),
                  onPressed: () {
                    ref.read(favoritesPanelExpandedProvider.notifier).state =
                        false;
                  },
                  tooltip: 'Collapse Favorites Panel',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Content: Empty State or Favorite Pokémon List
            if (favoritePokemon.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF111111),
                  border: Border.all(color: Colors.white12),
                ),
                child: const Column(
                  children: [
                    Icon(
                      Icons.favorite_border,
                      color: Colors.white38,
                      size: 32,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'NO FAVORITES YET',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        letterSpacing: 0.8,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Tap the heart icon on any Pokémon card to add it to your squad!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              )
            else
              SizedBox(
                height: 110,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: favoritePokemon.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final pokemon = favoritePokemon[index];
                    final nickname = nicknames[pokemon.id];
                    final hasNickname =
                        nickname != null && nickname.trim().isNotEmpty;

                    return Container(
                      width: 150,
                      decoration: BoxDecoration(
                        color: const Color(0xFF111111),
                        border: Border.all(
                          color: const Color(0xFFE3350D),
                          width: 1.5,
                        ),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Row(
                        children: [
                          // Image
                          SizedBox(
                            width: 50,
                            height: 50,
                            child: Image.network(
                              pokemon.imageUrl,
                              fit: BoxFit.contain,
                              errorBuilder: (_, _, _) => const Icon(
                                Icons.catching_pokemon,
                                color: Colors.white54,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (hasNickname) ...[
                                  Text(
                                    nickname.toUpperCase(),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.yellowAccent,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 10,
                                    ),
                                  ),
                                  Text(
                                    pokemon.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 9,
                                    ),
                                  ),
                                ] else ...[
                                  Text(
                                    pokemon.name.toUpperCase(),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Tooltip(
                                      message: 'Edit Nickname',
                                      child: InkWell(
                                        onTap: () => NicknameEditorDialog.show(
                                            context, pokemon),
                                        child: const Icon(
                                          Icons.edit,
                                          size: 14,
                                          color: Colors.white60,
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    Tooltip(
                                      message: 'Remove from Favorites',
                                      child: InkWell(
                                        onTap: () {
                                          ref
                                              .read(favoritesProvider.notifier)
                                              .removeFavorite(pokemon.id);
                                        },
                                        child: const Icon(
                                          Icons.favorite,
                                          size: 16,
                                          color: Color(0xFFE3350D),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
      crossFadeState: isExpanded
          ? CrossFadeState.showSecond
          : CrossFadeState.showFirst,
      duration: const Duration(milliseconds: 250),
    );
  }
}
