import '../../domain/entities/book_variant_entity.dart';

class MediaPartModel extends MediaPartEntity {
  const MediaPartModel({
    required super.partNumber,
    required super.title,
    super.audioUrl,
    super.videoUrl,
    required super.duration,
  });

  factory MediaPartModel.fromJson(Map<String, dynamic> json) {
    return MediaPartModel(
      partNumber: json['partNumber'] ?? 0,
      title: json['title'] ?? '',
      audioUrl: json['audioUrl'],
      videoUrl: json['videoUrl'],
      duration: json['duration'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'partNumber': partNumber,
      'title': title,
      'duration': duration,
    };
    if (audioUrl != null) map['audioUrl'] = audioUrl;
    if (videoUrl != null) map['videoUrl'] = videoUrl;
    return map;
  }

  factory MediaPartModel.fromEntity(MediaPartEntity entity) {
    return MediaPartModel(
      partNumber: entity.partNumber,
      title: entity.title,
      audioUrl: entity.audioUrl,
      videoUrl: entity.videoUrl,
      duration: entity.duration,
    );
  }
}
