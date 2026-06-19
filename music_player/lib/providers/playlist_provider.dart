import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/data/models/playlist_model.dart';
import 'package:music_player/data/datasources/database_helper.dart';
import 'package:music_player/data/models/song_model.dart';
import 'package:music_player/data/repositories/song_repository.dart';
import 'songs_provider.dart';

class PlaylistNotifier extends StateNotifier<List<PlaylistModel>> {
  final SongRepository _songRepository;

  PlaylistNotifier(this._songRepository) : super([]);

  Future<void> loadPlaylists() async {
    state = await DatabaseHelper.getPlaylists();
  }

  Future<void> createPlaylist(String name) async {
    await DatabaseHelper.createPlaylist(name);
    await loadPlaylists();
  }

  Future<void> deletePlaylist(int id) async {
    await DatabaseHelper.deletePlaylist(id);
    await loadPlaylists();
  }

  Future<void> renamePlaylist(int id, String newName) async {
    await DatabaseHelper.renamePlaylist(id, newName);
    await loadPlaylists();
  }

  Future<List<SongModel>> getPlaylistSongs(int playlistId) async {
    final songIds = await DatabaseHelper.getPlaylistSongIds(playlistId);
    final allSongs = await _songRepository.getAllSongs();
    return allSongs.where((s) => songIds.contains(s.id)).toList();
  }

  Future<void> addSongToPlaylist(int playlistId, int songId) async {
    await DatabaseHelper.addSongToPlaylist(playlistId, songId);
  }

  Future<void> removeSongFromPlaylist(int playlistId, int songId) async {
    await DatabaseHelper.removeSongFromPlaylist(playlistId, songId);
  }

  Future<bool> isSongInPlaylist(int playlistId, int songId) async {
    return await DatabaseHelper.isSongInPlaylist(playlistId, songId);
  }
}

final playlistProvider = StateNotifierProvider<PlaylistNotifier, List<PlaylistModel>>((ref) {
  final repo = ref.read(songRepositoryProvider);
  return PlaylistNotifier(repo);
});
