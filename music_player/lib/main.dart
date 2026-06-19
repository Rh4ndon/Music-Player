import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audio_service/audio_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:music_player/app/app.dart';
import 'package:music_player/core/theme/app_theme.dart';
import 'package:music_player/core/theme/colors.dart';
import 'package:music_player/data/repositories/audio_handler.dart';
import 'package:music_player/providers/audio_provider.dart';

SongAudioHandler? _globalHandler;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
      home: const PermissionGate(),
    );
  }
}

class PermissionGate extends StatefulWidget {
  const PermissionGate({super.key});

  @override
  State<PermissionGate> createState() => _PermissionGateState();
}

class _PermissionGateState extends State<PermissionGate> {
  bool _checking = true;
  bool _denied = false;
  bool _permanentlyDenied = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    setState(() {
      _checking = true;
      _denied = false;
      _permanentlyDenied = false;
    });

    Permission audioPermission;
    if (await Permission.audio.isGranted) {
      audioPermission = Permission.audio;
    } else {
      audioPermission = Permission.audio;
    }

    final audioStatus = await audioPermission.status;
    final notifStatus = await Permission.notification.status;

    if (audioStatus.isGranted && notifStatus.isGranted) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const App()),
        );
      }
      return;
    }

    if (audioStatus.isPermanentlyDenied || notifStatus.isPermanentlyDenied) {
      setState(() {
        _checking = false;
        _permanentlyDenied = true;
      });
      return;
    }

    setState(() {
      _checking = false;
      _denied = true;
    });
  }

  Future<void> _requestPermissions() async {
    setState(() => _checking = true);

    await [
      Permission.audio,
      Permission.notification,
    ].request();

    await _checkPermissions();
  }

  Future<void> _openSettings() async {
    await openAppSettings();
    if (mounted) {
      _checkPermissions();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.audiotrack, size: 80, color: AppColors.primary),
              const SizedBox(height: 24),
              const Text(
                'Music Player',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'A clean, ad-free MP3 player',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
              ),
              const SizedBox(height: 48),
              if (_checking)
                const CircularProgressIndicator(color: AppColors.primary),
              if (_permanentlyDenied)
                Column(
                  children: [
                    const Icon(Icons.warning_amber_rounded, size: 48, color: Colors.orange),
                    const SizedBox(height: 16),
                    const Text(
                      'Permissions required',
                      style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Music Player needs access to your music files and notifications to work.\n\n'
                      'Please enable these permissions in Settings.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                    ),
                    const SizedBox(height: 24),
                    _Button(
                      icon: Icons.settings,
                      label: 'Open Settings',
                      onTap: _openSettings,
                    ),
                  ],
                ),
              if (_denied)
                Column(
                  children: [
                    const Icon(Icons.library_music_outlined, size: 48, color: AppColors.primary),
                    const SizedBox(height: 16),
                    const Text(
                      'Allow access to music files?',
                      style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'This app needs permission to read your audio files and show playback notifications.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                    ),
                    const SizedBox(height: 24),
                    _Button(
                      icon: Icons.check_circle_outline,
                      label: 'Grant Permission',
                      onTap: _requestPermissions,
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Button extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _Button({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.black, size: 22),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
