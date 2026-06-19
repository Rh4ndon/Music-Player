# Music Player 🎵

A clean, ad‑free MP3 player for Android built with Flutter.

I built this because I wanted a music player that respects my privacy — no ads, no tracking, no unnecessary permissions. Just play your local audio files.

## Features

- Browse songs, albums, and artists from your device
- Create and manage custom playlists
- Search your music library
- Shuffle, repeat, and sleep timer
- Persistent notification with playback controls
- Dark theme with green accent
- No ads. No internet permission. No nonsense.

## Tech Stack

- **Flutter** & **Dart**
- **Riverpod** – state management
- **just_audio** – audio playback
- **audio_service** – background playback & notification controls
- **on_audio_query** – query device audio files
- **sqflite** – local playlist database

## Build

```bash
cd music_player
flutter pub get
flutter run --release
```

Minimum Android SDK: 21  
Target: Android 14+

## License

This project is open source under the MIT License.

## Support

If you find this useful, consider buying me a coffee ☕

[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/rh4ndon)
