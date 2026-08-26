import '../../domain/entities/video_course_entity.dart';
import '../../domain/repositories/video_course_repository.dart';
import '../datasources/video_course_remote_datasource.dart';

class VideoCourseRepositoryImpl implements VideoCourseRepository {
  final VideoCourseRemoteDataSource _remoteDataSource;

  VideoCourseRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<VideoCourseEntity>> getCourses({
    String? category,
    String? search,
    int? page,
  }) =>
      _remoteDataSource.getCourses(
        category: category,
        search: search,
        page: page,
      );

  @override
  Future<VideoCourseEntity> getCourseById(String id) =>
      _remoteDataSource.getCourseById(id);

  @override
  Future<VideoLessonEntity> getLesson({
    required String courseId,
    required String lessonId,
  }) =>
      _remoteDataSource.getLesson(courseId: courseId, lessonId: lessonId);

  @override
  Future<void> enrolInCourse(String courseId) =>
      _remoteDataSource.enrolInCourse(courseId);

  @override
  Future<void> updateLessonProgress({
    required String courseId,
    required String lessonId,
    required int watchedSeconds,
    required bool completed,
  }) =>
      _remoteDataSource.updateLessonProgress(
        courseId: courseId,
        lessonId: lessonId,
        watchedSeconds: watchedSeconds,
        completed: completed,
      );
}
