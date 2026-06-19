import 'dart:typed_data';
import 'package:on_audio_query/on_audio_query.dart' hide SongModel, AlbumModel, ArtistModel;
import 'package:music_player/data/models/song_model.dart';
import 'package:music_player/data/models/album_model.dart';
import 'package:music_player/data/models/artist_model.dart';

class SongRepository {
  final OnAudioQuery _audioQuery = OnAudioQuery();

  Future<bool> requestPermission() async {
    return await _audioQuery.permissionsStatus();
  }

  Future<void> requestPermissionOrAsk() async {
    await _audioQuery.permissionsRequest();
  }

  Future<List<SongModel>> getAllSongs() async {
    final songs = await _audioQuery.querySongs(
      sortType: SongSortType.TITLE,
      orderType: OrderType.ASC_OR_SMALLER,
      uriType: UriType.EXTERNAL,
    );
    return songs.map((song) => _toSongModel(song)).toList();
  }

  Future<List<AlbumModel>> getAllAlbums() async {
    final albums = await _audioQuery.queryAlbums(
      sortType: AlbumSortType.ALBUM,
      orderType: OrderType.ASC_OR_SMALLER,
      uriType: UriType.EXTERNAL,
    );
    return albums.map((album) => AlbumModel.fromMap({
      '_id': album.id,
      'album': album.album,
      'artist': album.artist ?? 'Unknown Artist',
      'album_art': null,
      'song_count': album.numOfSongs,
    })).toList();
  }

  Future<List<SongModel>> getAlbumSongs(int albumId) async {
    final songs = await _audioQuery.querySongs(
      sortType: SongSortType.TITLE,
      orderType: OrderType.ASC_OR_SMALLER,
      uriType: UriType.EXTERNAL,
    );
    return songs
      .where((s) => s.albumId == albumId)
      .map((song) => _toSongModel(song))
      .toList();
  }

  Future<List<ArtistModel>> getAllArtists() async {
    final artists = await _audioQuery.queryArtists(
      sortType: ArtistSortType.ARTIST,
      orderType: OrderType.ASC_OR_SMALLER,
      uriType: UriType.EXTERNAL,
    );
    return artists.map((artist) => ArtistModel.fromMap({
      '_id': artist.id,
      'artist': artist.artist,
      'song_count': artist.numberOfTracks ?? 0,
      'album_count': artist.numberOfAlbums ?? 0,
    })).toList();
  }

  Future<List<AlbumModel>> getArtistAlbums(String artistName) async {
    final albums = await _audioQuery.queryAlbums(
      sortType: AlbumSortType.ALBUM,
      orderType: OrderType.ASC_OR_SMALLER,
      uriType: UriType.EXTERNAL,
    );
    return albums
      .where((a) => a.artist == artistName)
      .map((album) => AlbumModel.fromMap({
        '_id': album.id,
        'album': album.album,
        'artist': album.artist ?? 'Unknown Artist',
        'album_art': null,
        'song_count': album.numOfSongs,
      }))
      .toList();
  }

  Future<Uint8List?> getAlbumArt(int albumId) async {
    return await _audioQuery.queryArtwork(
      albumId,
      ArtworkType.ALBUM,
      size: 500,
    );
  }

  Future<List<SongModel>> searchSongs(String query) async {
    final songs = await _audioQuery.querySongs(
      sortType: SongSortType.TITLE,
      orderType: OrderType.ASC_OR_SMALLER,
      uriType: UriType.EXTERNAL,
    );
    final lowerQuery = query.toLowerCase();
    return songs
      .where((s) =>
        s.title.toLowerCase().contains(lowerQuery) ||
        (s.artist?.toLowerCase().contains(lowerQuery) ?? false) ||
        (s.album?.toLowerCase().contains(lowerQuery) ?? false))
      .map((song) => _toSongModel(song))
      .toList();
  }

  SongModel _toSongModel(dynamic song) {
    return SongModel(
      id: song.id,
      title: song.title,
      artist: song.artist ?? 'Unknown Artist',
      artistId: song.artistId?.toString(),
      album: song.album ?? 'Unknown Album',
      albumId: song.albumId,
      albumArtPath: null,
      uri: song.uri ?? song.data,
      duration: song.duration ?? 0,
      size: song.size,
      dataAdded: song.dateAdded?.toString(),
    );
  }
}
