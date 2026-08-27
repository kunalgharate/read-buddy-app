import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:read_buddy_app/core/theme/app_colors.dart';
import '../../domain/entities/video_course_entity.dart';
import '../bloc/video_course_bloc.dart';

class VideoCourseDetailPage extends StatelessWidget {
  final String courseId;
  const VideoCourseDetailPage({super.key, required this.courseId});

  @override
  Widget build(BuildContext context) {
    return _VideoCourseDetailView(courseId: courseId);
  }
}

class _VideoCourseDetailView extends StatelessWidget {
  final String courseId;
  const _VideoCourseDetailView({required this.courseId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Course Details'),
        centerTitle: true,
      ),
      body: BlocConsumer<VideoCourseBloc, VideoCourseState>(
        listener: (context, state) {
          if (state is VideoCourseEnrolled) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Successfully enrolled in course!')),
            );
            context
                .read<VideoCourseBloc>()
                .add(LoadVideoCourseDetail(courseId));
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
          if (state is VideoCourseDetailLoaded) {
            return _CourseDetailContent(course: state.course);
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
              'Failed to load course',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => context
                  .read<VideoCourseBloc>()
                  .add(LoadVideoCourseDetail(courseId)),
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

// ─── Course Detail Content ─────────────────────────────────────────────────────

class _CourseDetailContent extends StatelessWidget {
  final VideoCourseEntity course;
  const _CourseDetailContent({required this.course});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Course Header with Thumbnail
          AspectRatio(
            aspectRatio: 16 / 9,
            child: course.thumbnail.isNotEmpty
                ? Image.network(
                    course.thumbnail,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _headerPlaceholder(),
                  )
                : _headerPlaceholder(),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  course.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                // Category & Stats
                Row(
                  children: [
                    _InfoChip(
                      icon: Icons.category_rounded,
                      label: course.category,
                    ),
                    const SizedBox(width: 12),
                    _InfoChip(
                      icon: Icons.play_lesson_rounded,
                      label: '${course.totalLessons} lessons',
                    ),
                    const SizedBox(width: 12),
                    _InfoChip(
                      icon: Icons.people_rounded,
                      label: '${course.enrolledCount} enrolled',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Description
                Text(
                  course.description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
                // Enrol Button
                if (!course.isEnrolled)
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () {
                        context
                            .read<VideoCourseBloc>()
                            .add(EnrolInVideoCourse(course.id));
                      },
                      icon: const Icon(Icons.school_rounded),
                      label: const Text('Enrol in Course'),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                if (course.isEnrolled) ...[
                  // Progress
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: course.progress,
                            backgroundColor:
                                AppColors.primary.withValues(alpha: 0.1),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.primary,
                            ),
                            minHeight: 8,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${(course.progress * 100).toInt()}%',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 24),
                // Lessons Section Header
                const Text(
                  'Lessons',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
          // Lesson List
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: course.lessons.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final lesson = course.lessons[index];
              return _LessonTile(
                lesson: lesson,
                courseId: course.id,
                isEnrolled: course.isEnrolled,
              );
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _headerPlaceholder() {
    return Container(
      color: AppColors.primary.withValues(alpha: 0.1),
      child: const Center(
        child: Icon(
          Icons.play_circle_outline_rounded,
          size: 64,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

// ─── Info Chip ─────────────────────────────────────────────────────────────────

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

// ─── Lesson Tile ───────────────────────────────────────────────────────────────

class _LessonTile extends StatelessWidget {
  final VideoLessonEntity lesson;
  final String courseId;
  final bool isEnrolled;
  const _LessonTile({
    required this.lesson,
    required this.courseId,
    required this.isEnrolled,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 0.5,
      child: ListTile(
        onTap: isEnrolled
            ? () {
                Navigator.pushNamed(
                  context,
                  '/video-lesson',
                  arguments: {'courseId': courseId, 'lessonId': lesson.id},
                );
              }
            : null,
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: lesson.isCompleted
                ? AppColors.primary.withValues(alpha: 0.1)
                : Colors.grey.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: lesson.isCompleted
                ? const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.primary,
                    size: 20,
                  )
                : Text(
                    '${lesson.orderIndex + 1}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
          ),
        ),
        title: Text(
          lesson.title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isEnrolled ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
        subtitle: Text(
          _formatDuration(lesson.duration),
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        trailing: isEnrolled
            ? const Icon(
                Icons.play_arrow_rounded,
                color: AppColors.primary,
              )
            : const Icon(
                Icons.lock_outline_rounded,
                color: AppColors.textSecondary,
                size: 18,
              ),
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
