import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:read_buddy_app/core/theme/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/services/location_service.dart';
import '../../../library/domain/entities/library_entity.dart';
import '../../../library/domain/usecases/library_usecases.dart';
import '../../../address/domain/entities/address_entity.dart';
import '../../../address/presentation/widgets/address_selector_widget.dart';
import '../../domain/entities/borrow_order_entity.dart';
import '../bloc/borrow_order_bloc.dart';
import '../widgets/order_book_card.dart';

class OrderCartPage extends StatelessWidget {
  const OrderCartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _OrderCartView();
  }
}

class _OrderCartView extends StatefulWidget {
  const _OrderCartView();

  @override
  State<_OrderCartView> createState() => _OrderCartViewState();
}

class _OrderCartViewState extends State<_OrderCartView> {
  FulfillmentMethod? _selectedMethod;
  AddressEntity? _selectedAddress;
  LibraryEntity? _selectedLibrary;
  Completer<void>? _refreshCompleter;

  void _completeRefresh() {
    if (_refreshCompleter != null && !_refreshCompleter!.isCompleted) {
      _refreshCompleter!.complete();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Borrow Cart'),
        centerTitle: true,
      ),
      body: BlocConsumer<BorrowOrderBloc, BorrowOrderState>(
        listener: (context, state) {
          if (state is OrderSubmitted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Order submitted successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context);
          }
          if (state is BorrowOrderError) {
            _completeRefresh();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
            // NOTE: Do NOT auto-reload here — a failing LoadDraftOrder would
            // re-emit BorrowOrderError and cause an infinite request loop.
          }
          if (state is DraftOrderLoaded) {
            _completeRefresh();
          }
        },
        builder: (context, state) {
          if (state is BorrowOrderLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          if (state is DraftOrderLoaded) {
            return _buildCartContent(context, state.order);
          }
          if (state is BorrowOrderError) {
            return _buildErrorState(context, state.message);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildCartContent(BuildContext context, BorrowOrderEntity order) {
    if (order.bookRequests.isEmpty) {
      return _buildEmptyCart(context);
    }

    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () {
              _refreshCompleter = Completer<void>();
              context.read<BorrowOrderBloc>().add(const LoadDraftOrder());
              return _refreshCompleter!.future;
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Budget bar
                _BudgetBar(
                  totalBookValue: order.totalBookValue,
                  budgetLimit: order.budgetLimit,
                ),
                const SizedBox(height: 16),

                // Book list
                ...order.bookRequests.map(
                  (book) => OrderBookCard(
                    book: book,
                    onRemove: () {
                      context
                          .read<BorrowOrderBloc>()
                          .add(RemoveBookFromCart(book.id));
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Fulfillment method selector
                _FulfillmentSelector(
                  selected: _selectedMethod,
                  onChanged: (method) {
                    setState(() {
                      _selectedMethod = method;
                      // Drop any stale pickup library when leaving PICKUP so a
                      // previously chosen id can't be submitted with DELIVERY.
                      if (method != FulfillmentMethod.PICKUP) {
                        _selectedLibrary = null;
                      }
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Address input for DELIVERY
                if (_selectedMethod == FulfillmentMethod.DELIVERY) ...[
                  _buildDeliverySection(),
                ],

                // Library selector for PICKUP
                if (_selectedMethod == FulfillmentMethod.PICKUP) ...[
                  _PickupLibrarySelector(
                    selectedLibrary: _selectedLibrary,
                    onSelected: (lib) => setState(() => _selectedLibrary = lib),
                  ),
                ],
              ],
            ),
          ),
        ),

        // Submit button
        _buildSubmitSection(context, order),
      ],
    );
  }

  Widget _buildDeliverySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.orange.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
          ),
          child: const Row(
            children: [
              Icon(Icons.info_outline, color: Colors.orange, size: 18),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  '₹25 delivery fee applies for home delivery',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.orange,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        AddressSelectorWidget(
          selectedAddress: _selectedAddress,
          onAddressSelected: (addr) {
            setState(() => _selectedAddress = addr);
          },
        ),
      ],
    );
  }

  Widget _buildSubmitSection(BuildContext context, BorrowOrderEntity order) {
    final canSubmit = _selectedMethod != null &&
        order.bookRequests.isNotEmpty &&
        order.totalBookValue <= order.budgetLimit &&
        (_selectedMethod == FulfillmentMethod.DELIVERY
            ? _selectedAddress != null
            : _selectedLibrary != null);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Book Value',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  '₹${order.totalBookValue.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            if (_selectedMethod == FulfillmentMethod.DELIVERY) ...[
              const SizedBox(height: 4),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Delivery Fee',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    '₹25',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: canSubmit
                    ? () {
                        context.read<BorrowOrderBloc>().add(
                              SubmitBorrowOrder(
                                fulfillmentMethod: _selectedMethod!,
                                address: _selectedMethod ==
                                        FulfillmentMethod.DELIVERY
                                    ? _selectedAddress?.fullAddress ?? ''
                                    : null,
                                libraryId:
                                    _selectedMethod == FulfillmentMethod.PICKUP
                                        ? _selectedLibrary?.id
                                        : null,
                              ),
                            );
                      }
                    : null,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade300,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Submit Order',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
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
                Icons.shopping_cart_outlined,
                size: 48,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Your cart is empty',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add books to your borrow cart\nand start reading!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.menu_book_rounded),
              label: const Text('Browse Books'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 56, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () =>
                  context.read<BorrowOrderBloc>().add(const LoadDraftOrder()),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Budget Bar ────────────────────────────────────────────────────────────────

class _BudgetBar extends StatelessWidget {
  final double totalBookValue;
  final double budgetLimit;

  const _BudgetBar({
    required this.totalBookValue,
    required this.budgetLimit,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (totalBookValue / budgetLimit).clamp(0.0, 1.0);
    final remaining = budgetLimit - totalBookValue;
    final isOverBudget = remaining <= 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isOverBudget
            ? AppColors.error.withValues(alpha: 0.05)
            : AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isOverBudget
              ? AppColors.error.withValues(alpha: 0.3)
              : AppColors.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Budget: ₹${totalBookValue.toStringAsFixed(0)} / ₹${budgetLimit.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isOverBudget ? AppColors.error : AppColors.textPrimary,
                ),
              ),
              Text(
                isOverBudget
                    ? 'Over budget!'
                    : '₹${remaining.toStringAsFixed(0)} remaining',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color:
                      isOverBudget ? AppColors.error : AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                isOverBudget ? AppColors.error : AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Fulfillment Method Selector ───────────────────────────────────────────────

class _FulfillmentSelector extends StatelessWidget {
  final FulfillmentMethod? selected;
  final ValueChanged<FulfillmentMethod> onChanged;

  const _FulfillmentSelector({
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Fulfillment Method',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _MethodCard(
                icon: Icons.local_shipping_outlined,
                label: 'Delivery',
                subtitle: '₹25 fee',
                isSelected: selected == FulfillmentMethod.DELIVERY,
                onTap: () => onChanged(FulfillmentMethod.DELIVERY),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MethodCard(
                icon: Icons.store_outlined,
                label: 'Pickup',
                subtitle: 'Free',
                isSelected: selected == FulfillmentMethod.PICKUP,
                onTap: () => onChanged(FulfillmentMethod.PICKUP),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MethodCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _MethodCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.08)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 28,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Pickup Library Selector ────────────────────────────────────────────────

/// Fetches libraries and shows only those within 15 km of the user's current
/// location, nearest first, and auto-selects the nearest one. Degrades
/// gracefully when the location is unavailable (shows the list unsorted with a
/// hint) and shows a clear empty message when none are within 15 km.
class _PickupLibrarySelector extends StatefulWidget {
  final LibraryEntity? selectedLibrary;
  final ValueChanged<LibraryEntity?> onSelected;

  const _PickupLibrarySelector({
    required this.selectedLibrary,
    required this.onSelected,
  });

  @override
  State<_PickupLibrarySelector> createState() => _PickupLibrarySelectorState();
}

class _PickupLibrarySelectorState extends State<_PickupLibrarySelector> {
  static const double _radiusKm = 15.0;

  bool _loading = true;
  String? _error;
  bool _locationUnavailable = false;
  bool _hadLibraries = false;
  List<_LibraryWithDistance> _libraries = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  // Reconciles the parent's selection against the current in-range list:
  // keep the current selection only if still in range, otherwise select the
  // nearest available, else clear it (so the parent drops any stale id).
  void _reconcileSelection(List<_LibraryWithDistance> within) {
    final currentId = widget.selectedLibrary?.id;
    final stillValid =
        currentId != null && within.any((l) => l.library.id == currentId);
    if (stillValid) return;
    if (within.isNotEmpty) {
      widget.onSelected(within.first.library);
    } else {
      widget.onSelected(null);
    }
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
      _locationUnavailable = false;
    });
    try {
      final all = await getIt<GetLibraryDetails>()();
      if (!mounted) return;
      final position = await LocationService.instance.getCurrentLocation();
      if (!mounted) return;

      if (position == null) {
        // Graceful degradation: no location -> show all (no distance), let the
        // user pick manually. Do NOT auto-select.
        final listed = all
            .map((l) => _LibraryWithDistance(library: l, distanceKm: null))
            .toList();
        _reconcileSelection(listed);
        setState(() {
          _locationUnavailable = true;
          _hadLibraries = all.isNotEmpty;
          _libraries = listed;
          _loading = false;
        });
        return;
      }

      final within = <_LibraryWithDistance>[];
      for (final lib in all) {
        if (lib.address.latitude == 0 && lib.address.longitude == 0) continue;
        final km = LocationService.instance.calculateDistanceKm(
          position.latitude,
          position.longitude,
          lib.address.latitude,
          lib.address.longitude,
        );
        if (km <= _radiusKm) {
          within.add(_LibraryWithDistance(library: lib, distanceKm: km));
        }
      }
      within.sort((a, b) => a.distanceKm!.compareTo(b.distanceKm!));

      _reconcileSelection(within);

      setState(() {
        _hadLibraries = all.isNotEmpty;
        _libraries = within;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      widget.onSelected(null);
      setState(() {
        _error = 'Could not load libraries. Please try again.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (_error != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_error!, style: const TextStyle(color: AppColors.error)),
          const SizedBox(height: 8),
          TextButton(onPressed: _load, child: const Text('Retry')),
        ],
      );
    }

    if (_libraries.isEmpty) {
      // Distinguish the three empty cases so the message is accurate.
      final String message;
      if (_locationUnavailable) {
        message = 'Location unavailable — enable location to find nearby '
            'libraries, or try Delivery instead.';
      } else if (_hadLibraries) {
        message = 'No libraries within 15 km of your location. '
            'Try Delivery instead.';
      } else {
        message = 'No libraries are available right now. '
            'Try Delivery instead.';
      }
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.orange.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.location_off, color: Colors.orange, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Pickup Library',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        if (_locationUnavailable) ...[
          const SizedBox(height: 6),
          const Text(
            'Location unavailable — showing all libraries. '
            'Enable location to see the nearest ones.',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ],
        const SizedBox(height: 10),
        ..._libraries.map((item) {
          final isSelected = widget.selectedLibrary?.id == item.library.id;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: GestureDetector(
              onTap: () => widget.onSelected(item.library),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color:
                        isSelected ? AppColors.primary : Colors.grey.shade300,
                    width: isSelected ? 2 : 1,
                  ),
                  color: isSelected
                      ? AppColors.primary.withValues(alpha: 0.05)
                      : Colors.white,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: item.library.isSuperLibrary
                            ? Colors.amber.withValues(alpha: 0.15)
                            : AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        item.library.isSuperLibrary
                            ? Icons.star
                            : Icons.local_library,
                        size: 20,
                        color: item.library.isSuperLibrary
                            ? Colors.amber
                            : AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.library.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.library.address.fullAddress,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    if (item.distanceKm != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          LocationService.instance
                              .formatDistance(item.distanceKm!),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    if (isSelected) ...[
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.check_circle,
                        color: AppColors.primary,
                        size: 22,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _LibraryWithDistance {
  final LibraryEntity library;
  final double? distanceKm;

  const _LibraryWithDistance({required this.library, this.distanceKm});
}
