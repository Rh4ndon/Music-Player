class FormatUtils {
  static String formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    final hours = duration.inHours;
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  static String formatSongCount(int count) {
    return '$count ${count == 1 ? 'song' : 'songs'}';
  }

  static String formatAlbumCount(int count) {
    return '$count ${count == 1 ? 'album' : 'albums'}';
  }
}
