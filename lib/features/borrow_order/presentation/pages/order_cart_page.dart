import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:read_buddy_app/core/di/injection.dart';
import 'package:read_buddy_app/core/services/city_notifier.dart';
import 'package:read_buddy_app/core/theme/app_colors.dart';
import 'package:read_buddy_app/core/utils/error_handler.dart';
import 'package:read_buddy_app/features/library/domain/entities/library_entity.dart';
import 'package:read_buddy_app/features/library/domain/usecases/library_usecases.dart';
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
  final _addressController = TextEditingController();
  String? _libraryId;
  String? _libraryName;
  bool _pickingLibrary = false;
  Completer<void>? _refreshCompleter;

  void _completeRefresh() {
    if (_refreshCompleter != null && !_refreshCompleter!.isCompleted) {
      _refreshCompleter!.complete();
    }
  }

  @override
  void initState() {
    super.initState();
    // canSubmit reads controller text during build, so the Submit button has
    // to be re-evaluated as the user types — otherwise it never enables.
    _addressController.addListener(_onFormChanged);
  }

  void _onFormChanged() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  void dispose() {
    _addressController.removeListener(_onFormChanged);
    _addressController.dispose();
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
                    setState(() => _selectedMethod = method);
                  },
                ),
                const SizedBox(height: 16),

                // Address input for DELIVERY
                if (_selectedMethod == FulfillmentMethod.DELIVERY) ...[
                  _buildDeliverySection(),
                ],

                // Library input for PICKUP
                if (_selectedMethod == FulfillmentMethod.PICKUP) ...[
                  _buildPickupSection(),
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
        TextField(
          controller: _addressController,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: 'Delivery Address',
            hintText: 'Enter your full delivery address',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPickupSection() {
    final selectedName = _libraryName;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pickup Library',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        InkWell(
          onTap: _pickingLibrary ? null : _pickLibrary,
          borderRadius: BorderRadius.circular(12),
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: selectedName == null ? 'Select a library' : null,
              hintText: selectedName == null ? 'Choose where to pick up' : null,
              prefixIcon: const Icon(Icons.local_library_outlined),
              suffixIcon: _pickingLibrary
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : const Icon(Icons.arrow_drop_down),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
            ),
            child: selectedName == null
                ? const SizedBox.shrink()
                : Text(
                    selectedName,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Books can only be collected from a library in your city.',
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  /// Loads the libraries the user can collect from (preferring their
  /// selected city) and lets them pick one.
  Future<void> _pickLibrary() async {
    setState(() => _pickingLibrary = true);
    try {
      final city = CityNotifier.instance.value;
      var libraries = await getIt<GetLibraries>()(city: city);
      if (city != null && libraries.isEmpty) {
        // City filter can be stricter than the backend data — fall back to
        // every library rather than dead-ending the pickup flow.
        libraries = await getIt<GetLibraries>()();
      }
      if (!mounted) return;
      if (libraries.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No libraries are available yet')),
        );
        return;
      }

      final selected = await showModalBottomSheet<LibraryEntity>(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (ctx) => _LibraryPickerSheet(libraries: libraries),
      );
      if (selected == null || !mounted) return;
      setState(() {
        _libraryId = selected.id;
        _libraryName = selected.name;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ErrorHandler.getErrorMessage(e))),
      );
    } finally {
      if (mounted) setState(() => _pickingLibrary = false);
    }
  }

  Widget _buildSubmitSection(BuildContext context, BorrowOrderEntity order) {
    final canSubmit = _selectedMethod != null &&
        order.bookRequests.isNotEmpty &&
        order.totalBookValue <= order.budgetLimit &&
        (_selectedMethod == FulfillmentMethod.DELIVERY
            ? _addressController.text.trim().isNotEmpty
            : _libraryId != null);

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
                                    ? _addressController.text.trim()
                                    : null,
                                libraryId: _selectedMethod ==
                                        FulfillmentMethod.PICKUP
                                    ? _libraryId
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

/// Lets the user choose which library to collect their borrow order from,
/// instead of hand-typing an opaque library id.
class _LibraryPickerSheet extends StatelessWidget {
  final List<LibraryEntity> libraries;

  const _LibraryPickerSheet({required this.libraries});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 20, 16, 8),
              child: Text(
                'Choose a pickup library',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
                itemCount: libraries.length,
                separatorBuilder: (_, __) =>
                    const Divider(height: 1, color: Color(0xFFEEEEEE)),
                itemBuilder: (context, index) {
                  final library = libraries[index];
                  return ListTile(
                    leading: const Icon(
                      Icons.local_library_outlined,
                      color: AppColors.primary,
                    ),
                    title: Text(
                      library.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    subtitle: Text(
                      library.address.fullAddress,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    onTap: () => Navigator.pop(context, library),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
