import 'package:equatable/equatable.dart';

class VideoLessonEntity extends Equatable {
  final String id;
  final String title;
  final int duration;
  final String videoUrl;
  final String thumbnailUrl;
  final int orderIndex;
  final bool isCompleted;
  final int watchedSeconds;

  const VideoLessonEntity({
    required this.id,
    required this.title,
    required this.duration,
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.orderIndex,
    required this.isCompleted,
    required this.watchedSeconds,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        duration,
        videoUrl,
        thumbnailUrl,
        orderIndex,
        isCompleted,
        watchedSeconds,
      ];
}

class VideoCourseEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final String thumbnail;
  final String category;
  final int totalLessons;
  final int totalDuration;
  final int enrolledCount;
  final bool isEnrolled;
  final double progress;
  final List<VideoLessonEntity> lessons;

  const VideoCourseEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnail,
    required this.category,
    required this.totalLessons,
    required this.totalDuration,
    required this.enrolledCount,
    required this.isEnrolled,
    required this.progress,
    required this.lessons,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        thumbnail,
        category,
        totalLessons,
        totalDuration,
        enrolledCount,
        isEnrolled,
        progress,
        lessons,
      ];
}
