import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/shipment_entity.dart';
import '../bloc/tracking_bloc.dart';

class TrackingPage extends StatelessWidget {
  final String requestId;

  const TrackingPage({super.key, required this.requestId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shipment Tracking'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<TrackingBloc>().add(RefreshShipment(requestId));
            },
          ),
        ],
      ),
      body: BlocConsumer<TrackingBloc, TrackingState>(
        listener: (context, state) {
          if (state is TrackingRefreshError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Refresh failed: ${state.message}')),
            );
          }
        },
        builder: (context, state) {
          if (state is TrackingLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is TrackingError) {
            return _buildErrorState(context, state.message);
          }

          if (state is TrackingLoaded) {
            return _buildTrackingContent(context, state.shipment);
          }

          // Keep showing the last-good shipment behind a transient refresh error
          if (state is TrackingRefreshError) {
            return _buildTrackingContent(context, state.shipment);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context
                    .read<TrackingBloc>()
                    .add(LoadShipmentByRequest(requestId));
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackingContent(BuildContext context, ShipmentEntity shipment) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildShipmentInfoCard(context, shipment),
          const SizedBox(height: 24),
          _buildStatusTimeline(context, shipment.status),
          if (shipment.receiptImageUrl != null) ...[
            const SizedBox(height: 24),
            _buildReceiptSection(context, shipment.receiptImageUrl!),
          ],
        ],
      ),
    );
  }

  Widget _buildShipmentInfoCard(BuildContext context, ShipmentEntity shipment) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Shipment Details',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const Divider(height: 24),
            _buildInfoRow(
              context,
              icon: Icons.local_shipping_outlined,
              label: 'Tracking ID',
              value: shipment.trackingId,
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              context,
              icon: Icons.business_outlined,
              label: 'Courier',
              value: shipment.courier,
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              context,
              icon: Icons.info_outline,
              label: 'Status',
              value: _formatStatus(shipment.status),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusTimeline(BuildContext context, String currentStatus) {
    const steps = ['ordered', 'shipped', 'in_transit', 'delivered'];
    // Map common backend aliases to the canonical timeline steps.
    final normalized = _normalizeStatus(currentStatus);
    final rawIndex = steps.indexOf(normalized);
    // If the status is unknown, default to the first step so the timeline
    // still renders sensibly (with the current status shown separately above).
    final currentIndex = rawIndex >= 0 ? rawIndex : 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tracking Timeline',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            if (rawIndex < 0) ...[
              const SizedBox(height: 8),
              Text(
                'Current status: ${_formatStatus(currentStatus)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
            const SizedBox(height: 16),
            ...List.generate(steps.length, (index) {
              final isCompleted = rawIndex >= 0 && index <= currentIndex;
              final isCurrent = rawIndex >= 0 && index == currentIndex;
              final isLast = index == steps.length - 1;

              return _buildTimelineStep(
                context,
                label: _formatStatus(steps[index]),
                icon: _getStepIcon(steps[index]),
                isCompleted: isCompleted,
                isCurrent: isCurrent,
                isLast: isLast,
              );
            }),
          ],
        ),
      ),
    );
  }

  /// Maps known backend status aliases to canonical timeline step names.
  String _normalizeStatus(String status) {
    final s = status.toLowerCase().trim();
    switch (s) {
      case 'pending':
      case 'created':
      case 'confirmed':
        return 'ordered';
      case 'dispatched':
      case 'out_for_delivery':
        return 'shipped';
      case 'intransit':
      case 'in-transit':
        return 'in_transit';
      case 'completed':
      case 'received':
        return 'delivered';
      default:
        return s;
    }
  }

  Widget _buildTimelineStep(
    BuildContext context, {
    required String label,
    required IconData icon,
    required bool isCompleted,
    required bool isCurrent,
    required bool isLast,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final activeColor = colorScheme.primary;
    final inactiveColor = colorScheme.outlineVariant;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 40,
            child: Column(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted ? activeColor : colorScheme.surface,
                    border: Border.all(
                      color: isCompleted ? activeColor : inactiveColor,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    icon,
                    size: 16,
                    color: isCompleted ? colorScheme.onPrimary : inactiveColor,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      constraints: const BoxConstraints(minHeight: 32),
                      color: isCompleted && !isCurrent
                          ? activeColor
                          : inactiveColor,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 24),
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight:
                          isCurrent ? FontWeight.bold : FontWeight.normal,
                      color: isCompleted
                          ? colorScheme.onSurface
                          : colorScheme.onSurfaceVariant,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptSection(BuildContext context, String imageUrl) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Receipt',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imageUrl,
                width: double.infinity,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const SizedBox(
                    height: 200,
                    child: Center(child: CircularProgressIndicator()),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.broken_image_outlined,
                          size: 48,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Unable to load receipt image',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatStatus(String status) {
    switch (status.toLowerCase()) {
      case 'ordered':
        return 'Ordered';
      case 'shipped':
        return 'Shipped';
      case 'in_transit':
        return 'In Transit';
      case 'delivered':
        return 'Delivered';
      default:
        return status.replaceAll('_', ' ').split(' ').map((word) {
          if (word.isEmpty) return word;
          return word[0].toUpperCase() + word.substring(1);
        }).join(' ');
    }
  }

  IconData _getStepIcon(String status) {
    switch (status.toLowerCase()) {
      case 'ordered':
        return Icons.receipt_long_outlined;
      case 'shipped':
        return Icons.inventory_2_outlined;
      case 'in_transit':
        return Icons.local_shipping_outlined;
      case 'delivered':
        return Icons.check_circle_outline;
      default:
        return Icons.circle_outlined;
    }
  }
}
