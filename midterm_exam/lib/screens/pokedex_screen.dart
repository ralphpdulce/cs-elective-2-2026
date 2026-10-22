import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/pokemon.dart';
import '../providers/pokemon_provider.dart';
import '../widgets/favorites_panel.dart';
import '../widgets/pokemon_card.dart';

class PokedexScreen extends ConsumerStatefulWidget {
  const PokedexScreen({
    super.key,
    required this.isDarkMode,
    required this.onToggleTheme,
  });

  final bool isDarkMode;
  final VoidCallback onToggleTheme;

  @override
  ConsumerState<PokedexScreen> createState() => _PokedexScreenState();
}

class _PokedexScreenState extends ConsumerState<PokedexScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _currentPage = 0;
  static const _pageSize = 10;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    setState(() => _currentPage = 0);
    ref.read(searchQueryProvider.notifier).state = value;
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() => _currentPage = 0);
    ref.read(searchQueryProvider.notifier).state = '';
  }

  void _selectType(String? type) {
    setState(() => _currentPage = 0);
    ref.read(typeFilterProvider.notifier).setType(type);
  }

  void _retry() {
    setState(() => _currentPage = 0);
    // Recalls existing fetch() method via the chosen state management
    ref.read(pokemonListProvider.notifier).fetchPokemon();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final listState = ref.watch(pokemonListProvider);
    final selectedType = ref.watch(typeFilterProvider);
    final availableTypes = ref.watch(availableTypesProvider);
    final filteredPokemon = ref.watch(filteredPokemonProvider);
    final favoriteCount =
        ref.watch(favoritesProvider.select((favs) => favs.length));
    final isFavPanelOpen = ref.watch(favoritesPanelExpandedProvider);

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
          // Favorites Panel Retractable Toggle
          IconButton(
            onPressed: () {
              ref.read(favoritesPanelExpandedProvider.notifier).state =
                  !isFavPanelOpen;
            },
            tooltip: isFavPanelOpen
                ? 'Hide Favorites Squad'
                : 'Show Favorites Squad',
            icon: Badge(
              label: Text('$favoriteCount'),
              isLabelVisible: favoriteCount > 0,
              backgroundColor: const Color(0xFFE3350D),
              textColor: Colors.white,
              child: Icon(
                isFavPanelOpen ? Icons.favorite : Icons.favorite_border,
                color: isFavPanelOpen ? Colors.yellowAccent : Colors.white,
              ),
            ),
          ),
          // Refresh Button: Recalls existing fetch() method via state management
          IconButton(
            onPressed: listState.status == PokemonStatus.loading ? null : _retry,
            tooltip: 'Refresh Pokémon list',
            icon: const Icon(Icons.refresh),
          ),
          // Theme Toggle
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
      body: Column(
        children: [
          // Retractable Favorites Panel across the app
          const FavoritesPanel(),

          // Main Content with Pull-To-Refresh
          Expanded(
            child: RefreshIndicator(
              // Recalls existing fetch() method via state management
              onRefresh: () =>
                  ref.read(pokemonListProvider.notifier).fetchPokemon(),
              color: colorScheme.primary,
              child: _buildBody(
                context,
                listState,
                filteredPokemon,
                selectedType,
                availableTypes,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    PokemonListState listState,
    List<Pokemon> filteredPokemon,
    String? selectedType,
    List<String> availableTypes,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    // Loading State
    if (listState.status == PokemonStatus.loading &&
        listState.pokemon.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Fetching Pokémon from PokéAPI...',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }

    // Error State
    if (listState.status == PokemonStatus.error && listState.pokemon.isEmpty) {
      return Center(
        child: _MessageState(
          icon: Icons.cloud_off_outlined,
          message: listState.errorMessage ?? 'Could not load Pokémon.',
          actionLabel: 'Try again',
          onAction: _retry,
        ),
      );
    }

    // Empty list from API
    if (listState.pokemon.isEmpty) {
      return const Center(
        child: _MessageState(
          icon: Icons.catching_pokemon,
          message: 'No Pokémon found in database.',
        ),
      );
    }

    // Pagination Calculation
    final pageCount =
        (filteredPokemon.length / _pageSize).ceil().clamp(1, 999);
    final page = _currentPage.clamp(0, pageCount - 1);
    final pageStart = page * _pageSize;
    final pageEnd = (pageStart + _pageSize).clamp(0, filteredPokemon.length);
    final visiblePokemon = filteredPokemon.sublist(pageStart, pageEnd);

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        // Header Banner & Controls
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.zero,
                border: Border.all(color: const Color(0xFF111111), width: 2),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x33000000),
                    offset: Offset(0, 4),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'POKEDEX // TRAINER MODE',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.4,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Explore Pokémon',
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${listState.pokemon.length} Pokémon loaded • ${filteredPokemon.length} matching',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    const SizedBox(height: 14),

                    // Search Bar
                    SearchBar(
                      controller: _searchController,
                      hintText: 'Search by name or nickname...',
                      leading: const Icon(Icons.search),
                      trailing: [
                        if (_searchController.text.isNotEmpty)
                          IconButton(
                            onPressed: _clearSearch,
                            tooltip: 'Clear search',
                            icon: const Icon(Icons.close),
                          ),
                      ],
                      onChanged: _onSearchChanged,
                    ),

                    const SizedBox(height: 14),

                    // Requirement 5: Pokémon Type Filter
                    Row(
                      children: [
                        const Icon(Icons.filter_alt, size: 16, color: Colors.white),
                        const SizedBox(width: 6),
                        const Text(
                          'TYPE FILTER:',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 11,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const Spacer(),
                        if (selectedType != null)
                          InkWell(
                            onTap: () => _selectType(null),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4),
                              child: Text(
                                'CLEAR FILTER',
                                style: TextStyle(
                                  color: Colors.yellowAccent,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Type Filter Chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          ChoiceChip(
                            label: const Text('ALL'),
                            selected: selectedType == null,
                            onSelected: (_) => _selectType(null),
                            selectedColor: Colors.white,
                            labelStyle: TextStyle(
                              color: selectedType == null
                                  ? const Color(0xFF111111)
                                  : Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                            backgroundColor: const Color(0xFF111111),
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero,
                            ),
                          ),
                          const SizedBox(width: 6),
                          ...availableTypes.map((type) {
                            final isSelected = selectedType?.toLowerCase() ==
                                type.toLowerCase();
                            return Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: ChoiceChip(
                                label: Text(type.toUpperCase()),
                                selected: isSelected,
                                onSelected: (selected) {
                                  _selectType(selected ? type : null);
                                },
                                selectedColor: Colors.yellowAccent,
                                labelStyle: TextStyle(
                                  color: isSelected
                                      ? const Color(0xFF111111)
                                      : Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                                backgroundColor: const Color(0xFF111111),
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.zero,
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Pagination Controls
        if (filteredPokemon.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: _PaginationControls(
                currentPage: page,
                pageCount: pageCount,
                onPrevious:
                    page == 0 ? null : () => setState(() => _currentPage--),
                onNext: page == pageCount - 1
                    ? null
                    : () => setState(() => _currentPage++),
              ),
            ),
          ),

        // Empty Search / Filter State
        if (filteredPokemon.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.search_off, size: 54, color: Colors.grey),
                    const SizedBox(height: 12),
                    const Text(
                      'No Pokémon match your current filter.',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      selectedType != null
                          ? 'Type filter: "$selectedType"'
                          : 'Try adjusting your search query.',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 14),
                    FilledButton.icon(
                      onPressed: () {
                        _clearSearch();
                        _selectType(null);
                      },
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('CLEAR ALL FILTERS'),
                      style: FilledButton.styleFrom(
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          // Pokémon Grid View
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (context, index) =>
                    PokemonCard(pokemon: visiblePokemon[index]),
                childCount: visiblePokemon.length,
              ),
              gridDelegate:
                  const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 220,
                mainAxisExtent: 270,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
            ),
          ),
      ],
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
            FilledButton(
              onPressed: onAction,
              style: FilledButton.styleFrom(
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
              ),
              child: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}
