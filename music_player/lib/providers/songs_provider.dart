import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/data/models/song_model.dart';
import 'package:music_player/data/models/album_model.dart';
import 'package:music_player/data/models/artist_model.dart';
import 'package:music_player/data/repositories/song_repository.dart';

final songRepositoryProvider = Provider<SongRepository>((ref) => SongRepository());

final songsProvider = FutureProvider<List<SongModel>>((ref) async {
  final repo = ref.read(songRepositoryProvider);
  final result = await repo.getAllSongs();
  return result;
});

final albumsProvider = FutureProvider<List<AlbumModel>>((ref) async {
  final repo = ref.read(songRepositoryProvider);
  final result = await repo.getAllAlbums();
  return result;
});

final artistsProvider = FutureProvider<List<ArtistModel>>((ref) async {
  final repo = ref.read(songRepositoryProvider);
  final result = await repo.getAllArtists();
  return result;
});

final albumSongsProvider = FutureProvider.family<List<SongModel>, int>((ref, albumId) async {
  final repo = ref.read(songRepositoryProvider);
  final result = await repo.getAlbumSongs(albumId);
  return result;
});

final artistAlbumsProvider = FutureProvider.family<List<AlbumModel>, String>((ref, artistName) async {
  final repo = ref.read(songRepositoryProvider);
  final result = await repo.getArtistAlbums(artistName);
  return result;
});

final albumArtProvider = FutureProvider.family<Uint8List?, int>((ref, albumId) async {
  final repo = ref.read(songRepositoryProvider);
  return await repo.getAlbumArt(albumId);
});
