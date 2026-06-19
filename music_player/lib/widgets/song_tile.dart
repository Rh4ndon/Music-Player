import 'package:flutter/material.dart';
import 'package:music_player/core/utils/format_utils.dart';
import 'package:music_player/data/models/song_model.dart';

class SongTile extends StatelessWidget {
  final SongModel song;
  final int? index;
  final bool isPlaying;
  final VoidCallback? onTap;
  final VoidCallback? onPlayNext;
  final VoidCallback? onAddToPlaylist;

  const SongTile({
    super.key,
    required this.song,
    this.index,
    this.isPlaying = false,
    this.onTap,
    this.onPlayNext,
    this.onAddToPlaylist,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: isPlaying
            ? theme.colorScheme.primary
            : theme.colorScheme.surfaceContainerHighest,
        radius: 22,
        child: Icon(
          isPlaying ? Icons.music_note : Icons.music_note_outlined,
          color: isPlaying ? Colors.black : theme.colorScheme.onSurfaceVariant,
          size: 20,
        ),
      ),
      title: Text(
        song.title,
        style: theme.textTheme.titleMedium?.copyWith(
          color: isPlaying
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurface,
          fontWeight: isPlaying ? FontWeight.w600 : null,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        song.artist,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            FormatUtils.formatDuration(song.durationDuration),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert,
              color: theme.colorScheme.onSurfaceVariant,
              size: 20,
            ),
            onSelected: (value) {
              switch (value) {
                case 'play_next':
                  onPlayNext?.call();
                case 'add_to_playlist':
                  onAddToPlaylist?.call();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'play_next',
                child: Row(
                  children: [
                    Icon(Icons.playlist_play, size: 20),
                    SizedBox(width: 12),
                    Text('Play next'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'add_to_playlist',
                child: Row(
                  children: [
                    Icon(Icons.playlist_add, size: 20),
                    SizedBox(width: 12),
                    Text('Add to playlist'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      onTap: onTap,
    );
  }
}
