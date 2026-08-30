import '../../domain/entities/video_course_entity.dart';

class VideoLessonModel extends VideoLessonEntity {
  const VideoLessonModel({
    required super.id,
    required super.title,
    required super.duration,
    required super.videoUrl,
    required super.thumbnailUrl,
    required super.orderIndex,
    required super.isCompleted,
    required super.watchedSeconds,
  });

  factory VideoLessonModel.fromJson(Map<String, dynamic> json) {
    return VideoLessonModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      duration: (json['duration'] ?? 0) is int
          ? json['duration'] as int
          : int.tryParse(json['duration']?.toString() ?? '0') ?? 0,
      videoUrl: json['videoUrl']?.toString() ?? '',
      thumbnailUrl: json['thumbnailUrl']?.toString() ?? '',
      orderIndex: (json['orderIndex'] ?? 0) is int
          ? json['orderIndex'] as int
          : int.tryParse(json['orderIndex']?.toString() ?? '0') ?? 0,
      isCompleted: json['isCompleted'] == true,
      watchedSeconds: (json['watchedSeconds'] ?? 0) is int
          ? json['watchedSeconds'] as int
          : int.tryParse(json['watchedSeconds']?.toString() ?? '0') ?? 0,
    );
  }

  /// Build a model from a plain domain entity (for safe serialization).
  factory VideoLessonModel.fromEntity(VideoLessonEntity e) {
    return VideoLessonModel(
      id: e.id,
      title: e.title,
      duration: e.duration,
      videoUrl: e.videoUrl,
      thumbnailUrl: e.thumbnailUrl,
      orderIndex: e.orderIndex,
      isCompleted: e.isCompleted,
      watchedSeconds: e.watchedSeconds,
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'title': title,
        'duration': duration,
        'videoUrl': videoUrl,
        'thumbnailUrl': thumbnailUrl,
        'orderIndex': orderIndex,
        'isCompleted': isCompleted,
        'watchedSeconds': watchedSeconds,
      };
}

class VideoCourseModel extends VideoCourseEntity {
  const VideoCourseModel({
    required super.id,
    required super.title,
    required super.description,
    required super.thumbnail,
    required super.category,
    required super.totalLessons,
    required super.totalDuration,
    required super.enrolledCount,
    required super.isEnrolled,
    required super.progress,
    required super.lessons,
  });

  factory VideoCourseModel.fromJson(Map<String, dynamic> json) {
    final lessonsList = json['lessons'] as List? ?? [];
    return VideoCourseModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      thumbnail: json['thumbnail']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      totalLessons: (json['totalLessons'] ?? 0) is int
          ? json['totalLessons'] as int
          : int.tryParse(json['totalLessons']?.toString() ?? '0') ?? 0,
      totalDuration: (json['totalDuration'] ?? 0) is int
          ? json['totalDuration'] as int
          : int.tryParse(json['totalDuration']?.toString() ?? '0') ?? 0,
      enrolledCount: (json['enrolledCount'] ?? 0) is int
          ? json['enrolledCount'] as int
          : int.tryParse(json['enrolledCount']?.toString() ?? '0') ?? 0,
      isEnrolled: json['isEnrolled'] == true,
      progress: (json['progress'] ?? 0.0) is double
          ? json['progress'] as double
          : double.tryParse(json['progress']?.toString() ?? '0.0') ?? 0.0,
      lessons: lessonsList
          .map((e) => VideoLessonModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'title': title,
        'description': description,
        'thumbnail': thumbnail,
        'category': category,
        'totalLessons': totalLessons,
        'totalDuration': totalDuration,
        'enrolledCount': enrolledCount,
        'isEnrolled': isEnrolled,
        'progress': progress,
        'lessons': lessons
            .map((e) => e is VideoLessonModel
                ? e.toJson()
                : VideoLessonModel.fromEntity(e).toJson())
            .toList(),
      };
}
