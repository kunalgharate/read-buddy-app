import 'package:read_buddy_app/core/theme/app_colors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/utils/secure_storage_utils.dart';
import '../../../profile/presentation/blocs/profile_bloc.dart';
import '../../data/datasources/book_request_remote_datasource.dart';
import '../../domain/entities/book_request_entity.dart';
import '../../domain/entities/library_entity.dart';
import '../../domain/entities/pickup_details_entity.dart';
import '../bloc/book_request_bloc.dart';
import '../bloc/book_request_event.dart';
import '../bloc/book_request_state.dart';

// ─── Page ─────────────────────────────────────────────────────────────────────

class CollectFromLibraryPage extends StatelessWidget {
  final BookRequestEntity request;
  final int initialTab;
  final bool isReturn;

  const CollectFromLibraryPage({
    super.key,
    required this.request,
    this.initialTab = 0,
    this.isReturn = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final bloc = getIt<BookRequestBloc>();
        _dispatchLoad(bloc);
        return bloc;
      },
      child: _CollectFromLibraryView(
        request: request,
        initialTab: initialTab,
        isReturn: isReturn,
      ),
    );
  }

  // Resolves the user's location (cached fast-path, otherwise a fresh fix)
  // before dispatching LoadLibraryDetails, so nearest-within-15km selection
  // is not skipped on a cold start. Guards against a closed bloc.
  Future<void> _dispatchLoad(BookRequestBloc bloc) async {
    var pos = LocationService.instance.lastPosition;
    pos ??= await LocationService.instance.getCurrentLocation();
    if (bloc.isClosed) return;
    bloc.add(
      LoadLibraryDetails(
        preferredLibraryId: request.libraryId,
        userLat: pos?.latitude,
        userLng: pos?.longitude,
      ),
    );
  }
}

class _CollectFromLibraryView extends StatefulWidget {
  final BookRequestEntity request;
  final int initialTab;
  final bool isReturn;

  const _CollectFromLibraryView({
    required this.request,
    required this.initialTab,
    this.isReturn = false,
  });

  @override
  State<_CollectFromLibraryView> createState() =>
      _CollectFromLibraryViewState();
}

class _CollectFromLibraryViewState extends State<_CollectFromLibraryView> {
  late int _selectedTab;
  bool _showingConfirmation = false;

  late final Razorpay _razorpay;
  bool _paying = false;

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  bool _isEditingAddress = false;

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.initialTab;
    _prefillFromUser();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _onReturnPaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _onReturnPaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, (_) {});
  }

  Future<void> _prefillFromUser() async {
    final storage = getIt<SecureStorageUtil>();
    final user = await storage.getUser();
    if (!mounted) return;
    setState(() {
      _nameController.text = widget.request.pickupUserName ??
          widget.request.deliveryName ??
          widget.request.userName ??
          user?.name ??
          '';
      _phoneController.text = widget.request.pickupPhone ??
          widget.request.deliveryPhone ??
          user?.phno ??
          '';
      _addressController.text =
          widget.request.pickupAddress ?? widget.request.deliveryAddress ?? '';
    });
  }

  @override
  void dispose() {
    _razorpay.clear();
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF2CE07F),
            onPrimary: AppColors.textPrimary,
            onSurface: AppColors.textPrimary,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF2CE07F),
            onPrimary: AppColors.textPrimary,
            onSurface: AppColors.textPrimary,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'DD/MM/YYYY';
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    return '$d/$m/${date.year}';
  }

  String _formatTime(TimeOfDay? time) {
    if (time == null) return '00:00 PM/AM';
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '${hour.toString().padLeft(2, '0')}:$minute $period';
  }

  bool _validateStep() {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final address = _addressController.text.trim();
    final isDropOffReturn = widget.isReturn && _selectedTab == 1;

    if (!widget.isReturn) {
      if (name.isEmpty || phone.isEmpty) {
        _showSnack('Please fill in all fields');
        return false;
      }
      if (phone.length != 10) {
        _showSnack('Phone number must be exactly 10 digits');
        return false;
      }
    }
    if (isDropOffReturn) {
      // no address needed for library drop-off
    } else {
      if (address.isEmpty) {
        _showSnack('Please fill in all fields');
        return false;
      }
      if (address.length < 10) {
        _showSnack('Please enter a valid address');
        return false;
      }
    }
    if (_selectedDate == null) {
      _showSnack('Please select a date');
      return false;
    }
    if (_selectedTime == null) {
      _showSnack('Please select a time');
      return false;
    }
    return true;
  }

  void _onConfirm() {
    if (_validateStep()) {
      setState(() => _showingConfirmation = true);
    }
  }

  // Tab 0 for the return flow is paid home pickup; tab 1 is free library
  // drop-off. Only the drop-off return goes through SchedulePickup; the paid
  // pickup is handled by the Razorpay create-order/verify flow below.
  bool get _isHomePickupReturn => widget.isReturn && _selectedTab == 0;

  String? get _selectedLibraryId {
    final state = context.read<BookRequestBloc>().state;
    if (state is LibraryDetailsLoaded) return state.library.id;
    return null;
  }

  void _onActualConfirm() {
    if (_isHomePickupReturn) {
      _startReturnPickupPayment();
      return;
    }

    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final address = widget.isReturn && _selectedTab == 1
        ? 'library-drop-off'
        : _addressController.text.trim();

    final libraryId = widget.isReturn && _selectedTab == 1
        ? _selectedLibraryId
        : null;
    if (widget.isReturn && _selectedTab == 1 &&
        (libraryId == null || libraryId.isEmpty)) {
      _showSnack('Library details are still loading. Please try again.');
      return;
    }

    final timeStr =
        '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}';

    context.read<BookRequestBloc>().add(
          SchedulePickup(
            PickupDetailsEntity(
              requestId: widget.request.id,
              userName: name,
              phoneNumber: phone,
              address: address,
              pickupDate: _selectedDate!,
              pickupTime: timeStr,
            ),
            isReturn: widget.isReturn,
            returnMethod: widget.isReturn
                ? (_selectedTab == 1 ? 'DROP_OFF' : 'PICKUP')
                : null,
            returnBranchId: libraryId,
          ),
        );
  }

  // PICKUP returns are paid (₹25 home-collection fee). create-order requires
  // the request to still be `delivered`, so it runs before any initiate-return
  // / verify call. The backend must return a `razorpayKey`; without it we can't
  // open checkout, so surface the guarded message.
  Future<void> _startReturnPickupPayment() async {
    if (_paying) return;
    setState(() => _paying = true);
    try {
      final ds = getIt<BookRequestRemoteDataSource>();
      final res = await ds.createReturnPickupOrder(widget.request.id);
      final razorpayKey = res['razorpayKey'] as String?;
      final orderId = res['orderId'] as String?;
      if (razorpayKey == null ||
          razorpayKey.isEmpty ||
          orderId == null ||
          orderId.isEmpty) {
        throw Exception(
          'Payment is temporarily unavailable. Please try again later.',
        );
      }
      if (!mounted) return;
      final amount = res['amount'];
      _razorpay.open({
        'key': razorpayKey,
        'amount': amount is num ? amount.toInt() : amount,
        'currency': 'INR',
        'order_id': orderId,
        'name': 'ReadBuddy',
        'description': 'Home Pickup Return Fee',
        'prefill': {
          'name': _nameController.text.trim(),
          'contact': _phoneController.text.trim(),
        },
        'theme': {'color': '#2CE07F'},
      });
    } catch (e) {
      if (mounted) {
        setState(() => _paying = false);
        _showSnack(e.toString().replaceFirst('Exception: ', ''));
      }
    }
  }

  Future<void> _onReturnPaymentSuccess(PaymentSuccessResponse response) async {
    try {
      final ds = getIt<BookRequestRemoteDataSource>();
      await ds.verifyReturnPickupPayment(
        widget.request.id,
        paymentId: response.paymentId ?? '',
        orderId: response.orderId ?? '',
        signature: response.signature ?? '',
        pickupAddress: _addressController.text.trim(),
      );
      if (!mounted) return;
      setState(() => _paying = false);
      context.read<ProfileBloc>().add(LoadProfileEvent());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment successful! Return pickup scheduled.'),
          backgroundColor: Color(0xFF2CE07F),
        ),
      );
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      if (mounted) {
        setState(() => _paying = false);
        _showSnack('Payment verification failed: $e');
      }
    }
  }

  void _onReturnPaymentError(PaymentFailureResponse response) {
    if (!mounted) return;
    setState(() => _paying = false);
    _showSnack('Payment failed: ${response.message ?? 'Please try again'}');
  }

  // DEV/TEST ONLY: completes the ₹25 return pickup fee via the backend demo
  // bypass (no card), mirroring the delivery-fee test hook. Useful for E2E
  // testing while the live checkout key is pending on the backend.
  Future<void> _payReturnPickupTest() async {
    if (_paying) return;
    setState(() => _paying = true);
    try {
      final ds = getIt<BookRequestRemoteDataSource>();
      final res = await ds.createReturnPickupOrder(widget.request.id);
      final orderId = res['orderId'] as String?;
      if (orderId == null || orderId.isEmpty) {
        throw Exception('Payment order was not created. Please try again.');
      }
      await ds.verifyReturnPickupPayment(
        widget.request.id,
        paymentId: 'pay_demo_success_99',
        orderId: orderId,
        signature: 'demo_bypass',
        pickupAddress: _addressController.text.trim(),
      );
      if (!mounted) return;
      setState(() => _paying = false);
      context.read<ProfileBloc>().add(LoadProfileEvent());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Return pickup scheduled! (test)')),
      );
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      if (mounted) {
        setState(() => _paying = false);
        _showSnack(e.toString().replaceFirst('Exception: ', ''));
      }
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget _buildConfirmationView() {
    final isPickup = _selectedTab == 0;
    final isDropOffReturn = widget.isReturn && _selectedTab == 1;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _BookCard(request: widget.request),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF9F9F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Confirm Details',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                _confirmRow('Method', isPickup ? 'Pick Up' : 'Drop Off'),
                if (!isDropOffReturn) ...[
                  _confirmRow('Name', _nameController.text.trim()),
                  _confirmRow('Phone', _phoneController.text.trim()),
                ],
                if (!isDropOffReturn)
                  _confirmRow('Address', _addressController.text.trim()),
                _confirmRow('Date', _formatDate(_selectedDate)),
                _confirmRow('Time', _formatTime(_selectedTime)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _confirmRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF888888),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Book Pick-Up & Drop',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocListener<BookRequestBloc, BookRequestState>(
        listenWhen: (_, state) =>
            state is PickupScheduled || state is PickupScheduleError,
        listener: (context, state) {
          if (state is PickupScheduled) {
            String message;
            if (widget.isReturn) {
              message = _selectedTab == 1
                  ? 'Return initiated. Please drop the book at the library.'
                  : 'Return pickup scheduled successfully.';
            } else {
              message = 'Pickup scheduled! See you at the library 📚';
            }
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message),
                backgroundColor: const Color(0xFF2CE07F),
              ),
            );
            Navigator.of(context).popUntil((route) => route.isFirst);
          } else if (state is PickupScheduleError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: _showingConfirmation
            ? _buildConfirmationView()
            : Column(
                children: [
                  // ── Tab row ──────────────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: _PickupTabRow(
                      selected: _selectedTab,
                      initialTab: widget.initialTab,
                      onChanged: (i) => setState(() => _selectedTab = i),
                    ),
                  ),

                  // ── Scrollable body ──────────────────────────────────────────
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Book info card ─────────────────────────────────
                          _BookCard(request: widget.request),

                          const SizedBox(height: 20),

                          const SizedBox(height: 28),

                          if (widget.isReturn && _selectedTab == 1)
                            const Text(
                              'Return Schedule',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E2939),
                              ),
                            ),

                          if (!widget.isReturn || _selectedTab == 0) ...[
                            // ── User Details header ────────────────────────────
                            const Text(
                              'User Details',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E2939),
                              ),
                            ),

                            const SizedBox(height: 16),
                          ],

                          if (!widget.isReturn || _selectedTab == 0) ...[
                            const _FieldLabel(label: 'User Name'),
                            const SizedBox(height: 8),
                            _InputField(
                              controller: _nameController,
                              hint: 'Enter Name',
                              keyboardType: TextInputType.name,
                            ),
                            const SizedBox(height: 16),
                            const _FieldLabel(label: 'Phone Number'),
                            const SizedBox(height: 8),
                            _InputField(
                              controller: _phoneController,
                              hint: 'Enter phone number',
                              keyboardType: TextInputType.phone,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(10),
                              ],
                            ),
                            const SizedBox(height: 16),
                          ],

                          if (!widget.isReturn || _selectedTab == 0) ...[
                            // ── Address (read-only for return pickup) ──────
                            Row(
                              children: [
                                const _FieldLabel(label: 'Address'),
                                if (widget.isReturn && _selectedTab == 0) ...[
                                  const Spacer(),
                                  GestureDetector(
                                    onTap: () => setState(
                                      () => _isEditingAddress =
                                          !_isEditingAddress,
                                    ),
                                    child: Text(
                                      _isEditingAddress
                                          ? 'Done'
                                          : 'Change Address',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF2CE07F),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 8),
                            _InputField(
                              controller: _addressController,
                              hint:
                                  'e.g. Flat 12, Sunrise Apts, MG Road, Mumbai',
                              keyboardType: TextInputType.streetAddress,
                              prefixIcon: const Icon(
                                Icons.location_on_outlined,
                                color: Color(0xFF888888),
                                size: 20,
                              ),
                              maxLines: 3,
                              minLines: 3,
                              readOnly: widget.isReturn &&
                                  _selectedTab == 0 &&
                                  !_isEditingAddress,
                              helperText:
                                  'Include flat/house no., street, area  •  min 10 characters',
                            ),
                          ],

                          const SizedBox(height: 16),

                          // ── Date + Time row ────────────────────────────────
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const _FieldLabel(label: 'Select Date'),
                                    const SizedBox(height: 8),
                                    _DateTimePickerButton(
                                      icon: Icons.calendar_month_outlined,
                                      label: _formatDate(_selectedDate),
                                      isPlaceholder: _selectedDate == null,
                                      onTap: _pickDate,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const _FieldLabel(label: 'Time'),
                                    const SizedBox(height: 8),
                                    _DateTimePickerButton(
                                      icon: Icons.access_time_outlined,
                                      label: _formatTime(_selectedTime),
                                      isPlaceholder: _selectedTime == null,
                                      onTap: _pickTime,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // ── Library card ───────────────────────────────────
                          BlocBuilder<BookRequestBloc, BookRequestState>(
                            builder: (context, state) {
                              if (state is LibraryDetailsLoading) {
                                return const Center(
                                  child: CircularProgressIndicator(
                                    color: Color(0xFF2CE07F),
                                  ),
                                );
                              }
                              if (state is LibraryDetailsLoaded) {
                                return _LibraryCard(library: state.library);
                              }
                              if (state is LibraryDetailsError) {
                                return Center(
                                  child: Text(
                                    state.message,
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),

                          const SizedBox(height: 28),
                        ],
                      ),
                    ),
                  ),
                ],
              ), // end Column (BlocListener child)
      ), // end BlocListener
      bottomNavigationBar: _showingConfirmation
          ? Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                12,
                16,
                MediaQuery.of(context).padding.bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: BlocBuilder<BookRequestBloc, BookRequestState>(
                      builder: (context, state) {
                        final isLoading = state is PickupScheduling || _paying;
                        return ElevatedButton(
                          onPressed: isLoading ? null : _onActualConfirm,
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
                                    color: AppColors.textPrimary,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : Text(
                                  _isHomePickupReturn
                                      ? 'Confirm & Pay ₹25'
                                      : 'Confirm',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                        );
                      },
                    ),
                  ),
                  if (_isHomePickupReturn &&
                      (kDebugMode ||
                          (AppConfig.isInitialized &&
                              AppConfig.instance.isDev))) ...[
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: OutlinedButton.icon(
                        onPressed: _paying ? null : _payReturnPickupTest,
                        icon: const Icon(Icons.bolt, size: 18),
                        label: const Text('Pay ₹25 (TEST)'),
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: OutlinedButton(
                      onPressed: () =>
                          setState(() => _showingConfirmation = false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textPrimary,
                        side: const BorderSide(
                          color: Color(0xFFCCCCCC),
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Back',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                12,
                16,
                MediaQuery.of(context).padding.bottom + 16,
              ),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _onConfirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2CE07F),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Next',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}

// ─── Tab row ──────────────────────────────────────────────────────────────────

class _PickupTabRow extends StatelessWidget {
  final int selected;
  final int initialTab;
  final ValueChanged<int> onChanged;

  const _PickupTabRow({
    required this.selected,
    required this.initialTab,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _PickupTabButton(
            label: 'Pick Up',
            icon: Icons.menu_book_outlined,
            isSelected: selected == 0,
            isDisabled: initialTab != 0,
            onTap: () => onChanged(0),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _PickupTabButton(
            label: 'Drop Off',
            icon: Icons.menu_book_outlined,
            isSelected: selected == 1,
            isDisabled: initialTab != 1,
            onTap: () => onChanged(1),
          ),
        ),
      ],
    );
  }
}

class _PickupTabButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final bool isDisabled;
  final VoidCallback onTap;

  const _PickupTabButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.isDisabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: isDisabled
              ? const Color(0xFFF0F0F0)
              : isSelected
                  ? const Color(0xFF2CE07F)
                  : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isDisabled
                ? const Color(0xFFE0E0E0)
                : isSelected
                    ? const Color(0xFF2CE07F)
                    : const Color(0xFFDDDDDD),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isDisabled
                  ? const Color(0xFFCCCCCC)
                  : isSelected
                      ? AppColors.textPrimary
                      : const Color(0xFFAAAAAA),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDisabled
                    ? const Color(0xFFCCCCCC)
                    : isSelected
                        ? AppColors.textPrimary
                        : const Color(0xFFAAAAAA),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Book info card ─────────────────────────────────────────────────────

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
          child:
              request.bookCoverUrl != null && request.bookCoverUrl!.isNotEmpty
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
                  color: AppColors.textPrimary,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Donated By ${request.donorName ?? 'Unknown'}',
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF555555),
                ),
              ),
              const SizedBox(height: 4),
              if (request.bookFormat != null && request.bookFormat!.isNotEmpty)
                Text(
                  _capitalize(request.bookFormat!),
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF555555),
                  ),
                ),
            ],
          ),
        ),
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

// ─── Library card ─────────────────────────────────────────────────────────────

class _LibraryCard extends StatelessWidget {
  final LibraryEntity library;

  const _LibraryCard({required this.library});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Name + Start Now ─────────────────────────────────────
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
                child: const Icon(
                  Icons.location_city,
                  size: 26,
                  color: Color(0xFF888888),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  library.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ── Address ──────────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 16,
                color: Color(0xFF888888),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  library.address.fullAddress,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF555555),
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // ── Phone ─────────────────────────────────────────────────
          Row(
            children: [
              const Icon(
                Icons.phone_outlined,
                size: 16,
                color: Color(0xFF888888),
              ),
              const SizedBox(width: 8),
              Text(
                library.contactNumber,
                style: const TextStyle(fontSize: 13, color: Color(0xFF555555)),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // ── Hours ─────────────────────────────────────────────────
          Row(
            children: [
              const Icon(
                Icons.access_time_outlined,
                size: 16,
                color: Color(0xFF888888),
              ),
              const SizedBox(width: 8),
              Text(
                library.openHours,
                style: const TextStyle(fontSize: 13, color: Color(0xFF555555)),
              ),
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
        color: AppColors.textPrimary,
      ),
    );
  }
}

// ─── Text input field ─────────────────────────────────────────────────────────

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;
  final Widget? prefixIcon;
  final List<TextInputFormatter>? inputFormatters;
  final int maxLines;
  final int minLines;
  final String? helperText;
  final bool readOnly;

  const _InputField({
    required this.controller,
    required this.hint,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.inputFormatters,
    this.maxLines = 1,
    this.minLines = 1,
    this.helperText,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      minLines: minLines,
      readOnly: readOnly,
      style: TextStyle(
        fontSize: 14,
        color: readOnly ? const Color(0xFF888888) : const Color(0xFF1E2939),
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 14, color: Color(0xFFAAAAAA)),
        helperText: helperText,
        helperMaxLines: 3,
        helperStyle: const TextStyle(
          fontSize: 11,
          color: Color(0xFF999999),
          height: 1.4,
        ),
        prefixIcon: prefixIcon,
        contentPadding: EdgeInsets.symmetric(
          horizontal: prefixIcon != null ? 0 : 16,
          vertical: 14,
        ),
        filled: true,
        fillColor: readOnly ? const Color(0xFFF5F5F5) : Colors.white,
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

// ─── Date / Time picker button ────────────────────────────────────────────────

class _DateTimePickerButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isPlaceholder;
  final VoidCallback onTap;

  const _DateTimePickerButton({
    required this.icon,
    required this.label,
    required this.isPlaceholder,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFDDDDDD), width: 1.2),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: const Color(0xFF555555)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: isPlaceholder
                      ? const Color(0xFFAAAAAA)
                      : AppColors.textPrimary,
                  fontWeight:
                      isPlaceholder ? FontWeight.normal : FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
