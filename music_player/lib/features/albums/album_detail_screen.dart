import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/core/theme/colors.dart';
import 'package:music_player/core/utils/format_utils.dart';
import 'package:music_player/data/models/album_model.dart';
import 'package:music_player/providers/songs_provider.dart';
import 'package:music_player/providers/audio_provider.dart' show handlerProvider, currentIndexProvider;
import 'package:music_player/widgets/song_tile.dart';
import 'package:music_player/features/playlists/create_playlist_dialog.dart';
import 'package:music_player/providers/playlist_provider.dart';
import 'package:music_player/features/now_playing/now_playing_screen.dart';

class AlbumDetailScreen extends ConsumerWidget {
  final AlbumModel album;

  const AlbumDetailScreen({super.key, required this.album});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final songsAsync = ref.watch(albumSongsProvider(album.id));
    final currentIndex = ref.watch(currentIndexProvider).valueOrNull;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(album.title),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.album, size: 60),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        album.title,
                        style: theme.textTheme.headlineSmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        album.artist,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        FormatUtils.formatSongCount(album.songCount),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _ActionButton(
                            icon: Icons.play_arrow_rounded,
                            label: 'Play',
                            onTap: () async {
                              final songs = await ref.read(albumSongsProvider(album.id).future);
                              if (songs.isNotEmpty) {
                                final handler = ref.read(handlerProvider);
                                handler.disableShuffle();
                                await handler.setSongs(songs, initialIndex: 0);
                                handler.play();
                              }
                            },
                            compact: true,
                          ),
                          const SizedBox(width: 12),
                          _ActionButton(
                            icon: Icons.shuffle,
                            label: 'Shuffle',
                            onTap: () async {
                              final songs = await ref.read(albumSongsProvider(album.id).future);
                              if (songs.isNotEmpty) {
                                final randomIndex = Random().nextInt(songs.length);
                                await ref.read(handlerProvider).setSongs(songs, initialIndex: randomIndex);
                                ref.read(handlerProvider).toggleShuffle();
                                ref.read(handlerProvider).play();
                              }
                            },
                            compact: true,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: songsAsync.when(
              data: (songs) => ListView.builder(
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
                      await handler.setSongs(songs, initialIndex: index);
                      handler.play();
                      if (context.mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const NowPlayingScreen()),
                        );
                      }
                    },
                    onAddToPlaylist: () => _addToPlaylist(context, ref, song),
                  );
                },
              ),
              error: (error, _) => Center(child: Text('Error: $error')),
              loading: () => const Center(child: CircularProgressIndicator()),
            ),
          ),
        ],
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

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool compact;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceCard,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 16 : 24,
            vertical: 10,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: AppColors.textPrimary, size: 20),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
