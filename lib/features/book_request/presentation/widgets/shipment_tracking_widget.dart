import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:read_buddy_app/core/di/injection.dart';
import 'package:read_buddy_app/core/network/api_constants.dart';
import 'package:read_buddy_app/core/theme/app_colors.dart';

/// Lightweight widget that fetches and displays shipment tracking info
/// for a given book request. Shows nothing if no shipment exists (404).
class ShipmentTrackingWidget extends StatefulWidget {
  final String requestId;

  const ShipmentTrackingWidget({super.key, required this.requestId});

  @override
  State<ShipmentTrackingWidget> createState() => _ShipmentTrackingWidgetState();
}

class _ShipmentTrackingWidgetState extends State<ShipmentTrackingWidget> {
  late final Future<Map<String, dynamic>?> _shipmentFuture;

  @override
  void initState() {
    super.initState();
    _shipmentFuture = _fetchShipment();
  }

  Future<Map<String, dynamic>?> _fetchShipment() async {
    try {
      final response = await getIt<Dio>().get(
        ApiConstants.shipmentByRequest(widget.requestId),
      );
      if (response.statusCode == 200 && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _shipmentFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              ),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return const SizedBox.shrink();
        }

        final shipment = snapshot.data!;
        return _buildShipmentCard(context, shipment);
      },
    );
  }

  Widget _buildShipmentCard(
    BuildContext context,
    Map<String, dynamic> shipment,
  ) {
    final carrier = shipment['carrier'] as String? ?? 'Unknown';
    final trackingNumber = shipment['trackingNumber'] as String? ?? '—';
    final status = shipment['status'] as String? ?? 'unknown';
    final estimatedDelivery = shipment['estimatedDelivery'] as String?;
    final receiptImageUrl = shipment['receiptImageUrl'] as String?;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text(
          'Shipment Tracking',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF052E44),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Carrier
              _ShipmentInfoRow(label: 'Carrier', value: carrier),
              const SizedBox(height: 8),

              // Tracking number (copyable)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    width: 120,
                    child: Text(
                      'Tracking #',
                      style: TextStyle(fontSize: 12, color: Color(0xFF888888)),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: trackingNumber));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Tracking number copied'),
                            duration: Duration(seconds: 2),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(
                              trackingNumber,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF052E44),
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.copy,
                            size: 14,
                            color: Color(0xFF888888),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Status badge
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 120,
                    child: Text(
                      'Status',
                      style: TextStyle(fontSize: 12, color: Color(0xFF888888)),
                    ),
                  ),
                  _StatusBadge(status: status),
                ],
              ),

              // Estimated delivery
              if (estimatedDelivery != null &&
                  estimatedDelivery.isNotEmpty) ...[
                const SizedBox(height: 8),
                _ShipmentInfoRow(
                  label: 'Est. Delivery',
                  value: _formatDate(estimatedDelivery),
                ),
              ],

              // Receipt image
              if (receiptImageUrl != null && receiptImageUrl.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Text(
                  'Receipt',
                  style: TextStyle(fontSize: 12, color: Color(0xFF888888)),
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: receiptImageUrl,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      height: 120,
                      color: const Color(0xFFF0F0F0),
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      height: 120,
                      color: const Color(0xFFF0F0F0),
                      child: const Center(
                        child: Icon(Icons.broken_image, color: Colors.grey),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  String _formatDate(String dateStr) {
    try {
      final dt = DateTime.parse(dateStr);
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return dateStr;
    }
  }
}

class _ShipmentInfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _ShipmentInfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: const TextStyle(fontSize: 12, color: Color(0xFF888888)),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF052E44),
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status.toLowerCase()) {
      case 'delivered':
        color = const Color(0xFF4CAF50);
      case 'in_transit':
      case 'shipping':
        color = const Color(0xFF2196F3);
      case 'out_for_delivery':
        color = const Color(0xFF009688);
      case 'returned':
        color = const Color(0xFF9C27B0);
      default:
        color = const Color(0xFFFF9800);
    }

    final label = status.replaceAll('_', ' ');
    final displayLabel =
        label.isNotEmpty ? label[0].toUpperCase() + label.substring(1) : status;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        displayLabel,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
