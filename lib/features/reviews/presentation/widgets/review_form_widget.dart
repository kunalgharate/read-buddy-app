import 'package:flutter/material.dart';
import 'package:read_buddy_app/core/theme/app_colors.dart';

class ReviewFormWidget extends StatefulWidget {
  final String bookId;
  final int? initialRating;
  final String? initialComment;
  final String? reviewId;
  final void Function({
    required int rating,
    required String comment,
  }) onSubmit;

  const ReviewFormWidget({
    super.key,
    required this.bookId,
    this.initialRating,
    this.initialComment,
    this.reviewId,
    required this.onSubmit,
  });

  /// Show the review form as a bottom sheet
  static Future<void> show({
    required BuildContext context,
    required String bookId,
    int? initialRating,
    String? initialComment,
    String? reviewId,
    required void Function({required int rating, required String comment})
        onSubmit,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: ReviewFormWidget(
          bookId: bookId,
          initialRating: initialRating,
          initialComment: initialComment,
          reviewId: reviewId,
          onSubmit: onSubmit,
        ),
      ),
    );
  }

  @override
  State<ReviewFormWidget> createState() => _ReviewFormWidgetState();
}

class _ReviewFormWidgetState extends State<ReviewFormWidget> {
  late int _rating;
  late TextEditingController _commentController;
  final _formKey = GlobalKey<FormState>();

  bool get isEditing => widget.reviewId != null;

  @override
  void initState() {
    super.initState();
    _rating = widget.initialRating ?? 0;
    _commentController =
        TextEditingController(text: widget.initialComment ?? '');
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceColor(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderColor(context),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              isEditing ? 'Edit Review' : 'Write a Review',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimaryColor(context),
              ),
            ),
            const SizedBox(height: 20),

            // Star rating
            Text(
              'Your Rating',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondaryColor(context),
              ),
            ),
            const SizedBox(height: 8),
            _buildStarSelector(),
            const SizedBox(height: 20),

            // Comment field
            Text(
              'Your Review',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondaryColor(context),
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _commentController,
              maxLines: 4,
              maxLength: 500,
              decoration: InputDecoration(
                hintText: 'Share your thoughts about this book...',
                hintStyle: TextStyle(
                  color: AppColors.textMutedColor(context),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.borderColor(context)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.borderColor(context)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
                contentPadding: const EdgeInsets.all(14),
              ),
              validator: (value) {
                if ((value == null || value.trim().isEmpty) && _rating == 0) {
                  return 'Please provide a rating or comment';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Submit button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _onSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  isEditing ? 'Update Review' : 'Submit Review',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStarSelector() {
    return Row(
      children: List.generate(5, (index) {
        final starIndex = index + 1;
        return GestureDetector(
          onTap: () => setState(() => _rating = starIndex),
          child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Icon(
              starIndex <= _rating ? Icons.star : Icons.star_border,
              size: 36,
              color: starIndex <= _rating
                  ? Colors.amber
                  : AppColors.textMutedColor(context),
            ),
          ),
        );
      }),
    );
  }

  void _onSubmit() {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a rating')),
      );
      return;
    }

    if (_formKey.currentState?.validate() ?? false) {
      widget.onSubmit(
        rating: _rating,
        comment: _commentController.text.trim(),
      );
      Navigator.of(context).pop();
    }
  }
}
