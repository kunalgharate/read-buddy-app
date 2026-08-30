import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:read_buddy_app/core/theme/app_colors.dart';
import '../../domain/entities/video_course_entity.dart';
import '../bloc/video_course_bloc.dart';

class VideoCourseListPage extends StatelessWidget {
  const VideoCourseListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _VideoCourseListView();
  }
}

class _VideoCourseListView extends StatefulWidget {
  const _VideoCourseListView();

  @override
  State<_VideoCourseListView> createState() => _VideoCourseListViewState();
}

class _VideoCourseListViewState extends State<_VideoCourseListView> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Courses'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search courses...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear_rounded),
                  onPressed: () {
                    _searchController.clear();
                    context
                        .read<VideoCourseBloc>()
                        .add(const LoadVideoCourses());
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppColors.primary.withValues(alpha: 0.05),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onSubmitted: (query) {
                final trimmed = query.trim();
                if (trimmed.isNotEmpty) {
                  context
                      .read<VideoCourseBloc>()
                      .add(SearchVideoCourses(trimmed));
                } else {
                  // Empty query — reload all courses
                  context.read<VideoCourseBloc>().add(const LoadVideoCourses());
                }
              },
            ),
          ),
          // Course Grid
          Expanded(
            child: BlocConsumer<VideoCourseBloc, VideoCourseState>(
              listener: (context, state) {
                if (state is VideoCourseError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message)),
                  );
                }
              },
              builder: (context, state) {
                if (state is VideoCourseLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
                  );
                }
                if (state is VideoCoursesLoaded) {
                  if (state.courses.isEmpty) {
                    return RefreshIndicator(
                      color: AppColors.primary,
                      onRefresh: () async {
                        context
                            .read<VideoCourseBloc>()
                            .add(const LoadVideoCourses());
                      },
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: const [
                          SizedBox(height: 120),
                          _EmptyCourses(),
                        ],
                      ),
                    );
                  }
                  return RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: () async {
                      context
                          .read<VideoCourseBloc>()
                          .add(const LoadVideoCourses());
                    },
                    child: GridView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.72,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: state.courses.length,
                      itemBuilder: (context, index) => _CourseCard(
                        course: state.courses[index],
                      ),
                    ),
                  );
                }
                if (state is VideoCourseError) {
                  return _buildError(context);
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
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
              'Failed to load courses',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () =>
                  context.read<VideoCourseBloc>().add(const LoadVideoCourses()),
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

// ─── Empty State ───────────────────────────────────────────────────────────────

class _EmptyCourses extends StatelessWidget {
  const _EmptyCourses();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.play_circle_outline_rounded,
                size: 48,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No courses found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Try adjusting your search or\ncheck back later for new courses.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Course Card ───────────────────────────────────────────────────────────────

class _CourseCard extends StatelessWidget {
  final VideoCourseEntity course;
  const _CourseCard({required this.course});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/video-course-detail',
          arguments: course.id,
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            AspectRatio(
              aspectRatio: 16 / 9,
              child: course.thumbnail.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: course.thumbnail,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => _thumbnailPlaceholder(),
                      errorWidget: (_, __, ___) => _thumbnailPlaceholder(),
                    )
                  : _thumbnailPlaceholder(),
            ),
            // Course Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.title,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${course.totalLessons} lessons',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const Spacer(),
                    if (course.isEnrolled) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: course.progress,
                          backgroundColor:
                              AppColors.primary.withValues(alpha: 0.1),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.primary,
                          ),
                          minHeight: 4,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${(course.progress * 100).toInt()}% complete',
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _thumbnailPlaceholder() {
    return Container(
      color: AppColors.primary.withValues(alpha: 0.1),
      child: const Center(
        child: Icon(
          Icons.play_circle_outline_rounded,
          size: 32,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
