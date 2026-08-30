part of 'video_course_bloc.dart';

sealed class VideoCourseState extends Equatable {
  const VideoCourseState();
  @override
  List<Object?> get props => [];
}

final class VideoCourseInitial extends VideoCourseState {}

final class VideoCourseLoading extends VideoCourseState {}

final class VideoCoursesLoaded extends VideoCourseState {
  final List<VideoCourseEntity> courses;
  const VideoCoursesLoaded(this.courses);
  @override
  List<Object?> get props => [courses];
}

final class VideoCourseDetailLoaded extends VideoCourseState {
  final VideoCourseEntity course;
  const VideoCourseDetailLoaded(this.course);
  @override
  List<Object?> get props => [course];
}

final class VideoLessonLoaded extends VideoCourseState {
  final VideoLessonEntity lesson;
  final String courseId;
  const VideoLessonLoaded(this.lesson, this.courseId);
  @override
  List<Object?> get props => [lesson, courseId];
}

final class VideoCourseEnrolled extends VideoCourseState {}

final class VideoLessonProgressUpdated extends VideoCourseState {
  final VideoLessonEntity lesson;
  final String courseId;
  final bool completed;
  const VideoLessonProgressUpdated(
    this.lesson,
    this.courseId, {
    this.completed = false,
  });
  @override
  List<Object?> get props => [lesson, courseId, completed];
}

final class VideoCourseError extends VideoCourseState {
  final String message;
  const VideoCourseError(this.message);
  @override
  List<Object?> get props => [message];
}
