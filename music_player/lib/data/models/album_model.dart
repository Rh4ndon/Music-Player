import 'song_model.dart';

class AlbumModel {
  final int id;
  final String title;
  final String artist;
  final String? albumArtPath;
  final int songCount;
  final List<SongModel> songs;

  AlbumModel({
    required this.id,
    required this.title,
    required this.artist,
    this.albumArtPath,
    required this.songCount,
    this.songs = const [],
  });

  factory AlbumModel.fromMap(Map<String, dynamic> map) {
    return AlbumModel(
      id: map['_id'] ?? map['album_id'] ?? map['id'] ?? 0,
      title: map['album'] ?? map['title'] ?? 'Unknown Album',
      artist: map['artist'] ?? 'Unknown Artist',
      albumArtPath: map['album_art'],
      songCount: map['song_count'] ?? map['number_of_songs'] ?? 0,
    );
  }

  AlbumModel copyWith({List<SongModel>? songs}) {
    return AlbumModel(
      id: id,
      title: title,
      artist: artist,
      albumArtPath: albumArtPath,
      songCount: songCount,
      songs: songs ?? this.songs,
    );
  }
}
