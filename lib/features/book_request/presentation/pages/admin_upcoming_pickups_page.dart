import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../domain/entities/book_request_entity.dart';
import '../bloc/admin_upcoming_pickups_bloc.dart';

class AdminUpcomingPickupsPage extends StatelessWidget {
  const AdminUpcomingPickupsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<AdminUpcomingPickupsBloc>()..add(LoadUpcomingPickups()),
      child: const _AdminUpcomingPickupsView(),
    );
  }
}

class _AdminUpcomingPickupsView extends StatelessWidget {
  const _AdminUpcomingPickupsView();

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
        title: const Text(
          'Pickups',
          style: TextStyle(
            color: Color(0xFF052E44),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<AdminUpcomingPickupsBloc, AdminUpcomingPickupsState>(
        builder: (context, state) {
          if (state is UpcomingPickupsLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF2CE07F)),
            );
          }
          if (state is UpcomingPickupsEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_available_outlined,
                      size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  const Text(
                    'No upcoming pickups',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            );
          }
          if (state is UpcomingPickupsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline,
                      size: 48, color: Colors.grey),
                  const SizedBox(height: 12),
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context
                        .read<AdminUpcomingPickupsBloc>()
                        .add(LoadUpcomingPickups()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2CE07F),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Retry',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          }
          if (state is UpcomingPickupsLoaded) {
            return RefreshIndicator(
              color: const Color(0xFF2CE07F),
              onRefresh: () async {
                context
                    .read<AdminUpcomingPickupsBloc>()
                    .add(RefreshUpcomingPickups());
                // Wait a bit for the refresh to complete
                await Future.delayed(const Duration(milliseconds: 500));
              },
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                itemCount: state.pickups.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, i) =>
                    _PickupCard(pickup: state.pickups[i]),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

// ─── Pickup Card ───────────────────────────────────────────────────────────

class _PickupCard extends StatelessWidget {
  final BookRequestEntity pickup;

  const _PickupCard({required this.pickup});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Book cover
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: pickup.bookCoverUrl != null &&
                    pickup.bookCoverUrl!.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: pickup.bookCoverUrl!,
                    width: 80,
                    height: 110,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => _coverPlaceholder(),
                    errorWidget: (_, __, ___) => _coverPlaceholder(),
                  )
                : _coverPlaceholder(),
          ),
          const SizedBox(width: 12),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Book title + status chip
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        pickup.bookTitle ?? 'Unknown Book',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF052E44),
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _StatusChip(status: pickup.status),
                  ],
                ),
                if (pickup.donorName != null && pickup.donorName!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'by ${pickup.donorName}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF888888),
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                const Divider(height: 1, color: Color(0xFFE0E0E0)),
                const SizedBox(height: 8),

                // User name
                _InfoRow(
                  icon: Icons.person_outline,
                  text: pickup.pickupUserName ?? pickup.userId ?? '—',
                ),
                const SizedBox(height: 6),

                // Phone
                _InfoRow(
                  icon: Icons.phone_outlined,
                  text: pickup.pickupPhone ?? '—',
                ),
                const SizedBox(height: 6),

                // Address
                _InfoRow(
                  icon: Icons.location_on_outlined,
                  text: pickup.pickupAddress ?? '—',
                ),
                const SizedBox(height: 6),

                // Date
                _InfoRow(
                  icon: Icons.calendar_today_outlined,
                  text: _formatDate(pickup.pickupDate),
                ),
                const SizedBox(height: 6),

                // Time
                _InfoRow(
                  icon: Icons.access_time_outlined,
                  text: pickup.pickupTime ?? '—',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _coverPlaceholder() {
    return Container(
      width: 80,
      height: 110,
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.menu_book, size: 32, color: Colors.grey),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '—';
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
        'Dec'
      ];
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return dateStr;
    }
  }
}

// ─── Info Row ──────────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF888888)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 13, color: Color(0xFF555555)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// ─── Status Chip ───────────────────────────────────────────────────────────

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF2CE07F).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: const Color(0xFF2CE07F).withValues(alpha: 0.4),
        ),
      ),
      child: Text(
        _formatStatus(status),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Color(0xFF2CE07F),
        ),
      ),
    );
  }

  String _formatStatus(String s) {
    if (s.toLowerCase() == 'pickup_scheduled') return 'Pickup Scheduled';
    return s[0].toUpperCase() + s.substring(1);
  }
}
