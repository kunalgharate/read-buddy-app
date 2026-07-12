import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:read_buddy_app/core/di/injection.dart';
import 'package:read_buddy_app/core/theme/app_colors.dart';
import '../bloc/librarian_bloc.dart';

class LibrarianDonationsPage extends StatelessWidget {
  const LibrarianDonationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<LibrarianBloc>()..add(LoadLibrarianDonations()),
      child: const _DonationsView(),
    );
  }
}

class _DonationsView extends StatelessWidget {
  const _DonationsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Donations')),
      body: BlocConsumer<LibrarianBloc, LibrarianState>(
        listener: (context, state) {
          if (state is LibrarianActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
            context.read<LibrarianBloc>().add(LoadLibrarianDonations());
          }
          if (state is LibrarianError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is LibrarianLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is LibrarianError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 12),
                  Text(state.message, textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => context
                        .read<LibrarianBloc>()
                        .add(LoadLibrarianDonations()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          if (state is LibrarianDonationsLoaded) {
            if (state.donations.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
                    SizedBox(height: 12),
                    Text('No donations yet',
                        style: TextStyle(color: Colors.grey, fontSize: 16)),
                  ],
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: () async {
                context.read<LibrarianBloc>().add(LoadLibrarianDonations());
              },
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: state.donations.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final donation = state.donations[index];
                  return _DonationCard(donation: donation);
                },
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _DonationCard extends StatelessWidget {
  final Map<String, dynamic> donation;
  const _DonationCard({required this.donation});

  @override
  Widget build(BuildContext context) {
    final status = (donation['status'] ?? 'pending').toString().toLowerCase();
    final donorName =
        donation['donorName'] ?? donation['donor']?['name'] ?? 'Unknown Donor';
    final bookTitle =
        donation['bookTitle'] ?? donation['book']?['title'] ?? 'Book Donation';
    final donationId = donation['_id'] ?? '';

    Color statusColor;
    switch (status) {
      case 'approved':
      case 'accepted':
      case 'received':
        statusColor = Colors.green;
        break;
      case 'rejected':
        statusColor = Colors.red;
        break;
      case 'in_transit':
      case 'scheduled':
        statusColor = Colors.blue;
        break;
      default:
        statusColor = Colors.orange;
    }

    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    bookTitle.toString(),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.person_outline, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(donorName.toString(),
                    style: const TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),
            if (status == 'pending') ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () {
                      context.read<LibrarianBloc>().add(
                          UpdateDonationStatusEvent(donationId, 'rejected'));
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    child: const Text('Reject'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      context.read<LibrarianBloc>().add(
                          UpdateDonationStatusEvent(donationId, 'approved'));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    child: const Text('Approve'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
