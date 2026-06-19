import 'song_model.dart';

class PlaylistModel {
  final int? id;
  final String name;
  final DateTime createdAt;
  final List<SongModel> songs;

  PlaylistModel({
    this.id,
    required this.name,
    DateTime? createdAt,
    this.songs = const [],
  }) : createdAt = createdAt ?? DateTime.now();

  int get songCount => songs.length;

  PlaylistModel copyWith({
    int? id,
    String? name,
    DateTime? createdAt,
    List<SongModel>? songs,
  }) {
    return PlaylistModel(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      songs: songs ?? this.songs,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory PlaylistModel.fromMap(Map<String, dynamic> map) {
    return PlaylistModel(
      id: map['id'],
      name: map['name'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}
