class ArtistModel {
  final int id;
  final String name;
  final int songCount;
  final int albumCount;
  final String? albumArtPath;

  ArtistModel({
    required this.id,
    required this.name,
    required this.songCount,
    required this.albumCount,
    this.albumArtPath,
  });

  factory ArtistModel.fromMap(Map<String, dynamic> map) {
    return ArtistModel(
      id: map['_id'] ?? map['artist_id'] ?? map['id'] ?? 0,
      name: map['artist'] ?? 'Unknown Artist',
      songCount: map['song_count'] ?? map['number_of_songs'] ?? 0,
      albumCount: map['album_count'] ?? map['number_of_albums'] ?? 0,
      albumArtPath: map['album_art'],
    );
  }
}
