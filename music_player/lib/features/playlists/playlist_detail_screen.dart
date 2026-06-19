import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/data/models/playlist_model.dart';
import 'package:music_player/providers/audio_provider.dart' show handlerProvider, currentIndexProvider;
import 'package:music_player/providers/playlist_provider.dart';
import 'package:music_player/widgets/song_tile.dart';
import 'package:music_player/features/now_playing/now_playing_screen.dart';

class PlaylistDetailScreen extends ConsumerStatefulWidget {
  final PlaylistModel playlist;

  const PlaylistDetailScreen({super.key, required this.playlist});

  @override
  ConsumerState<PlaylistDetailScreen> createState() => _PlaylistDetailScreenState();
}

class _PlaylistDetailScreenState extends ConsumerState<PlaylistDetailScreen> {
  late Future<List> _songsFuture;

  @override
  void initState() {
    super.initState();
    _songsFuture = ref.read(playlistProvider.notifier).getPlaylistSongs(widget.playlist.id!);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentIndex = ref.watch(currentIndexProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.playlist.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.shuffle),
            onPressed: () async {
              final songs = await _songsFuture;
              if (songs.isNotEmpty) {
                final handler = ref.read(handlerProvider);
                final randomIndex = Random().nextInt(songs.length);
                await handler.setSongs(songs.cast(), initialIndex: randomIndex);
                handler.toggleShuffle();
                handler.play();
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<List>(
        future: _songsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final songs = snapshot.data ?? [];
          if (songs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.library_music_outlined, size: 64, color: theme.colorScheme.onSurfaceVariant),
                  const SizedBox(height: 16),
                  Text('No songs in this playlist', style: theme.textTheme.bodyLarge),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 80),
            itemCount: songs.length,
            itemBuilder: (context, index) {
              final song = songs[index];

              return SongTile(
                song: song,
                index: index,
                isPlaying: currentIndex == index,
                onTap: () async {
                  final handler = ref.read(handlerProvider);
                  handler.disableShuffle();
                  await handler.setSongs(songs.cast(), initialIndex: index);
                  handler.play();
                  if (context.mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const NowPlayingScreen()),
                    );
                  }
                },
                onAddToPlaylist: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Already in this playlist'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
