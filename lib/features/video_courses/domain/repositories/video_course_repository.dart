import '../entities/video_course_entity.dart';

abstract class VideoCourseRepository {
  Future<List<VideoCourseEntity>> getCourses({
    String? category,
    String? search,
    int? page,
  });
  Future<VideoCourseEntity> getCourseById(String id);
  Future<VideoLessonEntity> getLesson({
    required String courseId,
    required String lessonId,
  });
  Future<void> enrolInCourse(String courseId);
  Future<void> updateLessonProgress({
    required String courseId,
    required String lessonId,
    required int watchedSeconds,
    required bool completed,
  });
}
