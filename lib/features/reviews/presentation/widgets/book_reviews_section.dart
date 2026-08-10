import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:read_buddy_app/core/theme/app_colors.dart';
import 'package:read_buddy_app/core/utils/secure_storage_utils.dart';
import 'package:read_buddy_app/features/reviews/domain/entities/review_entity.dart';
import 'package:read_buddy_app/features/reviews/presentation/bloc/review_bloc.dart';
import 'package:read_buddy_app/features/reviews/presentation/widgets/review_card.dart';
import 'package:read_buddy_app/features/reviews/presentation/widgets/review_form_widget.dart';

/// A self-contained widget that shows book reviews with average rating.
/// Embed in any book detail page with: `BookReviewsSection(bookId: bookId)`
class BookReviewsSection extends StatelessWidget {
  final String bookId;

  const BookReviewsSection({super.key, required this.bookId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.instance<ReviewBloc>()..add(LoadBookReviews(bookId)),
      child: _BookReviewsSectionContent(bookId: bookId),
    );
  }
}

class _BookReviewsSectionContent extends StatelessWidget {
  final String bookId;

  const _BookReviewsSectionContent({required this.bookId});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ReviewBloc, ReviewState>(
      listener: (context, state) {
        if (state is ReviewActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.success,
            ),
          );
        } else if (state is ReviewError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, state),
            const SizedBox(height: 12),
            _buildContent(context, state),
          ],
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, ReviewState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              'Reviews',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimaryColor(context),
              ),
            ),
            if (state is ReviewsLoaded) ...[
              const SizedBox(width: 8),
              _buildAverageRatingBadge(context, state),
            ],
          ],
        ),
        TextButton.icon(
          onPressed: () => _showReviewForm(context),
          icon: const Icon(Icons.rate_review, size: 18),
          label: const Text('Write Review'),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildAverageRatingBadge(
    BuildContext context,
    ReviewsLoaded state,
  ) {
    if (state.totalReviews == 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, size: 14, color: Colors.amber),
          const SizedBox(width: 4),
          Text(
            state.averageRating.toStringAsFixed(1),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.amber,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '(${state.totalReviews})',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textMutedColor(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, ReviewState state) {
    if (state is ReviewLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (state is ReviewsLoaded) {
      if (state.reviews.isEmpty) {
        return _buildEmptyState(context);
      }
      return _buildReviewList(context, state.reviews);
    }

    if (state is ReviewError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Icon(Icons.error_outline,
                  size: 48, color: AppColors.textMutedColor(context)),
              const SizedBox(height: 8),
              Text(
                'Could not load reviews',
                style: TextStyle(color: AppColors.textMutedColor(context)),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () =>
                    context.read<ReviewBloc>().add(LoadBookReviews(bookId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.rate_review_outlined,
              size: 48,
              color: AppColors.textMutedColor(context),
            ),
            const SizedBox(height: 8),
            Text(
              'No reviews yet',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textMutedColor(context),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Be the first to share your thoughts!',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textMutedColor(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewList(
    BuildContext context,
    List<ReviewEntity> reviews,
  ) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: reviews.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final review = reviews[index];
        return FutureBuilder<bool>(
          future: _isReviewOwner(review.userId),
          builder: (context, snapshot) {
            final isOwner = snapshot.data ?? false;
            return ReviewCard(
              review: review,
              isOwner: isOwner,
              onEdit: isOwner
                  ? () => _showReviewForm(
                        context,
                        reviewId: review.id,
                        initialRating: review.rating,
                        initialComment: review.comment,
                      )
                  : null,
              onDelete:
                  isOwner ? () => _confirmDelete(context, review.id!) : null,
            );
          },
        );
      },
    );
  }

  Future<bool> _isReviewOwner(String reviewUserId) async {
    try {
      final storage = GetIt.instance<SecureStorageUtil>();
      final user = await storage.getUser();
      return user?.id == reviewUserId;
    } catch (_) {
      return false;
    }
  }

  void _showReviewForm(
    BuildContext context, {
    String? reviewId,
    int? initialRating,
    String? initialComment,
  }) {
    final bloc = context.read<ReviewBloc>();

    ReviewFormWidget.show(
      context: context,
      bookId: bookId,
      reviewId: reviewId,
      initialRating: initialRating,
      initialComment: initialComment,
      onSubmit: ({required int rating, required String comment}) {
        if (reviewId != null) {
          bloc.add(UpdateReviewEvent(
            id: reviewId,
            bookId: bookId,
            rating: rating,
            comment: comment,
          ));
        } else {
          bloc.add(CreateReviewEvent(
            bookId: bookId,
            rating: rating,
            comment: comment,
          ));
        }
      },
    );
  }

  void _confirmDelete(BuildContext context, String reviewId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Review'),
        content: const Text(
          'Are you sure you want to delete this review? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<ReviewBloc>().add(
                    DeleteReviewEvent(id: reviewId, bookId: bookId),
                  );
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
