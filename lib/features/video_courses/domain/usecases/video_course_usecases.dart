import '../entities/video_course_entity.dart';
import '../repositories/video_course_repository.dart';

class GetVideoCourses {
  final VideoCourseRepository _repository;
  GetVideoCourses(this._repository);

  Future<List<VideoCourseEntity>> call({
    String? category,
    String? search,
    int? page,
  }) =>
      _repository.getCourses(category: category, search: search, page: page);
}

class GetVideoCourseById {
  final VideoCourseRepository _repository;
  GetVideoCourseById(this._repository);

  Future<VideoCourseEntity> call(String id) => _repository.getCourseById(id);
}

class GetVideoLesson {
  final VideoCourseRepository _repository;
  GetVideoLesson(this._repository);

  Future<VideoLessonEntity> call({
    required String courseId,
    required String lessonId,
  }) =>
      _repository.getLesson(courseId: courseId, lessonId: lessonId);
}

class EnrolInCourse {
  final VideoCourseRepository _repository;
  EnrolInCourse(this._repository);

  Future<void> call(String courseId) => _repository.enrolInCourse(courseId);
}

class UpdateLessonProgress {
  final VideoCourseRepository _repository;
  UpdateLessonProgress(this._repository);

  Future<void> call({
    required String courseId,
    required String lessonId,
    required int watchedSeconds,
    required bool completed,
  }) =>
      _repository.updateLessonProgress(
        courseId: courseId,
        lessonId: lessonId,
        watchedSeconds: watchedSeconds,
        completed: completed,
      );
}
