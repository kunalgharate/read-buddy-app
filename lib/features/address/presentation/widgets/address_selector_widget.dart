import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:read_buddy_app/core/di/injection.dart';
import 'package:read_buddy_app/core/theme/app_colors.dart';
import '../bloc/address_bloc.dart';
import '../../domain/entities/address_entity.dart';

/// Widget for selecting a delivery address during book request.
/// Shows the user's saved addresses with the default highlighted.
class AddressSelectorWidget extends StatelessWidget {
  final void Function(AddressEntity address) onAddressSelected;
  final AddressEntity? selectedAddress;

  const AddressSelectorWidget({
    super.key,
    required this.onAddressSelected,
    this.selectedAddress,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AddressBloc>()..add(LoadAddresses()),
      child: _AddressSelectorView(
        onAddressSelected: onAddressSelected,
        selectedAddress: selectedAddress,
      ),
    );
  }
}

class _AddressSelectorView extends StatelessWidget {
  final void Function(AddressEntity address) onAddressSelected;
  final AddressEntity? selectedAddress;

  const _AddressSelectorView({
    required this.onAddressSelected,
    this.selectedAddress,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AddressBloc, AddressState>(
      builder: (context, state) {
        if (state is AddressLoading) {
          return const Padding(
            padding: EdgeInsets.all(20),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        }
        if (state is AddressError) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Text(state.message),
          );
        }
        if (state is AddressesLoaded) {
          if (state.addresses.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text('No saved addresses'),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () =>
                        Navigator.pushNamed(context, '/addresses'),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Address'),
                  ),
                ],
              ),
            );
          }

          // Auto-select default if nothing selected
          if (selectedAddress == null) {
            final defaultAddr = state.addresses
                .where((a) => a.isDefault)
                .firstOrNull;
            if (defaultAddr != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                onAddressSelected(defaultAddr);
              });
            }
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'Delivery Address',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, '/addresses'),
                    child: const Text('Manage'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...state.addresses.map((addr) {
                final isSelected = selectedAddress?.id == addr.id;
                return _AddressTile(
                  address: addr,
                  isSelected: isSelected,
                  onTap: () => onAddressSelected(addr),
                );
              }),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _AddressTile extends StatelessWidget {
  final AddressEntity address;
  final bool isSelected;
  final VoidCallback onTap;

  const _AddressTile({
    required this.address,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: isSelected ? 2 : 1,
            ),
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.05)
                : Colors.white,
          ),
          child: Row(
            children: [
              Icon(
                address.label.toLowerCase() == 'work'
                    ? Icons.work_outline
                    : Icons.home_outlined,
                color: isSelected ? AppColors.primary : AppColors.textHint,
                size: 20,
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
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textPrimary,
                          ),
                        ),
                        if (address.isDefault) ...[
                          const SizedBox(width: 6),
                          const Text(
                            '• Default',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ],
                    ),
                    Text(
                      '${address.name}, ${address.phone}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      address.fullAddress,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textHint,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (isSelected)
                const Icon(Icons.check_circle, color: AppColors.primary, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}
