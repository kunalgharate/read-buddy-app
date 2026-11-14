import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:read_buddy_app/core/di/injection.dart';
import 'package:read_buddy_app/core/theme/app_colors.dart';

import '../bloc/borrow_order_bloc.dart';
import '../cart_badge_notifier.dart';

/// Shortcut to the borrow cart with a live item-count badge.
///
/// The cart used to be reachable only from the book detail page straight after
/// a book was added, so closing it left no way back. Mounting this on the book
/// browsing surfaces keeps the cart one tap away.
class CartEntryButton extends StatelessWidget {
  /// Optional bloc for tests or hosts that already own one. When omitted the
  /// button creates (and disposes) its own and loads the draft cart.
  final BorrowOrderBloc? bloc;

  /// Renders inside the 52x52 rounded card used by the Books header when true,
  /// or as a plain [IconButton] for app bars when false.
  final bool boxed;

  const CartEntryButton({super.key, this.bloc, this.boxed = false});

  @override
  Widget build(BuildContext context) {
    final external = bloc;
    if (external != null) {
      return BlocProvider<BorrowOrderBloc>.value(
        value: external,
        child: _CartEntryView(boxed: boxed),
      );
    }
    return BlocProvider<BorrowOrderBloc>(
      create: (_) => getIt<BorrowOrderBloc>()..add(const LoadDraftOrder()),
      child: _CartEntryView(boxed: boxed),
    );
  }
}

class _CartEntryView extends StatefulWidget {
  final bool boxed;

  const _CartEntryView({required this.boxed});

  @override
  State<_CartEntryView> createState() => _CartEntryViewState();
}

class _CartEntryViewState extends State<_CartEntryView> {
  /// Count carried over while the draft reloads, so the badge does not blink.
  int _itemCount = 0;

  @override
  void initState() {
    super.initState();
    cartRevision.addListener(_reloadDraft);
  }

  @override
  void dispose() {
    cartRevision.removeListener(_reloadDraft);
    super.dispose();
  }

  void _reloadDraft() {
    if (!mounted) return;
    context.read<BorrowOrderBloc>().add(const LoadDraftOrder());
  }

  Future<void> _openCart() async {
    await Navigator.of(context).pushNamed('/order-cart');
    if (!mounted) return;
    // The cart screen owns a separate bloc instance, so refresh this badge.
    context.read<BorrowOrderBloc>().add(const LoadDraftOrder());
  }

  int _countFor(BorrowOrderState state) => switch (state) {
        DraftOrderLoaded(:final order) => order.bookRequests.length,
        OrderSubmitted(:final order) => order.bookRequests.length,
        OrderCancelled(:final order) => order.bookRequests.length,
        _ => _itemCount,
      };

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BorrowOrderBloc, BorrowOrderState>(
      listenWhen: (previous, current) =>
          current is DraftOrderLoaded ||
          current is OrderSubmitted ||
          current is OrderCancelled,
      listener: (context, state) {
        final count = _countFor(state);
        if (count != _itemCount) {
          setState(() => _itemCount = count);
        }
      },
      buildWhen: (previous, current) =>
          current is DraftOrderLoaded ||
          current is OrderSubmitted ||
          current is OrderCancelled,
      builder: (context, state) {
        final count = _countFor(state);
        final button = IconButton(
          tooltip: count > 0 ? 'Borrow cart, $count items' : 'Borrow cart',
          onPressed: _openCart,
          icon: Badge.count(
            count: count,
            isLabelVisible: count > 0,
            backgroundColor: AppColors.primary,
            child: Icon(
              Icons.shopping_cart_outlined,
              color: widget.boxed
                  ? Theme.of(context).colorScheme.onSurface
                  : null,
            ),
          ),
        );

        if (!widget.boxed) return button;

        return Container(
          height: 52,
          width: 52,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: button,
        );
      },
    );
  }
}
