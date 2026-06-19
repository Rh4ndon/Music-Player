import 'dart:async';
import 'package:just_audio/just_audio.dart';
import 'package:audio_service/audio_service.dart';
import 'package:music_player/data/models/song_model.dart';

class SongAudioHandler extends BaseAudioHandler {
  final AudioPlayer _player = AudioPlayer();
  List<SongModel> _allSongs = [];
  bool _isShuffled = false;
  LoopMode _loopMode = LoopMode.off;
  final StreamController<void> _changeController = StreamController<void>.broadcast();

  Stream<void> get changeStream => _changeController.stream;
  bool get isShuffled => _isShuffled;
  LoopMode get loopMode => _loopMode;
  List<SongModel> get songQueue => _allSongs;
  Stream<int?> get currentIndexStream => _player.currentIndexStream;
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;
  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  int? get currentIndex => _player.currentIndex;

  SongAudioHandler() {
    _player.setAudioSource(ConcatenatingAudioSource(children: []));

    playbackState.add(PlaybackState(
      controls: _getControls(),
      playing: false,
      processingState: AudioProcessingState.idle,
      shuffleMode: AudioServiceShuffleMode.none,
      repeatMode: AudioServiceRepeatMode.none,
      updatePosition: Duration.zero,
      bufferedPosition: Duration.zero,
      speed: 1.0,
    ));

    _player.playerStateStream.listen((state) {
      playbackState.add(PlaybackState(
        controls: _getControls(),
        playing: state.playing,
        processingState: _mapProcessingState(state.processingState),
        shuffleMode: _isShuffled ? AudioServiceShuffleMode.all : AudioServiceShuffleMode.none,
        repeatMode: _mapLoopModeToRepeatMode(_loopMode),
        updatePosition: _player.position,
        bufferedPosition: _player.bufferedPosition,
        speed: 1.0,
      ));
      _notify();
    });

    _player.currentIndexStream.listen((index) {
      if (index != null && index < _allSongs.length) {
        final song = _allSongs[index];
        mediaItem.add(MediaItem(
          id: song.id.toString(),
          title: song.title,
          artist: song.artist,
        ));
      }
      _notify();
    });

    _player.positionStream.listen((_) => _notify());
    _player.durationStream.listen((_) => _notify());
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> skipToNext() => _player.seekToNext();

  @override
  Future<void> skipToPrevious() => _player.seekToPrevious();

  @override
  Future<void> stop() => _player.stop();

  @override
  Future<void> setShuffleMode(AudioServiceShuffleMode shuffleMode) async {
    _isShuffled = shuffleMode == AudioServiceShuffleMode.all;
    await _player.setShuffleModeEnabled(_isShuffled);
    _notify();
  }

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    _loopMode = _mapRepeatModeToLoopMode(repeatMode);
    await _player.setLoopMode(_loopMode);
    _notify();
  }

  @override
  Future<void> skipToQueueItem(int index) async {
    if (index >= 0 && index < _allSongs.length) {
      _player.seek(Duration.zero, index: index);
    }
  }

  @override
  Future<void> onTaskRemoved() async {
    await _player.stop();
    await super.onTaskRemoved();
  }

  Future<void> setSongs(List<SongModel> songs, {int? initialIndex}) async {
    _allSongs = songs;
    final audioSources = songs.map((s) =>
      AudioSource.uri(Uri.parse(s.uri))
    ).toList();

    await _player.setAudioSource(
      ConcatenatingAudioSource(children: audioSources),
      initialIndex: initialIndex ?? 0,
    );

    queue.add(songs.map((s) => MediaItem(
      id: s.id.toString(),
      title: s.title,
      artist: s.artist,
    )).toList());

    if (_isShuffled) {
      await _player.setShuffleModeEnabled(true);
    }
  }

  void toggleShuffle() {
    _isShuffled = !_isShuffled;
    _player.setShuffleModeEnabled(_isShuffled);
    playbackState.add(playbackState.value.copyWith(
      shuffleMode: _isShuffled ? AudioServiceShuffleMode.all : AudioServiceShuffleMode.none,
    ));
    _notify();
  }

  void disableShuffle() {
    if (_isShuffled) {
      _isShuffled = false;
      _player.setShuffleModeEnabled(false);
      playbackState.add(playbackState.value.copyWith(
        shuffleMode: AudioServiceShuffleMode.none,
      ));
      _notify();
    }
  }

  void cycleRepeatMode() {
    switch (_loopMode) {
      case LoopMode.off:
        _loopMode = LoopMode.all;
      case LoopMode.all:
        _loopMode = LoopMode.one;
      case LoopMode.one:
        _loopMode = LoopMode.off;
    }
    _player.setLoopMode(_loopMode);
    playbackState.add(playbackState.value.copyWith(
      repeatMode: _mapLoopModeToRepeatMode(_loopMode),
    ));
    _notify();
  }

  void playSongAtIndex(int index) {
    if (index >= 0 && index < _allSongs.length) {
      skipToQueueItem(index);
      play();
    }
  }

  void _notify() {
    if (!_changeController.isClosed) {
      _changeController.add(null);
    }
  }

  List<MediaControl> _getControls() {
    return [
      MediaControl.skipToPrevious,
      MediaControl.pause,
      MediaControl.play,
      MediaControl.skipToNext,
    ];
  }

  AudioProcessingState _mapProcessingState(ProcessingState state) {
    switch (state) {
      case ProcessingState.idle: return AudioProcessingState.idle;
      case ProcessingState.loading: return AudioProcessingState.loading;
      case ProcessingState.buffering: return AudioProcessingState.buffering;
      case ProcessingState.ready: return AudioProcessingState.ready;
      case ProcessingState.completed: return AudioProcessingState.completed;
    }
  }

  AudioServiceRepeatMode _mapLoopModeToRepeatMode(LoopMode mode) {
    switch (mode) {
      case LoopMode.off: return AudioServiceRepeatMode.none;
      case LoopMode.all: return AudioServiceRepeatMode.all;
      case LoopMode.one: return AudioServiceRepeatMode.one;
    }
  }

  LoopMode _mapRepeatModeToLoopMode(AudioServiceRepeatMode mode) {
    switch (mode) {
      case AudioServiceRepeatMode.none: return LoopMode.off;
      case AudioServiceRepeatMode.one: return LoopMode.one;
      case AudioServiceRepeatMode.all: return LoopMode.all;
      case AudioServiceRepeatMode.group: return LoopMode.all;
    }
  }

  void dispose() {
    _changeController.close();
    _player.dispose();
  }
}
