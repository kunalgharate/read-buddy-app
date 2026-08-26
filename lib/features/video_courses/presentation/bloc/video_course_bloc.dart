import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:read_buddy_app/core/utils/error_handler.dart';
import '../../domain/entities/video_course_entity.dart';
import '../../domain/usecases/video_course_usecases.dart';

part 'video_course_event.dart';
part 'video_course_state.dart';

class VideoCourseBloc extends Bloc<VideoCourseEvent, VideoCourseState> {
  final GetVideoCourses _getVideoCourses;
  final GetVideoCourseById _getVideoCourseById;
  final GetVideoLesson _getVideoLesson;
  final EnrolInCourse _enrolInCourse;
  final UpdateLessonProgress _updateLessonProgress;

  VideoCourseBloc({
    required GetVideoCourses getVideoCourses,
    required GetVideoCourseById getVideoCourseById,
    required GetVideoLesson getVideoLesson,
    required EnrolInCourse enrolInCourse,
    required UpdateLessonProgress updateLessonProgress,
  })  : _getVideoCourses = getVideoCourses,
        _getVideoCourseById = getVideoCourseById,
        _getVideoLesson = getVideoLesson,
        _enrolInCourse = enrolInCourse,
        _updateLessonProgress = updateLessonProgress,
        super(VideoCourseInitial()) {
    on<LoadVideoCourses>(_onLoadVideoCourses);
    on<LoadVideoCourseDetail>(_onLoadVideoCourseDetail);
    on<LoadVideoLesson>(_onLoadVideoLesson);
    on<EnrolInVideoCourse>(_onEnrolInCourse);
    on<UpdateVideoLessonProgress>(_onUpdateLessonProgress);
    on<SearchVideoCourses>(_onSearchVideoCourses);
  }

  Future<void> _onLoadVideoCourses(
    LoadVideoCourses event,
    Emitter<VideoCourseState> emit,
  ) async {
    emit(VideoCourseLoading());
    try {
      final courses = await _getVideoCourses(
        category: event.category,
        page: event.page,
      );
      emit(VideoCoursesLoaded(courses));
    } catch (e) {
      emit(VideoCourseError(ErrorHandler.getErrorMessage(e)));
    }
  }

  Future<void> _onSearchVideoCourses(
    SearchVideoCourses event,
    Emitter<VideoCourseState> emit,
  ) async {
    emit(VideoCourseLoading());
    try {
      final courses = await _getVideoCourses(search: event.query);
      emit(VideoCoursesLoaded(courses));
    } catch (e) {
      emit(VideoCourseError(ErrorHandler.getErrorMessage(e)));
    }
  }

  Future<void> _onLoadVideoCourseDetail(
    LoadVideoCourseDetail event,
    Emitter<VideoCourseState> emit,
  ) async {
    emit(VideoCourseLoading());
    try {
      final course = await _getVideoCourseById(event.courseId);
      emit(VideoCourseDetailLoaded(course));
    } catch (e) {
      emit(VideoCourseError(ErrorHandler.getErrorMessage(e)));
    }
  }

  Future<void> _onLoadVideoLesson(
    LoadVideoLesson event,
    Emitter<VideoCourseState> emit,
  ) async {
    emit(VideoCourseLoading());
    try {
      final lesson = await _getVideoLesson(
        courseId: event.courseId,
        lessonId: event.lessonId,
      );
      emit(VideoLessonLoaded(lesson, event.courseId));
    } catch (e) {
      emit(VideoCourseError(ErrorHandler.getErrorMessage(e)));
    }
  }

  Future<void> _onEnrolInCourse(
    EnrolInVideoCourse event,
    Emitter<VideoCourseState> emit,
  ) async {
    try {
      await _enrolInCourse(event.courseId);
      emit(VideoCourseEnrolled());
    } catch (e) {
      emit(VideoCourseError(ErrorHandler.getErrorMessage(e)));
    }
  }

  Future<void> _onUpdateLessonProgress(
    UpdateVideoLessonProgress event,
    Emitter<VideoCourseState> emit,
  ) async {
    try {
      await _updateLessonProgress(
        courseId: event.courseId,
        lessonId: event.lessonId,
        watchedSeconds: event.watchedSeconds,
        completed: event.completed,
      );
      emit(VideoLessonProgressUpdated());
    } catch (e) {
      emit(VideoCourseError(ErrorHandler.getErrorMessage(e)));
    }
  }
}
