import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:read_buddy_app/core/theme/app_colors.dart';
import '../../domain/entities/video_course_entity.dart';
import '../bloc/video_course_bloc.dart';

class VideoLessonPage extends StatelessWidget {
  final String courseId;
  final String lessonId;
  const VideoLessonPage({
    super.key,
    required this.courseId,
    required this.lessonId,
  });

  @override
  Widget build(BuildContext context) {
    return _VideoLessonView(courseId: courseId, lessonId: lessonId);
  }
}

class _VideoLessonView extends StatelessWidget {
  final String courseId;
  final String lessonId;
  const _VideoLessonView({required this.courseId, required this.lessonId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lesson'),
        centerTitle: true,
      ),
      body: BlocConsumer<VideoCourseBloc, VideoCourseState>(
        listener: (context, state) {
          // Only show a snackbar when the lesson is marked complete —
          // not on every routine progress (slider) update.
          if (state is VideoLessonProgressUpdated && state.completed) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Lesson marked as complete!')),
            );
          }
          if (state is VideoCourseError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is VideoCourseLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          if (state is VideoLessonLoaded) {
            return _LessonContent(
              lesson: state.lesson,
              courseId: state.courseId,
            );
          }
          // Keep showing the lesson content after a progress update
          if (state is VideoLessonProgressUpdated) {
            return _LessonContent(
              lesson: state.lesson,
              courseId: state.courseId,
            );
          }
          if (state is VideoCourseError) {
            return _buildError(context);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildError(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 56, color: AppColors.error),
            const SizedBox(height: 16),
            const Text(
              'Failed to load lesson',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => context.read<VideoCourseBloc>().add(
                    LoadVideoLesson(courseId: courseId, lessonId: lessonId),
                  ),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Lesson Content ────────────────────────────────────────────────────────────

class _LessonContent extends StatefulWidget {
  final VideoLessonEntity lesson;
  final String courseId;
  const _LessonContent({required this.lesson, required this.courseId});

  @override
  State<_LessonContent> createState() => _LessonContentState();
}

class _LessonContentState extends State<_LessonContent> {
  late double _sliderValue;

  @override
  void initState() {
    super.initState();
    _sliderValue = widget.lesson.duration > 0
        ? widget.lesson.watchedSeconds / widget.lesson.duration
        : 0.0;
  }

  @override
  void didUpdateWidget(covariant _LessonContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.lesson.watchedSeconds != widget.lesson.watchedSeconds) {
      _sliderValue = widget.lesson.duration > 0
          ? widget.lesson.watchedSeconds / widget.lesson.duration
          : 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Video Player Placeholder
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              color: Colors.black87,
              child: const Center(
                child: Icon(
                  Icons.play_circle_filled_rounded,
                  size: 72,
                  color: Colors.white70,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Lesson Title
                Text(
                  widget.lesson.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                // Duration Info
                Row(
                  children: [
                    const Icon(
                      Icons.timer_outlined,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDuration(widget.lesson.duration),
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    if (widget.lesson.isCompleted)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle_rounded,
                              size: 14,
                              color: AppColors.primary,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Completed',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 24),
                // Progress Slider
                const Text(
                  'Progress',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      _formatDuration(
                        (_sliderValue * widget.lesson.duration).round(),
                      ),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Expanded(
                      child: Slider(
                        value: _sliderValue.clamp(0.0, 1.0),
                        onChanged: (value) {
                          setState(() {
                            _sliderValue = value;
                          });
                        },
                        onChangeEnd: (value) {
                          final watchedSeconds =
                              (value * widget.lesson.duration).round();
                          context.read<VideoCourseBloc>().add(
                                UpdateVideoLessonProgress(
                                  courseId: widget.courseId,
                                  lessonId: widget.lesson.id,
                                  watchedSeconds: watchedSeconds,
                                  completed: false,
                                ),
                              );
                        },
                        activeColor: AppColors.primary,
                        inactiveColor: AppColors.primary.withValues(alpha: 0.2),
                      ),
                    ),
                    Text(
                      _formatDuration(widget.lesson.duration),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Mark as Complete Button
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: widget.lesson.isCompleted
                        ? null
                        : () {
                            context.read<VideoCourseBloc>().add(
                                  UpdateVideoLessonProgress(
                                    courseId: widget.courseId,
                                    lessonId: widget.lesson.id,
                                    watchedSeconds: widget.lesson.duration,
                                    completed: true,
                                  ),
                                );
                          },
                    icon: Icon(
                      widget.lesson.isCompleted
                          ? Icons.check_circle_rounded
                          : Icons.check_rounded,
                    ),
                    label: Text(
                      widget.lesson.isCompleted
                          ? 'Lesson Completed'
                          : 'Mark as Complete',
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: widget.lesson.isCompleted
                          ? Colors.grey
                          : AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remaining = seconds % 60;
    if (minutes >= 60) {
      final hours = minutes ~/ 60;
      final mins = minutes % 60;
      return '${hours}h ${mins}m';
    }
    return '${minutes}m ${remaining}s';
  }
}
