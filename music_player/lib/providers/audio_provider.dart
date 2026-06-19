import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/data/repositories/audio_handler.dart';
import 'package:just_audio/just_audio.dart';

final handlerProvider = Provider<SongAudioHandler>((ref) {
  throw UnimplementedError('handlerProvider must be overridden');
});

final currentIndexProvider = StreamProvider<int?>((ref) {
  final handler = ref.watch(handlerProvider);
  return handler.currentIndexStream;
});

final playerStateProvider = StreamProvider<PlayerState>((ref) {
  final handler = ref.watch(handlerProvider);
  return handler.playerStateStream;
});

final handlerChangeProvider = StreamProvider<void>((ref) {
  final handler = ref.watch(handlerProvider);
  return handler.changeStream;
});
