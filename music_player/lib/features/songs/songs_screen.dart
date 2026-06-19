import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/core/theme/colors.dart';
import 'package:music_player/data/models/song_model.dart';
import 'package:music_player/providers/songs_provider.dart';
import 'package:music_player/providers/audio_provider.dart' show handlerProvider, currentIndexProvider;
import 'package:music_player/providers/playlist_provider.dart';
import 'package:music_player/widgets/song_tile.dart';
import 'package:music_player/features/playlists/create_playlist_dialog.dart';

class SongsScreen extends ConsumerWidget {
  const SongsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final songsAsync = ref.watch(songsProvider);
    final theme = Theme.of(context);

    return songsAsync.when(
      data: (songs) => _buildSongsList(context, ref, songs, theme),
      error: (error, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text('Failed to load songs', style: theme.textTheme.bodyLarge),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => ref.invalidate(songsProvider),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildSongsList(
    BuildContext context,
    WidgetRef ref,
    List<SongModel> songs,
    ThemeData theme,
  ) {
    final currentIndex = ref.watch(currentIndexProvider).valueOrNull;
    if (songs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.library_music_outlined, size: 64, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(height: 16),
            Text('No songs found', style: theme.textTheme.bodyLarge),
            const SizedBox(height: 8),
            Text(
              'Make sure you have audio files on your device',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: _ActionButton(
                  icon: Icons.play_arrow_rounded,
                  label: 'Play All',
                  onTap: () async {
                    final handler = ref.read(handlerProvider);
                    handler.disableShuffle();
                    await handler.setSongs(songs, initialIndex: 0);
                    handler.play();
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ActionButton(
                  icon: Icons.shuffle,
                  label: 'Shuffle',
                  onTap: () async {
                    final handler = ref.read(handlerProvider);
                    final randomIndex = Random().nextInt(songs.length);
                    await handler.setSongs(songs, initialIndex: randomIndex);
                    handler.toggleShuffle();
                    handler.play();
                  },
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 80),
            itemCount: songs.length,
            itemBuilder: (context, index) {
              final song = songs[index];
              final handler = ref.read(handlerProvider);

              return SongTile(
                song: song,
                index: index,
                isPlaying: currentIndex == index,
                onTap: () async {
                  handler.disableShuffle();
                  await handler.setSongs(songs, initialIndex: index);
                  handler.play();
                },
                onAddToPlaylist: () => _addToPlaylist(context, ref, song),
              );
            },
          ),
        ),
      ],
    );
  }

  void _addToPlaylist(BuildContext context, WidgetRef ref, SongModel song) {
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
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[600],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Add to playlist',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      TextButton.icon(
                        onPressed: () async {
                          final name = await showDialog<String>(
                            context: context,
                            builder: (_) => const CreatePlaylistDialog(),
                          );
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
                  Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(
                      'No playlists yet',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  )
                else
                  ...playlistList.map((playlist) => ListTile(
                    leading: const Icon(Icons.playlist_play),
                    title: Text(playlist.name),
                    subtitle: Text('${playlist.songs.length} songs'),
                    onTap: () {
                      ref.read(playlistProvider.notifier)
                          .addSongToPlaylist(playlist.id!, song.id);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Added to "${playlist.name}"'),
                          behavior: SnackBarBehavior.floating,
                        ),
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

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceCard,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppColors.textPrimary, size: 22),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
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
