/// Audiobook domain entities — pure Dart, no framework dependencies.
library;

class AudioBookTrack {
  final String id;
  final String title;
  final int trackNumber;
  final String url;
  final Duration duration;

  const AudioBookTrack({
    required this.id,
    required this.title,
    required this.trackNumber,
    required this.url,
    required this.duration,
  });
}

class AudioBook {
  final String id;
  final String title;
  final String author;
  final String coverUrl;
  final List<AudioBookTrack> tracks;
  final Duration totalDuration;

  const AudioBook({
    required this.id,
    required this.title,
    required this.author,
    required this.coverUrl,
    required this.tracks,
    required this.totalDuration,
  });

  bool get isSinglePart => tracks.length == 1;
}
