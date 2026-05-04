import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../domain/entities/book_request_entity.dart';
import '../../domain/entities/library_entity.dart';
import '../bloc/book_request_bloc.dart';
import '../bloc/book_request_event.dart';
import '../bloc/book_request_state.dart';

// ─── Page ─────────────────────────────────────────────────────────────────────

class BookOrderPage extends StatelessWidget {
  final BookRequestEntity request;
  final int initialTab;

  const BookOrderPage({
    super.key,
    required this.request,
    this.initialTab = 0,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<BookRequestBloc>()..add(LoadLibraryDetails()),
      child: _BookOrderView(request: request, initialTab: initialTab),
    );
  }
}

// ─── View ─────────────────────────────────────────────────────────────────────

class _BookOrderView extends StatefulWidget {
  final BookRequestEntity request;
  final int initialTab;

  const _BookOrderView({required this.request, required this.initialTab});

  @override
  State<_BookOrderView> createState() => _BookOrderViewState();
}

class _BookOrderViewState extends State<_BookOrderView> {
  late int _currentTab;
  LibraryEntity? _library;

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _currentTab = widget.initialTab;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  String get _appBarTitle =>
      _currentTab == 0 ? 'Book Order' : 'Delivery Details';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF052E44)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _appBarTitle,
          style: const TextStyle(
            color: Color(0xFF1E2939),
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
        centerTitle: true,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
        ),
      ),
      body: BlocListener<BookRequestBloc, BookRequestState>(
        listener: (context, state) {
          if (state is LibraryDetailsLoaded) {
            setState(() => _library = state.library);
          }
          if (state is DeliveryFulfillmentSet) {
            setState(() => _currentTab = 1);
          }
          if (state is DeliveryPaymentDone) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Order placed! Your book is on its way 🚚'),
                backgroundColor: Color(0xFF2CE07F),
              ),
            );
            Navigator.of(context).popUntil((route) => route.isFirst);
          }
          if (state is DeliveryError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: Column(
          children: [
            _OrderStepper(currentStep: _currentTab),
            Expanded(
              child: _currentTab == 0
                  ? _BookOrderTab(
                      request: widget.request,
                      library: _library,
                      nameController: _nameController,
                      phoneController: _phoneController,
                      addressController: _addressController,
                    )
                  : _DeliveryDetailsTab(
                      library: _library,
                      deliveryName: _nameController.text.trim(),
                      deliveryPhone: _phoneController.text.trim(),
                      deliveryAddress: _addressController.text.trim(),
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(
          16, 12, 16,
          MediaQuery.of(context).padding.bottom + 16,
        ),
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: BlocBuilder<BookRequestBloc, BookRequestState>(
            builder: (context, state) {
              final isLoading = state is DeliveryFulfillmentLoading ||
                  state is DeliveryPaymentLoading;
              return ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () {
                        if (_currentTab == 0) {
                          final address = _addressController.text.trim();
                          final name = _nameController.text.trim();
                          final phone = _phoneController.text.trim();
                          if (name.isEmpty || phone.isEmpty || address.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Please fill in all fields')),
                            );
                            return;
                          }
                          context.read<BookRequestBloc>().add(
                                SetDeliveryFulfillment(
                                  requestId: widget.request.id,
                                  name: name,
                                  phone: phone,
                                  address: address,
                                ),
                              );
                        } else {
                          context.read<BookRequestBloc>().add(
                                ConfirmDeliveryPayment(
                                  requestId: widget.request.id,
                                ),
                              );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2CE07F),
                  disabledBackgroundColor:
                      const Color(0xFF2CE07F).withValues(alpha: 0.6),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          color: Color(0xFF1E2939),
                          strokeWidth: 2.5,
                        ),
                      )
                    : Text(
                        _currentTab == 0 ? 'Proceed' : 'Proceed to Pay',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E2939),
                        ),
                      ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// ─── 2-step stepper ───────────────────────────────────────────────────────────

class _OrderStepper extends StatelessWidget {
  final int currentStep;

  const _OrderStepper({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    const steps = ['Book Order', 'Delivery Details'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(steps.length * 2 - 1, (index) {
          if (index.isOdd) {
            final isCompleted = (index ~/ 2) < currentStep;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Container(
                  height: 1.5,
                  color: isCompleted
                      ? const Color(0xFF052E44)
                      : const Color(0xFFDDDDDD),
                ),
              ),
            );
          }

          final stepIndex = index ~/ 2;
          final isActive = stepIndex == currentStep;
          final isCompleted = stepIndex < currentStep;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(
                    color: isActive || isCompleted
                        ? const Color(0xFF052E44)
                        : const Color(0xFFCCCCCC),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: isCompleted
                      ? const Icon(Icons.check,
                          size: 16, color: Color(0xFF052E44))
                      : Text(
                          '${stepIndex + 1}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isActive
                                ? const Color(0xFF052E44)
                                : const Color(0xFFAAAAAA),
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                steps[stepIndex],
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.normal,
                  color: isActive
                      ? const Color(0xFF052E44)
                      : const Color(0xFFAAAAAA),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

// ─── Tab 1: Book Order ────────────────────────────────────────────────────────

class _BookOrderTab extends StatelessWidget {
  final BookRequestEntity request;
  final LibraryEntity? library;
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController addressController;

  const _BookOrderTab({
    required this.request,
    required this.library,
    required this.nameController,
    required this.phoneController,
    required this.addressController,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _BookCard(request: request),
          const SizedBox(height: 12),
          const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
          const SizedBox(height: 20),
          _DeliveryAgentCard(library: library),
          const SizedBox(height: 20),
          const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
          const SizedBox(height: 20),
          const Text(
            'User Details',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E2939),
            ),
          ),
          const SizedBox(height: 16),
          const _FieldLabel(label: 'User Name'),
          const SizedBox(height: 8),
          _InputField(
            controller: nameController,
            hint: 'Enter Name',
            keyboardType: TextInputType.name,
          ),
          const SizedBox(height: 16),
          const _FieldLabel(label: 'Phone Number'),
          const SizedBox(height: 8),
          _InputField(
            controller: phoneController,
            hint: 'Enter phone number',
            keyboardType: TextInputType.phone,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          const SizedBox(height: 16),
          const _FieldLabel(label: 'Address'),
          const SizedBox(height: 8),
          _InputField(
            controller: addressController,
            hint: 'Enter delivery address',
            keyboardType: TextInputType.streetAddress,
            maxLines: 3,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ─── Tab 2: Delivery Details ──────────────────────────────────────────────────

class _DeliveryDetailsTab extends StatelessWidget {
  final LibraryEntity? library;
  final String deliveryName;
  final String deliveryPhone;
  final String deliveryAddress;

  const _DeliveryDetailsTab({
    required this.library,
    required this.deliveryName,
    required this.deliveryPhone,
    required this.deliveryAddress,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DeliveryTimelineV2(
            library: library,
            deliveryName: deliveryName,
            deliveryPhone: deliveryPhone,
            deliveryAddress: deliveryAddress,
          ),
          const SizedBox(height: 28),
          const _DeliveryBoySection(),
          const SizedBox(height: 28),
          const _PayOfDeliverySection(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ─── From / To delivery timeline ─────────────────────────────────────────────
//
// Layout (matches screenshot):
//   • "From" circle (green, ~52px diameter) left-aligned
//   • thin dark line from bottom of circle down to top of pickup card
//   • pickup card (full width)
//   • thin dark line from bottom of card down to "To" circle
//   • "To" circle
//   • thin dark line from bottom of "To" circle to top of dropoff card
//   • dropoff card

class _DeliveryTimelineV2 extends StatelessWidget {
  final LibraryEntity? library;
  final String deliveryName;
  final String deliveryPhone;
  final String deliveryAddress;

  const _DeliveryTimelineV2({
    required this.library,
    required this.deliveryName,
    required this.deliveryPhone,
    required this.deliveryAddress,
  });

  @override
  Widget build(BuildContext context) {
    final libName = library?.name ?? '—';
    final libPhone = library?.contactNumber ?? '—';
    final libAddress = library?.address.fullAddress ?? '—';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _TimelineCircle(label: 'From'),
        const _TimelineLine(height: 14),
        _TimelineCard(
          icon: Icons.local_shipping_outlined,
          description: 'Your book will be picked up from $libAddress',
          boldLines: ['$libName - $libPhone', libAddress],
        ),
        const _TimelineLine(height: 14),
        const _TimelineCircle(label: 'To'),
        const _TimelineLine(height: 14),
        _TimelineCard(
          icon: Icons.local_shipping_outlined,
          description: 'Your book will be delivered to',
          boldLines: [deliveryName, deliveryPhone, deliveryAddress],
        ),
      ],
    );
  }
}

class _TimelineCircle extends StatelessWidget {
  final String label;
  const _TimelineCircle({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: const BoxDecoration(
        color: Color(0xFF2CE07F),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E2939),
          ),
        ),
      ),
    );
  }
}

class _TimelineLine extends StatelessWidget {
  final double height;
  const _TimelineLine({required this.height});

  @override
  Widget build(BuildContext context) {
    // Centered under the 52px circle
    return SizedBox(
      width: 36,
      height: height,
      child: Center(
        child: Container(
          width: 2,
          height: height,
          color: const Color(0xFF1A3C4A),
        ),
      ),
    );
  }
}

class _TimelineCard extends StatelessWidget {
  final IconData icon;
  final String description;
  final List<String> boldLines;

  const _TimelineCard({
    required this.icon,
    required this.description,
    required this.boldLines,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE8E8E8), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: const Color(0xFF1E2939)),
          const SizedBox(height: 10),
          Text(
            description,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF444444),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          ...boldLines.where((l) => l.isNotEmpty).map(
                (line) => Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(
                    line,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E2939),
                    ),
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

// ─── Delivery Boy Details section ─────────────────────────────────────────────

class _DeliveryBoySection extends StatelessWidget {
  const _DeliveryBoySection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.local_shipping_outlined,
                size: 20, color: Color(0xFF1E2939)),
            SizedBox(width: 8),
            Text(
              'Delivery Boy Details',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E2939),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const _DetailRow(
            icon: Icons.person_outline, label: 'Name', value: 'Sunil Soni'),
        const Divider(height: 1, color: Color(0xFFEEEEEE)),
        const _DetailRow(
            icon: Icons.phone_outlined,
            label: 'Contact No.',
            value: '0123456789'),
        const Divider(height: 1, color: Color(0xFFEEEEEE)),
        _StatusRow(),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF555555)),
          const SizedBox(width: 10),
          Text(label,
              style: const TextStyle(fontSize: 14, color: Color(0xFF444444))),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1E2939),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const statuses = ['Picked Up', 'On Way', 'Delivered'];
    const activeIndex = 0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          const Icon(Icons.phone_callback_outlined,
              size: 20, color: Color(0xFF555555)),
          const SizedBox(width: 10),
          const Text('Status',
              style: TextStyle(fontSize: 14, color: Color(0xFF444444))),
          const Spacer(),
          Row(
            children: List.generate(statuses.length, (i) {
              final isActive = i == activeIndex;
              return Padding(
                padding: EdgeInsets.only(left: i == 0 ? 0 : 6),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color:
                        isActive ? const Color(0xFF2CE07F) : Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isActive
                          ? const Color(0xFF2CE07F)
                          : const Color(0xFFCCCCCC),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    statuses[i],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isActive
                          ? const Color(0xFF1E2939)
                          : const Color(0xFF888888),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ─── Pay of Delivery section ──────────────────────────────────────────────────

class _PayOfDeliverySection extends StatelessWidget {
  const _PayOfDeliverySection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.account_balance_wallet_outlined,
                size: 20, color: Color(0xFF1E2939)),
            SizedBox(width: 8),
            Text(
              'Pay of Delivery',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E2939),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Column(
            children: [
              _ChargeRow(
                  label: 'Book Delivery Charge',
                  amount: '+60',
                  showDivider: true),
              _ChargeRow(
                  label: 'Delivery App Partner Fee',
                  amount: '+20',
                  showDivider: false),
            ],
          ),
        ),
      ],
    );
  }
}

class _ChargeRow extends StatelessWidget {
  final String label;
  final String amount;
  final bool showDivider;

  const _ChargeRow({
    required this.label,
    required this.amount,
    required this.showDivider,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 14, color: Color(0xFF444444))),
              Text(
                amount,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1E2939),
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          const Divider(height: 1, thickness: 1, color: Color(0xFFE8E8E8)),
      ],
    );
  }
}

// ─── Book info card ───────────────────────────────────────────────────────────

class _BookCard extends StatelessWidget {
  final BookRequestEntity request;

  const _BookCard({required this.request});

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1).toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: request.bookCoverUrl != null &&
                  request.bookCoverUrl!.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: request.bookCoverUrl!,
                  width: 90,
                  height: 120,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => _placeholder(),
                  errorWidget: (_, __, ___) => _placeholder(),
                )
              : _placeholder(),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                request.bookTitle ?? 'Unknown Book',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E2939),
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Donated By  ${request.donorName ?? 'Unknown'}',
                style: const TextStyle(fontSize: 13, color: Color(0xFF555555)),
              ),
              const SizedBox(height: 4),
              if (request.bookFormat != null && request.bookFormat!.isNotEmpty)
                Text(
                  'Format - ${_capitalize(request.bookFormat!)}',
                  style:
                      const TextStyle(fontSize: 13, color: Color(0xFF555555)),
                ),
              const SizedBox(height: 4),
              const Text(
                'Quantity - 1',
                style: TextStyle(fontSize: 13, color: Color(0xFF555555)),
              ),
            ],
          ),
        ),
        const Icon(Icons.chevron_right, color: Color(0xFF888888), size: 22),
      ],
    );
  }

  Widget _placeholder() {
    return Container(
      width: 90,
      height: 120,
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.menu_book, size: 36, color: Colors.grey),
    );
  }
}

// ─── Delivery agent card ──────────────────────────────────────────────────────

class _DeliveryAgentCard extends StatelessWidget {
  final LibraryEntity? library;

  const _DeliveryAgentCard({required this.library});

  @override
  Widget build(BuildContext context) {
    final name = library?.name ?? '—';
    final phone = library?.contactNumber ?? '—';
    final address = library?.address.fullAddress ?? '—';
    final hours = library?.openHours ?? '—';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEAEAEA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E0E0),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFCCCCCC)),
                ),
                child: const Icon(Icons.store_outlined,
                    size: 24, color: Color(0xFF888888)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E2939),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on_outlined,
                  size: 16, color: Color(0xFF888888)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  address,
                  style: const TextStyle(
                      fontSize: 13, color: Color(0xFF555555), height: 1.4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.phone_outlined, size: 16, color: Color(0xFF888888)),
              const SizedBox(width: 8),
              Text(phone,
                  style: const TextStyle(fontSize: 13, color: Color(0xFF555555))),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.access_time_outlined,
                  size: 16, color: Color(0xFF888888)),
              const SizedBox(width: 8),
              Text(hours,
                  style: const TextStyle(fontSize: 13, color: Color(0xFF555555))),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Field label ──────────────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String label;

  const _FieldLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Color(0xFF1E2939),
      ),
    );
  }
}

// ─── Text input field ─────────────────────────────────────────────────────────

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int maxLines;

  const _InputField({
    required this.controller,
    required this.hint,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 14, color: Color(0xFF1E2939)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 14, color: Color(0xFFAAAAAA)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFDDDDDD), width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF2CE07F), width: 1.5),
        ),
      ),
    );
  }
}
