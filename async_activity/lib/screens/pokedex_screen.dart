import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/pokemon.dart';
import '../services/pokemon_service.dart';
import '../widgets/pokemon_card.dart';

class PokedexScreen extends StatefulWidget {
  const PokedexScreen({
    super.key,
    this._service,
    required this.isDarkMode,
    required this.onToggleTheme,
  });

  final PokemonService? _service;
  final bool isDarkMode;
  final VoidCallback onToggleTheme;

  @override
  State<PokedexScreen> createState() => _PokedexScreenState();
}

class _PokedexScreenState extends State<PokedexScreen> {
  late Future<List<Pokemon>> _pokemonFuture;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _currentPage = 0;

  static const _pageSize = 10;

  @override
  void initState() {
    super.initState();
    _pokemonFuture = (widget._service ?? PokemonService()).fetchPokemon();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Pokemon> _matchingPokemon(List<Pokemon> pokemon) {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) {
      return pokemon;
    }

    return pokemon
        .where((item) => item.name.toLowerCase().contains(query))
        .toList();
  }

  void _retry() {
    setState(() {
      _pokemonFuture = (widget._service ?? PokemonService()).fetchPokemon();
      _currentPage = 0;
    });
  }

  void _updateSearch(String value) {
    setState(() {
      _searchQuery = value;
      _currentPage = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Pokedex',
          style: GoogleFonts.silkscreen(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: widget.onToggleTheme,
            tooltip: widget.isDarkMode
                ? 'Switch to light mode'
                : 'Switch to dark mode',
            icon: Icon(widget.isDarkMode ? Icons.light_mode : Icons.dark_mode),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: FutureBuilder<List<Pokemon>>(
        future: _pokemonFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _MessageState(
              icon: Icons.cloud_off_outlined,
              message: 'Could not load Pokemon.',
              actionLabel: 'Try again',
              onAction: _retry,
            );
          }

          final pokemon = snapshot.data ?? <Pokemon>[];
          if (pokemon.isEmpty) {
            return const _MessageState(
              icon: Icons.catching_pokemon,
              message: 'No Pokemon found.',
            );
          }

          final matchingPokemon = _matchingPokemon(pokemon);
          final pageCount = (matchingPokemon.length / _pageSize).ceil().clamp(
            1,
            999,
          );
          final page = _currentPage.clamp(0, pageCount - 1);
          final pageStart = page * _pageSize;
          final pageEnd = (pageStart + _pageSize).clamp(
            0,
            matchingPokemon.length,
          );
          final visiblePokemon = matchingPokemon.sublist(pageStart, pageEnd);

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.zero,
                      border: Border.all(
                        color: const Color(0xFF111111),
                        width: 2,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x33000000),
                          offset: Offset(0, 4),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'POKEDEX // TRAINER MODE',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.4,
                                ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Explore Pokemon',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Search by name or browse the pages.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: Colors.white),
                          ),
                          const SizedBox(height: 18),
                          SearchBar(
                            controller: _searchController,
                            hintText: 'Search Pokemon',
                            leading: const Icon(Icons.search),
                            trailing: [
                              if (_searchQuery.isNotEmpty)
                                IconButton(
                                  onPressed: () {
                                    _searchController.clear();
                                    _updateSearch('');
                                  },
                                  tooltip: 'Clear search',
                                  icon: const Icon(Icons.close),
                                ),
                            ],
                            onChanged: _updateSearch,
                          ),
                          const SizedBox(height: 18),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              if (matchingPokemon.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
                    child: _PaginationControls(
                      currentPage: page,
                      pageCount: pageCount,
                      onPrevious: page == 0
                          ? null
                          : () => setState(() => _currentPage--),
                      onNext: page == pageCount - 1
                          ? null
                          : () => setState(() => _currentPage++),
                    ),
                  ),
                ),
              if (matchingPokemon.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: _MessageState(
                    icon: Icons.search_off,
                    message: 'No Pokemon match your search.',
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) =>
                          PokemonCard(pokemon: visiblePokemon[index]),
                      childCount: visiblePokemon.length,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 220,
                          mainAxisExtent: 240,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _PaginationControls extends StatelessWidget {
  const _PaginationControls({
    required this.currentPage,
    required this.pageCount,
    required this.onPrevious,
    required this.onNext,
  });

  final int currentPage;
  final int pageCount;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    final foregroundColor = Theme.of(context).colorScheme.onSurface;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        OutlinedButton(
          onPressed: onPrevious,
          style: OutlinedButton.styleFrom(
            foregroundColor: foregroundColor,
            side: const BorderSide(color: Color(0xFF111111), width: 2),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10),
          ),
          child: const Icon(Icons.chevron_left),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'PAGE ${currentPage + 1} / $pageCount',
            style: TextStyle(
              color: foregroundColor,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
        ),
        OutlinedButton(
          onPressed: onNext,
          style: OutlinedButton.styleFrom(
            foregroundColor: foregroundColor,
            side: const BorderSide(color: Color(0xFF111111), width: 2),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10),
          ),
          child: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }
}

class _MessageState extends StatelessWidget {
  const _MessageState({
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48),
          const SizedBox(height: 12),
          Text(message),
          if (actionLabel != null) ...[
            const SizedBox(height: 12),
            FilledButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ],
      ),
    );
  }
}
