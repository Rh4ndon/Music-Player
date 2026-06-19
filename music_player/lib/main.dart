import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audio_service/audio_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:music_player/app/app.dart';
import 'package:music_player/core/theme/app_theme.dart';
import 'package:music_player/data/repositories/audio_handler.dart';
import 'package:music_player/providers/audio_provider.dart';

SongAudioHandler? _globalHandler;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (await Permission.notification.isDenied) {
    await Permission.notification.request();
  }

  await AudioService.init(
    builder: () {
      _globalHandler = SongAudioHandler();
      return _globalHandler!;
    },
    config: AudioServiceConfig(
      androidNotificationChannelId: 'com.musicplayer.music_player.channel.audio',
      androidNotificationChannelName: 'Music Player',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
      androidNotificationIcon: 'mipmap/ic_launcher',
    ),
  );

  runApp(
    ProviderScope(
      overrides: [handlerProvider.overrideWithValue(_globalHandler!)],
      child: const MusicPlayerApp(),
    ),
  );
}

class MusicPlayerApp extends StatelessWidget {
  const MusicPlayerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Music Player',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const App(),
    );
  }
}
