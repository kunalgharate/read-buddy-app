import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:read_buddy_app/core/di/injection.dart';
import 'package:read_buddy_app/core/theme/app_colors.dart';
import 'package:read_buddy_app/core/services/location_service.dart';
import '../bloc/library_bloc.dart';
import '../../domain/entities/library_entity.dart';
import '../../data/models/library_model.dart';

/// Create or edit a library. Pass a [LibraryEntity] as route argument to edit.
class CreateLibraryPage extends StatelessWidget {
  final LibraryEntity? existing;
  const CreateLibraryPage({super.key, this.existing});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<LibraryBloc>(),
      child: _CreateLibraryForm(existing: existing),
    );
  }
}

class _CreateLibraryForm extends StatefulWidget {
  final LibraryEntity? existing;
  const _CreateLibraryForm({this.existing});

  @override
  State<_CreateLibraryForm> createState() => _CreateLibraryFormState();
}

class _CreateLibraryFormState extends State<_CreateLibraryForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _contactCtrl;
  late final TextEditingController _hoursCtrl;
  late final TextEditingController _streetCtrl;
  late final TextEditingController _cityCtrl;
  late final TextEditingController _stateCtrl;
  late final TextEditingController _pincodeCtrl;
  late final TextEditingController _latCtrl;
  late final TextEditingController _lngCtrl;
  late bool _isSuperLibrary;
  bool _fetchingLocation = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final lib = widget.existing;
    _nameCtrl = TextEditingController(text: lib?.name ?? '');
    _contactCtrl = TextEditingController(text: lib?.contactNumber ?? '');
    _hoursCtrl = TextEditingController(text: lib?.openHours ?? '');
    _streetCtrl = TextEditingController(text: lib?.address.street ?? '');
    _cityCtrl = TextEditingController(text: lib?.address.city ?? '');
    _stateCtrl = TextEditingController(text: lib?.address.state ?? '');
    _pincodeCtrl = TextEditingController(text: lib?.address.pincode ?? '');
    _latCtrl = TextEditingController(
      text: lib != null && lib.address.latitude != 0
          ? lib.address.latitude.toString()
          : '',
    );
    _lngCtrl = TextEditingController(
      text: lib != null && lib.address.longitude != 0
          ? lib.address.longitude.toString()
          : '',
    );
    _isSuperLibrary = lib?.isSuperLibrary ?? false;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _contactCtrl.dispose();
    _hoursCtrl.dispose();
    _streetCtrl.dispose();
    _cityCtrl.dispose();
    _stateCtrl.dispose();
    _pincodeCtrl.dispose();
    _latCtrl.dispose();
    _lngCtrl.dispose();
    super.dispose();
  }

  Future<void> _useCurrentLocation() async {
    setState(() => _fetchingLocation = true);
    final position = await LocationService.instance.getCurrentLocation();
    if (position == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not get location. Check permissions.'),
          ),
        );
      }
      setState(() => _fetchingLocation = false);
      return;
    }

    _latCtrl.text = position.latitude.toStringAsFixed(6);
    _lngCtrl.text = position.longitude.toStringAsFixed(6);

    // Reverse geocode to fill address fields
    final address = await LocationService.instance.reverseGeocode(
      position.latitude,
      position.longitude,
    );
    if (address != null) {
      _streetCtrl.text = address.street;
      _cityCtrl.text = address.city;
      _stateCtrl.text = address.state;
      _pincodeCtrl.text = address.pincode;
    }
    setState(() => _fetchingLocation = false);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final data = LibraryModel(
      id: '',
      name: _nameCtrl.text.trim(),
      contactNumber: _contactCtrl.text.trim(),
      openHours: _hoursCtrl.text.trim(),
      isSuperLibrary: _isSuperLibrary,
      address: LibraryAddressModel(
        street: _streetCtrl.text.trim(),
        city: _cityCtrl.text.trim(),
        state: _stateCtrl.text.trim(),
        country: 'India',
        pincode: _pincodeCtrl.text.trim(),
        latitude: double.tryParse(_latCtrl.text) ?? 0,
        longitude: double.tryParse(_lngCtrl.text) ?? 0,
      ),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ).toJson();

    if (_isEditing) {
      context
          .read<LibraryBloc>()
          .add(UpdateLibraryEvent(widget.existing!.id, data));
    } else {
      context.read<LibraryBloc>().add(CreateLibraryEvent(data));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Library' : 'Add Library'),
      ),
      body: BlocListener<LibraryBloc, LibraryState>(
        listener: (context, state) {
          if (state is LibraryCreated || state is LibraryUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  _isEditing ? 'Library updated' : 'Library created',
                ),
              ),
            );
            Navigator.pop(context, true);
          }
          if (state is LibraryError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Name
                _buildField(
                  controller: _nameCtrl,
                  label: 'Library Name *',
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Name is required' : null,
                ),
                const SizedBox(height: 14),

                // Contact
                _buildField(
                  controller: _contactCtrl,
                  label: 'Contact Number',
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 14),

                // Open Hours
                _buildField(
                  controller: _hoursCtrl,
                  label: 'Open Hours (e.g. Mon-Sat 9AM-8PM)',
                ),
                const SizedBox(height: 20),

                // Location header
                Row(
                  children: [
                    const Text(
                      'Location',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: _fetchingLocation ? null : _useCurrentLocation,
                      icon: _fetchingLocation
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child:
                                  CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.my_location, size: 18),
                      label: const Text('Use Current Location'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Street
                _buildField(controller: _streetCtrl, label: 'Street / Area'),
                const SizedBox(height: 14),

                // City + State
                Row(
                  children: [
                    Expanded(
                      child: _buildField(
                        controller: _cityCtrl,
                        label: 'City *',
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildField(
                        controller: _stateCtrl,
                        label: 'State *',
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Required' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Pincode
                _buildField(
                  controller: _pincodeCtrl,
                  label: 'Pincode',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 14),

                // Lat + Lng
                Row(
                  children: [
                    Expanded(
                      child: _buildField(
                        controller: _latCtrl,
                        label: 'Latitude',
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                          signed: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildField(
                        controller: _lngCtrl,
                        label: 'Longitude',
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                          signed: true,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Super Library toggle
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'Super Library',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  subtitle: const Text(
                    'Fallback library shown when no nearby options exist',
                    style: TextStyle(fontSize: 12),
                  ),
                  value: _isSuperLibrary,
                  activeTrackColor: Colors.amber,
                  onChanged: (v) => setState(() => _isSuperLibrary = v),
                ),
                const SizedBox(height: 24),

                // Submit
                BlocBuilder<LibraryBloc, LibraryState>(
                  builder: (context, state) {
                    final loading = state is LibraryLoading;
                    return FilledButton(
                      onPressed: loading ? null : _submit,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: loading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              _isEditing ? 'Update Library' : 'Create Library',
                              style: const TextStyle(fontSize: 16),
                            ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }
}
