import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/pokemon.dart';
import '../providers/pokemon_provider.dart';
import 'nickname_editor_dialog.dart';

class PokemonCard extends ConsumerWidget {
  const PokemonCard({super.key, required this.pokemon});

  final Pokemon pokemon;

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'grass':
        return const Color(0xFF78C850);
      case 'fire':
        return const Color(0xFFF08030);
      case 'water':
        return const Color(0xFF6890F0);
      case 'electric':
        return const Color(0xFFF8D030);
      case 'bug':
        return const Color(0xFFA8B820);
      case 'normal':
        return const Color(0xFFA8A878);
      case 'poison':
        return const Color(0xFFA040A0);
      case 'ground':
        return const Color(0xFFE0C068);
      case 'fairy':
        return const Color(0xFFEE99AC);
      case 'fighting':
        return const Color(0xFFC03028);
      case 'psychic':
        return const Color(0xFFF85888);
      case 'rock':
        return const Color(0xFFB8A038);
      case 'ghost':
        return const Color(0xFF705898);
      case 'ice':
        return const Color(0xFF98D8D8);
      case 'dragon':
        return const Color(0xFF7038F8);
      case 'dark':
        return const Color(0xFF705848);
      case 'steel':
        return const Color(0xFFB8B8D0);
      case 'flying':
        return const Color(0xFFA890F0);
      default:
        return const Color(0xFF68A090);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final surface = colorScheme.surface;

    // Real-time favorite and nickname state
    final isFavorite = ref.watch(
      favoritesProvider.select((favs) => favs.contains(pokemon.id)),
    );
    final nickname = ref.watch(
      nicknamesProvider.select((nicks) => nicks[pokemon.id]),
    );

    final hasNickname = nickname != null && nickname.trim().isNotEmpty;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header: Name / Nickname + ID + Favorite Heart
          Container(
            color: colorScheme.primary,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (hasNickname) ...[
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                '"$nickname"'.toUpperCase(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.yellowAccent,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 12,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.edit,
                              size: 11,
                              color: Colors.white70,
                            ),
                          ],
                        ),
                        Text(
                          pokemon.name.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ] else ...[
                        Text(
                          pokemon.name.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                            letterSpacing: 0.7,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Text(
                  '#${pokemon.id.toString().padLeft(3, '0')}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 11,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(width: 4),
                // Favorite Heart Indicator Button
                Tooltip(
                  message: isFavorite
                      ? 'Remove from favorites'
                      : 'Add to favorites',
                  child: InkWell(
                    onTap: () {
                      ref
                          .read(favoritesProvider.notifier)
                          .toggleFavorite(pokemon.id);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(3.0),
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.yellowAccent : Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Pokémon Image Section
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: surface,
                  border: Border.all(
                    color: colorScheme.onSurface.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Image.network(
                        pokemon.imageUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.image_not_supported_outlined,
                          size: 48,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    // Quick button to open Nickname Editor
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Tooltip(
                        message: hasNickname ? 'Edit Nickname' : 'Add Nickname',
                        child: InkWell(
                          onTap: () => NicknameEditorDialog.show(context, pokemon),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF111111)
                                  .withValues(alpha: 0.75),
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: Icon(
                              hasNickname
                                  ? Icons.edit_note
                                  : Icons.add_comment_outlined,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Types Badges
          if (pokemon.types.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              child: Wrap(
                spacing: 4,
                runSpacing: 2,
                children: pokemon.types.map((type) {
                  final typeColor = _getTypeColor(type);
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 5, vertical: 1.5),
                    decoration: BoxDecoration(
                      color: typeColor,
                      borderRadius: BorderRadius.circular(2),
                      border: Border.all(color: Colors.black26, width: 0.5),
                    ),
                    child: Text(
                      type.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

          // Card Footer
          Container(
            color: const Color(0xFF111111),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: () => NicknameEditorDialog.show(context, pokemon),
                  child: Text(
                    hasNickname ? 'NICKNAMED' : 'SET NICKNAME',
                    style: TextStyle(
                      color: hasNickname
                          ? Colors.yellowAccent
                          : Colors.white70,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                Icon(
                  Icons.catching_pokemon,
                  color: colorScheme.primary,
                  size: 16,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
