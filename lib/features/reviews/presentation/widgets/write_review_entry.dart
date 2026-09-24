import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:read_buddy_app/core/theme/app_colors.dart';
import 'package:read_buddy_app/features/reviews/domain/entities/review_eligibility_entity.dart';
import 'package:read_buddy_app/features/reviews/presentation/bloc/review_bloc.dart';
import 'package:read_buddy_app/features/reviews/presentation/widgets/review_form_widget.dart';

/// A compact, self-contained entry point that lets a user write (or edit) a
/// review for [bookId]. It queries the eligibility endpoint and only renders a
/// button when the user is eligible (borrowed + completed and not yet
/// reviewed) or already has a review to edit. When not eligible it renders
/// nothing, so it is safe to embed unconditionally.
///
/// Intended for the borrow flow (e.g. the delivered/returned request detail
/// page) where the reviews list is not shown.
class WriteReviewEntry extends StatelessWidget {
  final String bookId;

  const WriteReviewEntry({super.key, required this.bookId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          GetIt.instance<ReviewBloc>()..add(LoadReviewEligibility(bookId)),
      child: _WriteReviewEntryContent(bookId: bookId),
    );
  }
}

class _WriteReviewEntryContent extends StatelessWidget {
  final String bookId;

  const _WriteReviewEntryContent({required this.bookId});

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
          // Refresh eligibility so the button reflects the new review state.
          context.read<ReviewBloc>().add(LoadReviewEligibility(bookId));
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
        ReviewEligibilityEntity? eligibility;
        if (state is ReviewEligibilityLoaded) {
          eligibility = state.eligibility;
        } else if (state is ReviewsLoaded) {
          eligibility = state.eligibility;
        }

        if (eligibility == null) return const SizedBox.shrink();

        final existing = eligibility.existingReview;
        final canWrite = eligibility.canReview || existing != null;
        if (!canWrite) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const _SectionTitle('Your Review'),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () => _showReviewForm(context, eligibility!),
                icon: Icon(
                  existing != null ? Icons.edit : Icons.rate_review,
                  size: 18,
                ),
                label: Text(
                  existing != null ? 'Edit your review' : 'Write a review',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showReviewForm(
    BuildContext context,
    ReviewEligibilityEntity eligibility,
  ) {
    final bloc = context.read<ReviewBloc>();
    final existing = eligibility.existingReview;

    ReviewFormWidget.show(
      context: context,
      bookId: bookId,
      reviewId: existing?.id,
      initialRating: existing?.rating,
      initialTitle: existing?.title,
      initialComment: existing?.comment,
      onSubmit: ({
        required int rating,
        required String title,
        required String comment,
      }) {
        if (existing?.id != null) {
          bloc.add(
            UpdateReviewEvent(
              id: existing!.id!,
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
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Color(0xFF052E44),
      ),
    );
  }
}
