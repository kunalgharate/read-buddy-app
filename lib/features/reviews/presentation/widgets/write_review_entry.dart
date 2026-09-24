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
      key: ValueKey(bookId),
      create: (_) =>
          GetIt.instance<ReviewBloc>()..add(LoadReviewEligibility(bookId)),
      child: _WriteReviewEntryContent(bookId: bookId),
    );
  }
}

class _WriteReviewEntryContent extends StatefulWidget {
  final String bookId;

  const _WriteReviewEntryContent({required this.bookId});

  @override
  State<_WriteReviewEntryContent> createState() =>
      _WriteReviewEntryContentState();
}

class _WriteReviewEntryContentState extends State<_WriteReviewEntryContent> {
  /// Last known eligibility so we can keep showing the Write/Edit button while
  /// a subsequent operation (create/update reload) is loading or fails.
  ReviewEligibilityEntity? _lastEligibility;

  /// Whether the in-flight operation was started by the user (create/update).
  /// Only such failures should surface an error SnackBar — the best-effort
  /// eligibility load must stay silent.
  bool _userInitiatedInFlight = false;

  String get bookId => widget.bookId;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ReviewBloc, ReviewState>(
      listener: (context, state) {
        if (state is ReviewActionSuccess) {
          _userInitiatedInFlight = false;
          // Optimistically flip local eligibility so the stale 'Write' button
          // clears immediately (they just submitted) instead of lingering until
          // the reviews+eligibility reload completes. The subsequent
          // LoadReviewEligibility will replace this with the authoritative value.
          if (_lastEligibility != null) {
            setState(() {
              _lastEligibility = _lastEligibility!.copyWith(canReview: false);
            });
          }
          // Refresh eligibility so Edit/Delete reflect the new review promptly.
          context.read<ReviewBloc>().add(LoadReviewEligibility(bookId));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.success,
            ),
          );
        } else if (state is ReviewError) {
          // Only report failures for actual user-initiated create/update
          // actions — never for the best-effort eligibility load/reload.
          if (_userInitiatedInFlight) {
            _userInitiatedInFlight = false;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        }
      },
      builder: (context, state) {
        // Track the freshest eligibility we have seen so it survives later
        // loading/error states.
        if (state is ReviewEligibilityLoaded) {
          _lastEligibility = state.eligibility;
        } else if (state is ReviewsLoaded && state.eligibility != null) {
          _lastEligibility = state.eligibility;
        }

        final eligibility = _lastEligibility;

        // Eligibility never resolved yet: offer a silent retry on error so the
        // entry does not stay absent for the page lifetime.
        if (eligibility == null) {
          if (state is ReviewError) {
            return Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () => context
                    .read<ReviewBloc>()
                    .add(LoadReviewEligibility(bookId)),
                child: const Text('Retry'),
              ),
            );
          }
          return const SizedBox.shrink();
        }

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
                onPressed: () => _showReviewForm(context, eligibility),
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
        // Mark the operation as user-initiated so an error surfaces a SnackBar.
        _userInitiatedInFlight = true;
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
