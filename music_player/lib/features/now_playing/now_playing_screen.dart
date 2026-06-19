import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_player/core/theme/colors.dart';
import 'package:music_player/core/utils/format_utils.dart';
import 'package:music_player/providers/audio_provider.dart' show handlerProvider, handlerChangeProvider;
import 'package:music_player/widgets/sleep_timer_dialog.dart';
import 'dart:async';

class NowPlayingScreen extends ConsumerStatefulWidget {
  const NowPlayingScreen({super.key});

  @override
  ConsumerState<NowPlayingScreen> createState() => _NowPlayingScreenState();
}

class _NowPlayingScreenState extends ConsumerState<NowPlayingScreen> {
  Timer? _sleepTimer;

  @override
  void dispose() {
    _sleepTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final handler = ref.watch(handlerProvider);
    ref.watch(handlerChangeProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Now Playing',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.timer_outlined, color: AppColors.textPrimary),
            onPressed: () => _showSleepTimer(context),
          ),
        ],
      ),
      body: StreamBuilder<int?>(
        stream: handler.currentIndexStream,
        builder: (context, indexSnapshot) {
          final index = indexSnapshot.data;
          if (index == null) {
            return const Center(
              child: Text('No song playing', style: TextStyle(color: AppColors.textSecondary)),
            );
          }
          final queue = handler.songQueue;
          if (index >= queue.length) {
            return const Center(child: Text('No song playing', style: TextStyle(color: AppColors.textSecondary)));
          }
          final song = queue[index];

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),
                Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceCard,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.music_note,
                      size: 80,
                      color: AppColors.primary.withAlpha(150),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  song.title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  song.artist,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),
                StreamBuilder<Duration>(
                  stream: handler.positionStream,
                  builder: (context, posSnapshot) {
                    final position = posSnapshot.data ?? Duration.zero;
                    return StreamBuilder<Duration?>(
                      stream: handler.durationStream,
                      builder: (context, durSnapshot) {
                        final duration = durSnapshot.data ?? Duration.zero;
                        return Column(
                          children: [
                            SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                activeTrackColor: AppColors.primary,
                                inactiveTrackColor: AppColors.surfaceCard,
                                thumbColor: AppColors.primary,
                                overlayColor: AppColors.primary.withAlpha(40),
                                trackHeight: 4,
                                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                              ),
                              child: Slider(
                                value: duration.inMilliseconds > 0
                                    ? (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0)
                                    : 0.0,
                                onChanged: (value) {
                                  final pos = (value * duration.inMilliseconds).toInt();
                                  handler.seek(Duration(milliseconds: pos));
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    FormatUtils.formatDuration(position),
                                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                                  ),
                                  Text(
                                    FormatUtils.formatDuration(duration),
                                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 24),
                StreamBuilder<PlayerState>(
                  stream: handler.playerStateStream,
                  builder: (context, stateSnapshot) {
                    final isPlaying = stateSnapshot.data?.playing ?? false;
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.shuffle,
                            color: handler.isShuffled ? AppColors.primary : AppColors.textSecondary,
                            size: 28,
                          ),
                          onPressed: () => handler.toggleShuffle(),
                        ),
                        const SizedBox(width: 16),
                        IconButton(
                          icon: const Icon(Icons.skip_previous_rounded, color: AppColors.textPrimary, size: 36),
                          onPressed: () => handler.skipToPrevious(),
                        ),
                        const SizedBox(width: 16),
                        Container(
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: Icon(
                              isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                              color: Colors.black,
                              size: 36,
                            ),
                            onPressed: () {
                              if (isPlaying) {
                                handler.pause();
                              } else {
                                handler.play();
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        IconButton(
                          icon: const Icon(Icons.skip_next_rounded, color: AppColors.textPrimary, size: 36),
                          onPressed: () => handler.skipToNext(),
                        ),
                        const SizedBox(width: 16),
                        IconButton(
                          icon: Icon(
                            Icons.repeat_rounded,
                            color: handler.loopMode != LoopMode.off
                                ? AppColors.primary
                                : AppColors.textSecondary,
                            size: 28,
                          ),
                          onPressed: () => handler.cycleRepeatMode(),
                        ),
                      ],
                    );
                  },
                ),
                const Spacer(flex: 2),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showSleepTimer(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => SleepTimerDialog(
        onSet: (duration) {
          _sleepTimer?.cancel();
          _sleepTimer = Timer(duration, () {
            ref.read(handlerProvider).pause();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Sleep timer stopped playback'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Playback will stop in ${duration.inMinutes} minutes'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      ),
    );
  }
}
