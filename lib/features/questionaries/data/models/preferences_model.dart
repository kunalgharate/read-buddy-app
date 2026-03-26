// data/models/preference_model.dart
class PreferenceModel {
  final List<String> genres;
  final List<String> formats;
  final List<String> preferredTimes;
  final String frequency;
  final int pagesPerSession;

  PreferenceModel({
    required this.genres,
    required this.formats,
    required this.preferredTimes,
    this.frequency = 'Daily',
    this.pagesPerSession = 30,
  });

  Map<String, dynamic> toJson() => {
        'genres': genres,
        'formats': formats,
        'preferredTimes': preferredTimes,
        'frequency': frequency,
        'pagesPerSession': pagesPerSession,
      };
}
