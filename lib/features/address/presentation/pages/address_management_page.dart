import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:read_buddy_app/core/di/injection.dart';
import 'package:read_buddy_app/core/theme/app_colors.dart';
import 'package:read_buddy_app/core/services/location_service.dart';
import '../bloc/address_bloc.dart';
import '../../domain/entities/address_entity.dart';
import '../../data/models/address_model.dart';

class AddressManagementPage extends StatelessWidget {
  const AddressManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AddressBloc>()..add(LoadAddresses()),
      child: const _AddressManagementView(),
    );
  }
}

class _AddressManagementView extends StatelessWidget {
  const _AddressManagementView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Addresses')),
      body: BlocConsumer<AddressBloc, AddressState>(
        listener: (context, state) {
          if (state is AddressCreated || state is AddressUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Address saved')),
            );
            context.read<AddressBloc>().add(LoadAddresses());
          }
          if (state is AddressDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Address deleted')),
            );
            context.read<AddressBloc>().add(LoadAddresses());
          }
          if (state is AddressError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is AddressLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is AddressesLoaded) {
            if (state.addresses.isEmpty) {
              return const Center(
                child: Text('No addresses yet. Tap + to add one.'),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.addresses.length,
              itemBuilder: (context, index) => _AddressCard(
                address: state.addresses[index],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddressForm(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Address'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  void _showAddressForm(BuildContext context, {AddressEntity? existing}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<AddressBloc>(),
        child: _AddressForm(existing: existing),
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  final AddressEntity address;
  const _AddressCard({required this.address});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                address.label.toLowerCase() == 'work'
                    ? Icons.work_outline
                    : Icons.home_outlined,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        address.label,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (address.isDefault) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'DEFAULT',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    address.name.isNotEmpty ? address.name : '',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    address.fullAddress,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textHint,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  const _AddressManagementView()
                      ._showAddressForm(context, existing: address);
                } else if (value == 'delete') {
                  context
                      .read<AddressBloc>()
                      .add(DeleteAddressEvent(address.id));
                }
              },
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'edit', child: Text('Edit')),
                const PopupMenuItem(
                  value: 'delete',
                  child: Text('Delete', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AddressForm extends StatefulWidget {
  final AddressEntity? existing;
  const _AddressForm({this.existing});

  @override
  State<_AddressForm> createState() => _AddressFormState();
}

class _AddressFormState extends State<_AddressForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _line1Ctrl;
  late final TextEditingController _line2Ctrl;
  late final TextEditingController _cityCtrl;
  late final TextEditingController _stateCtrl;
  late final TextEditingController _pincodeCtrl;
  String _label = 'Home';
  bool _isDefault = false;
  double _lat = 0;
  double _lng = 0;
  bool _fetchingLocation = false;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _nameCtrl = TextEditingController(text: e?.name ?? '');
    _phoneCtrl = TextEditingController(text: e?.phone ?? '');
    _line1Ctrl = TextEditingController(text: e?.addressLine1 ?? '');
    _line2Ctrl = TextEditingController(text: e?.addressLine2 ?? '');
    _cityCtrl = TextEditingController(text: e?.city ?? '');
    _stateCtrl = TextEditingController(text: e?.state ?? '');
    _pincodeCtrl = TextEditingController(text: e?.pincode ?? '');
    _label = e?.label ?? 'Home';
    _isDefault = e?.isDefault ?? false;
    _lat = e?.latitude ?? 0;
    _lng = e?.longitude ?? 0;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _line1Ctrl.dispose();
    _line2Ctrl.dispose();
    _cityCtrl.dispose();
    _stateCtrl.dispose();
    _pincodeCtrl.dispose();
    super.dispose();
  }

  Future<void> _useCurrentLocation() async {
    setState(() => _fetchingLocation = true);
    final pos = await LocationService.instance.getCurrentLocation();
    if (pos == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not get location')),
        );
      }
      setState(() => _fetchingLocation = false);
      return;
    }
    _lat = pos.latitude;
    _lng = pos.longitude;

    final address = await LocationService.instance.reverseGeocode(
      pos.latitude,
      pos.longitude,
    );
    if (address != null) {
      _line1Ctrl.text = address.street;
      _cityCtrl.text = address.city;
      _stateCtrl.text = address.state;
      _pincodeCtrl.text = address.pincode;
    }
    setState(() => _fetchingLocation = false);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final data = AddressModel(
      id: '',
      label: _label,
      name: _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      addressLine1: _line1Ctrl.text.trim(),
      addressLine2: _line2Ctrl.text.trim(),
      city: _cityCtrl.text.trim(),
      state: _stateCtrl.text.trim(),
      pincode: _pincodeCtrl.text.trim(),
      latitude: _lat,
      longitude: _lng,
      isDefault: _isDefault,
    ).toJson();

    if (widget.existing != null) {
      context
          .read<AddressBloc>()
          .add(UpdateAddressEvent(widget.existing!.id, data));
    } else {
      context.read<AddressBloc>().add(CreateAddressEvent(data));
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.existing != null ? 'Edit Address' : 'Add Address',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              // Label selector
              Row(
                children: ['Home', 'Work', 'Other'].map((l) {
                  final selected = _label == l;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(l),
                      selected: selected,
                      onSelected: (_) => setState(() => _label = l),
                      selectedColor: AppColors.primary.withValues(alpha: 0.2),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              _field(_nameCtrl, 'Recipient Name *', validator: _required),
              const SizedBox(height: 10),
              _field(_phoneCtrl, 'Phone *',
                  keyboard: TextInputType.phone, validator: _required),
              const SizedBox(height: 10),
              _field(_line1Ctrl, 'Flat / House / Building *',
                  validator: _required),
              const SizedBox(height: 10),
              _field(_line2Ctrl, 'Street / Area'),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                      child: _field(_cityCtrl, 'City *', validator: _required)),
                  const SizedBox(width: 10),
                  Expanded(
                      child:
                          _field(_stateCtrl, 'State *', validator: _required)),
                ],
              ),
              const SizedBox(height: 10),
              _field(_pincodeCtrl, 'Pincode *',
                  keyboard: TextInputType.number, validator: _required),
              const SizedBox(height: 10),
              // Location
              TextButton.icon(
                onPressed: _fetchingLocation ? null : _useCurrentLocation,
                icon: _fetchingLocation
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.my_location, size: 18),
                label:
                    Text(_lat != 0 ? 'Location set ✓' : 'Use Current Location'),
              ),
              // Default toggle
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Set as default address'),
                value: _isDefault,
                activeTrackColor: AppColors.primary,
                onChanged: (v) => setState(() => _isDefault = v),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: _submit,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  widget.existing != null ? 'Update' : 'Save Address',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController ctrl,
    String label, {
    TextInputType? keyboard,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboard,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    );
  }

  String? _required(String? v) =>
      v == null || v.trim().isEmpty ? 'Required' : null;
}
