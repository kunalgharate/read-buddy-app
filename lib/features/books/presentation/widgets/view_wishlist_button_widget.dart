import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/wishlist_bloc.dart';
import 'bottom_sheet_cart.dart';

class ViewWishlistButtonWidget extends StatelessWidget {
  final VoidCallback? onTap;

  const ViewWishlistButtonWidget({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    // Watch the WishlistCubit to get the number of books and rebuild when it changes.
    final bookCount = context.watch<WishlistCubit>().state.books.length;

    return GestureDetector(
      onTap: onTap ??
          () {
            // Re-use the same logic as the floating cart icon to show the bottom sheet.
            context.read<WishlistCubit>().showMenuPermanently();
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              builder: (_) => const BottomSheetCart(),
            );
          },
      child: Container(
        height: 54,
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF2CE07F),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Badge(
              label: Text(bookCount.toString()),
              child: const Icon(
                Icons.shopping_cart_checkout,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'View Wishlist',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color.fromRGBO(5, 46, 68, 1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
