import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_player/core/theme/colors.dart';
import 'package:music_player/providers/audio_provider.dart' show handlerProvider, playerStateProvider, currentIndexProvider;
import 'package:music_player/features/now_playing/now_playing_screen.dart';

class MiniPlayer extends ConsumerWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final handler = ref.watch(handlerProvider);
    final playerState = ref.watch(playerStateProvider).valueOrNull;
    final index = ref.watch(currentIndexProvider).valueOrNull;

    if (playerState == null || playerState.processingState == ProcessingState.idle) {
      return const SizedBox.shrink();
    }
    if (index == null) return const SizedBox.shrink();

    final queue = handler.songQueue;
    if (index >= queue.length) return const SizedBox.shrink();
    final song = queue[index];

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const NowPlayingScreen()),
        );
      },
      child: Container(
        height: 64,
        decoration: const BoxDecoration(
          color: AppColors.surfaceCard,
          border: Border(top: BorderSide(color: AppColors.surfaceCard, width: 0.5)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(color: AppColors.primary.withAlpha(40), borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.music_note, color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(song.title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text(song.artist, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.skip_previous_rounded, color: AppColors.textPrimary, size: 28),
              onPressed: handler.skipToPrevious,
            ),
            IconButton(
              icon: Icon(playerState.playing ? Icons.pause_rounded : Icons.play_arrow_rounded, color: AppColors.textPrimary, size: 32),
              onPressed: () {
                if (playerState.playing) {
                  handler.pause();
                } else {
                  handler.play();
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.skip_next_rounded, color: AppColors.textPrimary, size: 28),
              onPressed: handler.skipToNext,
            ),
          ],
        ),
      ),
    );
  }
}
