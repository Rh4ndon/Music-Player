class SongModel {
  final int id;
  final String title;
  final String artist;
  final String? artistId;
  final String? album;
  final int? albumId;
  final String? albumArtPath;
  final String uri;
  final int duration;
  final int size;
  final String? dataAdded;

  SongModel({
    required this.id,
    required this.title,
    required this.artist,
    this.artistId,
    this.album,
    this.albumId,
    this.albumArtPath,
    required this.uri,
    required this.duration,
    required this.size,
    this.dataAdded,
  });

  Duration get durationDuration => Duration(milliseconds: duration);

  factory SongModel.fromMap(Map<String, dynamic> map) {
    return SongModel(
      id: map['_id'] ?? map['id'] ?? 0,
      title: map['title'] ?? map['display_name'] ?? 'Unknown',
      artist: map['artist'] ?? 'Unknown Artist',
      artistId: map['artist_id']?.toString(),
      album: map['album'] ?? 'Unknown Album',
      albumId: map['album_id'],
      albumArtPath: map['album_art'],
      uri: map['uri'] ?? map['_data'] ?? '',
      duration: map['duration'] ?? 0,
      size: map['size'] ?? 0,
      dataAdded: map['date_added']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'artist_id': artistId,
      'album': album,
      'album_id': albumId,
      'album_art': albumArtPath,
      'uri': uri,
      'duration': duration,
      'size': size,
    };
  }
}
