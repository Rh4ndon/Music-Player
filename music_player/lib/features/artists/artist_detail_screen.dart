import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/core/theme/colors.dart';
import 'package:music_player/core/utils/format_utils.dart';
import 'package:music_player/data/models/artist_model.dart';
import 'package:music_player/providers/songs_provider.dart';
import 'package:music_player/providers/audio_provider.dart' show handlerProvider;
import 'package:music_player/widgets/album_card.dart';
import 'package:music_player/features/albums/album_detail_screen.dart';

class ArtistDetailScreen extends ConsumerWidget {
  final ArtistModel artist;

  const ArtistDetailScreen({super.key, required this.artist});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final albumsAsync = ref.watch(artistAlbumsProvider(artist.name));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(artist.name),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 44,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  child: const Icon(Icons.person, size: 48),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        artist.name,
                        style: theme.textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${FormatUtils.formatAlbumCount(artist.albumCount)} · ${FormatUtils.formatSongCount(artist.songCount)}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _ActionButton(
                            icon: Icons.play_arrow_rounded,
                            label: 'Play All',
                            onTap: () async {
                              final allSongs = await ref.read(songsProvider.future);
                              final artistSongs = allSongs.where((s) => s.artist == artist.name).toList();
                              if (artistSongs.isNotEmpty) {
                                final handler = ref.read(handlerProvider);
                                handler.disableShuffle();
                                await handler.setSongs(artistSongs, initialIndex: 0);
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
                              final allSongs = await ref.read(songsProvider.future);
                              final artistSongs = allSongs.where((s) => s.artist == artist.name).toList();
                              if (artistSongs.isNotEmpty) {
                                final randomIndex = Random().nextInt(artistSongs.length);
                                await ref.read(handlerProvider).setSongs(artistSongs, initialIndex: randomIndex);
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Albums',
              style: theme.textTheme.titleLarge,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: albumsAsync.when(
              data: (albums) {
                if (albums.isEmpty) {
                  return Center(
                    child: Text('No albums found', style: theme.textTheme.bodyMedium),
                  );
                }
                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.85,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: albums.length,
                  itemBuilder: (context, index) {
                    final album = albums[index];
                    return AlbumCard(
                      album: album,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AlbumDetailScreen(album: album),
                          ),
                        );
                      },
                    );
                  },
                );
              },
              error: (error, _) => Center(child: Text('Error: $error')),
              loading: () => const Center(child: CircularProgressIndicator()),
            ),
          ),
        ],
      ),
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
