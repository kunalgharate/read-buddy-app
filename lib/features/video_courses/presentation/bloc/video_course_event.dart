part of 'video_course_bloc.dart';

sealed class VideoCourseEvent extends Equatable {
  const VideoCourseEvent();
  @override
  List<Object?> get props => [];
}

final class LoadVideoCourses extends VideoCourseEvent {
  final String? category;
  final int? page;
  const LoadVideoCourses({this.category, this.page});
  @override
  List<Object?> get props => [category, page];
}

final class SearchVideoCourses extends VideoCourseEvent {
  final String query;
  const SearchVideoCourses(this.query);
  @override
  List<Object?> get props => [query];
}

final class LoadVideoCourseDetail extends VideoCourseEvent {
  final String courseId;
  const LoadVideoCourseDetail(this.courseId);
  @override
  List<Object?> get props => [courseId];
}

final class LoadVideoLesson extends VideoCourseEvent {
  final String courseId;
  final String lessonId;
  const LoadVideoLesson({required this.courseId, required this.lessonId});
  @override
  List<Object?> get props => [courseId, lessonId];
}

final class EnrolInVideoCourse extends VideoCourseEvent {
  final String courseId;
  const EnrolInVideoCourse(this.courseId);
  @override
  List<Object?> get props => [courseId];
}

final class UpdateVideoLessonProgress extends VideoCourseEvent {
  final String courseId;
  final String lessonId;
  final int watchedSeconds;
  final bool completed;
  const UpdateVideoLessonProgress({
    required this.courseId,
    required this.lessonId,
    required this.watchedSeconds,
    required this.completed,
  });
  @override
  List<Object?> get props => [courseId, lessonId, watchedSeconds, completed];
}
