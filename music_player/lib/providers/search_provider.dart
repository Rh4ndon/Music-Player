import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_player/data/models/song_model.dart';
import 'songs_provider.dart';

final searchResultsProvider = FutureProvider.family<List<SongModel>, String>((ref, query) async {
  if (query.isEmpty) return [];
  final repo = ref.read(songRepositoryProvider);
  final result = await repo.searchSongs(query);
  return result;
});
