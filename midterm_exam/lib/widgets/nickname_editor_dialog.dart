import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/pokemon.dart';
import '../providers/pokemon_provider.dart';

class NicknameEditorDialog extends ConsumerStatefulWidget {
  const NicknameEditorDialog({super.key, required this.pokemon});

  final Pokemon pokemon;

  static Future<void> show(BuildContext context, Pokemon pokemon) {
    return showDialog<void>(
      context: context,
      builder: (context) => NicknameEditorDialog(pokemon: pokemon),
    );
  }

  @override
  ConsumerState<NicknameEditorDialog> createState() =>
      _NicknameEditorDialogState();
}

class _NicknameEditorDialogState extends ConsumerState<NicknameEditorDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final currentNickname =
        ref.read(nicknamesProvider)[widget.pokemon.id] ?? '';
    _controller = TextEditingController(text: currentNickname);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _saveNickname() {
    final newNickname = _controller.text.trim();
    ref
        .read(nicknamesProvider.notifier)
        .setNickname(widget.pokemon.id, newNickname);
    Navigator.of(context).pop();
  }

  void _removeNickname() {
    ref.read(nicknamesProvider.notifier).removeNickname(widget.pokemon.id);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final currentNickname = ref.watch(nicknamesProvider)[widget.pokemon.id];
    final hasExistingNickname =
        currentNickname != null && currentNickname.trim().isNotEmpty;

    return Dialog(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
        side: BorderSide(color: Color(0xFF111111), width: 2),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                SizedBox(
                  width: 48,
                  height: 48,
                  child: Image.network(
                    widget.pokemon.imageUrl,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.catching_pokemon),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'NICKNAME EDITOR',
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                        ),
                      ),
                      Text(
                        widget.pokemon.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: 'Cancel',
                ),
              ],
            ),
            const Divider(height: 24, thickness: 1.5),
            const SizedBox(height: 8),
            TextField(
              controller: _controller,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: 'Custom Nickname',
                hintText: 'e.g. Sparky, Chomper',
                helperText: hasExistingNickname
                    ? 'Current nickname: "$currentNickname"'
                    : 'Assign a custom name to this Pokémon',
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.zero,
                ),
              ),
              onSubmitted: (_) => _saveNickname(),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                if (hasExistingNickname) ...[
                  OutlinedButton.icon(
                    onPressed: _removeNickname,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colorScheme.error,
                      side: BorderSide(color: colorScheme.error, width: 1.5),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                    ),
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: const Text('REMOVE'),
                  ),
                  const Spacer(),
                ] else ...[
                  const Spacer(),
                ],
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('CANCEL'),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: _saveNickname,
                  style: FilledButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  icon: const Icon(Icons.check, size: 18),
                  label: const Text('SAVE'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
