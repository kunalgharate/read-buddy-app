import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:read_buddy_app/core/theme/app_colors.dart';
import 'package:read_buddy_app/features/reviews/domain/entities/review_eligibility_entity.dart';
import 'package:read_buddy_app/features/reviews/presentation/bloc/review_bloc.dart';
import 'package:read_buddy_app/features/reviews/presentation/widgets/review_card.dart';
import 'package:read_buddy_app/features/reviews/presentation/widgets/review_form_widget.dart';

/// A self-contained widget that shows book reviews with average rating.
/// Embed in any book detail page with: `BookReviewsSection(bookId: bookId)`
///
/// By default this creates and owns its own [ReviewBloc]. When embedded in a
/// page that already provides a shared [ReviewBloc] above it (so the title
/// rating summary and this section stay in sync), pass
/// `useAncestorBloc: true` to consume that ancestor bloc instead of creating
/// a second independent instance. The ancestor is responsible for the initial
/// `LoadBookReviews` dispatch, so this widget does not re-add it.
class BookReviewsSection extends StatelessWidget {
  final String bookId;
  final bool useAncestorBloc;

  const BookReviewsSection({
    super.key,
    required this.bookId,
    this.useAncestorBloc = false,
  });

  @override
  Widget build(BuildContext context) {
    if (useAncestorBloc) {
      // Reuse the ReviewBloc already provided by an ancestor. The initial
      // LoadBookReviews was dispatched by that ancestor, so we must NOT add it
      // again here to avoid a duplicate load.
      return _BookReviewsSectionContent(bookId: bookId);
    }
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
        // Hide the whole section when there are no reviews AND the user
        // cannot write one (matches the web behavior).
        if (state is ReviewsLoaded) {
          final canReview = state.eligibility?.canReview ?? false;
          final hasExisting = state.eligibility?.existingReview != null;
          if (state.reviews.isEmpty && !canReview && !hasExisting) {
            return const SizedBox.shrink();
          }
        }

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
    final eligibility = state is ReviewsLoaded ? state.eligibility : null;
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
        _buildWriteReviewAction(context, eligibility),
      ],
    );
  }

  /// Show the 'Write Review' entry ONLY when the user is eligible and has not
  /// yet reviewed. When the user already has a review, show Edit + Delete for
  /// it instead. Otherwise render nothing.
  Widget _buildWriteReviewAction(
    BuildContext context,
    ReviewEligibilityEntity? eligibility,
  ) {
    final existing = eligibility?.existingReview;
    if (existing != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton.icon(
            onPressed: () => _showReviewForm(
              context,
              reviewId: existing.id,
              initialRating: existing.rating,
              initialTitle: existing.title,
              initialComment: existing.comment,
            ),
            icon: const Icon(Icons.edit, size: 18),
            label: const Text('Edit'),
            style: TextButton.styleFrom(foregroundColor: AppColors.primary),
          ),
          if (existing.id != null)
            TextButton.icon(
              onPressed: () => _confirmDelete(context, existing.id!),
              icon: const Icon(Icons.delete, size: 18),
              label: const Text('Delete'),
              style: TextButton.styleFrom(foregroundColor: AppColors.error),
            ),
        ],
      );
    }

    if (eligibility?.canReview == true) {
      return TextButton.icon(
        onPressed: () => _showReviewForm(context),
        icon: const Icon(Icons.rate_review, size: 18),
        label: const Text('Write Review'),
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
        ),
      );
    }

    return const SizedBox.shrink();
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
      return _buildReviewList(context, state);
    }

    if (state is ReviewError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: AppColors.textMutedColor(context),
              ),
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
    ReviewsLoaded state,
  ) {
    final reviews = state.reviews;
    final ownReviewId = state.eligibility?.existingReview?.id;
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: reviews.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final review = reviews[index];
        final isOwner = ownReviewId != null && review.id == ownReviewId;
        return ReviewCard(
          review: review,
          isOwner: isOwner,
          onEdit: isOwner
              ? () => _showReviewForm(
                    context,
                    reviewId: review.id,
                    initialRating: review.rating,
                    initialTitle: review.title,
                    initialComment: review.comment,
                  )
              : null,
          onDelete: isOwner ? () => _confirmDelete(context, review.id!) : null,
        );
      },
    );
  }

  void _showReviewForm(
    BuildContext context, {
    String? reviewId,
    int? initialRating,
    String? initialTitle,
    String? initialComment,
  }) {
    final bloc = context.read<ReviewBloc>();

    ReviewFormWidget.show(
      context: context,
      bookId: bookId,
      reviewId: reviewId,
      initialRating: initialRating,
      initialTitle: initialTitle,
      initialComment: initialComment,
      onSubmit: ({
        required int rating,
        required String title,
        required String comment,
      }) {
        if (reviewId != null) {
          bloc.add(
            UpdateReviewEvent(
              id: reviewId,
              bookId: bookId,
              rating: rating,
              title: title,
              comment: comment,
            ),
          );
        } else {
          bloc.add(
            CreateReviewEvent(
              bookId: bookId,
              rating: rating,
              title: title,
              comment: comment,
            ),
          );
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
