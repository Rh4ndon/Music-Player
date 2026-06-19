import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/providers/search_provider.dart';
import 'package:music_player/providers/audio_provider.dart' show handlerProvider, currentIndexProvider;
import 'package:music_player/providers/playlist_provider.dart';
import 'package:music_player/features/playlists/create_playlist_dialog.dart';
import 'package:music_player/widgets/song_tile.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final resultsAsync = ref.watch(searchResultsProvider(_query));
    final currentIndex = ref.watch(currentIndexProvider).valueOrNull;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          focusNode: _focusNode,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Search songs, artists, albums...',
            hintStyle: TextStyle(color: Colors.grey),
            border: InputBorder.none,
          ),
          onChanged: (value) {
            setState(() => _query = value);
          },
        ),
        actions: [
          if (_query.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                setState(() => _query = '');
              },
            ),
        ],
      ),
      body: SafeArea(
        child: _query.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search, size: 64, color: theme.colorScheme.onSurfaceVariant),
                    const SizedBox(height: 16),
                    Text('Search your music library', style: theme.textTheme.bodyLarge),
                  ],
                ),
              )
            : resultsAsync.when(
                data: (results) {
                  if (results.isEmpty) {
                    return Center(
                      child: Text('No results for "$_query"', style: theme.textTheme.bodyMedium),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      final song = results[index];
                      return SongTile(
                        song: song,
                        index: index,
                        isPlaying: currentIndex == index,
                        onTap: () async {
                          final handler = ref.read(handlerProvider);
                          handler.disableShuffle();
                          await handler.setSongs(results, initialIndex: index);
                          handler.play();
                        },
                        onAddToPlaylist: () => _addToPlaylist(context, ref, song),
                      );
                    },
                  );
                },
                error: (error, _) => Center(child: Text('Error: $error')),
                loading: () => const Center(child: CircularProgressIndicator()),
              ),
      ),
    );
  }

  void _addToPlaylist(BuildContext context, WidgetRef ref, song) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Consumer(
          builder: (context, ref, _) {
            final playlistList = ref.watch(playlistProvider);
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[600], borderRadius: BorderRadius.circular(2))),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Add to playlist', style: Theme.of(context).textTheme.titleLarge),
                      TextButton.icon(
                        onPressed: () async {
                          final name = await showDialog<String>(context: context, builder: (_) => const CreatePlaylistDialog());
                          if (name != null && name.isNotEmpty) {
                            ref.read(playlistProvider.notifier).createPlaylist(name);
                          }
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('New'),
                      ),
                    ],
                  ),
                ),
                if (playlistList.isEmpty)
                  Padding(padding: const EdgeInsets.all(32), child: Text('No playlists yet', style: Theme.of(context).textTheme.bodyMedium))
                else
                  ...playlistList.map((playlist) => ListTile(
                    leading: const Icon(Icons.playlist_play),
                    title: Text(playlist.name),
                    subtitle: Text('${playlist.songCount} songs'),
                    onTap: () {
                      ref.read(playlistProvider.notifier).addSongToPlaylist(playlist.id!, song.id);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Added to "${playlist.name}"'), behavior: SnackBarBehavior.floating),
                      );
                    },
                  )),
                const SizedBox(height: 16),
              ],
            );
          },
        );
      },
    );
  }
}
