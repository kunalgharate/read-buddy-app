import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:read_buddy_app/core/services/location_service.dart';
import 'package:read_buddy_app/core/theme/app_colors.dart';
import 'package:read_buddy_app/features/donate/presentation/bloc/donate_book_bloc.dart';
import 'package:read_buddy_app/features/library/domain/entities/library_entity.dart';

/// Widget to show nearby libraries for donation drop-off selection.
/// Replaces the old nearest_agents_widget.
class LibrarySelectorWidget extends StatefulWidget {
  final void Function(LibraryEntity library) onLibrarySelected;
  final LibraryEntity? selectedLibrary;

  const LibrarySelectorWidget({
    super.key,
    required this.onLibrarySelected,
    this.selectedLibrary,
  });

  @override
  State<LibrarySelectorWidget> createState() => _LibrarySelectorWidgetState();
}

class _LibrarySelectorWidgetState extends State<LibrarySelectorWidget> {
  List<_LibraryWithDistance> _sorted = [];

  @override
  void initState() {
    super.initState();
    context.read<DonateBookBloc>().add(LoadNearestLibraries());
  }

  Future<void> _sortByDistance(List<LibraryEntity> libraries) async {
    final position = await LocationService.instance.getCurrentLocation();
    if (position == null) {
      setState(() {
        _sorted = libraries
            .map((l) => _LibraryWithDistance(library: l, distanceKm: null))
            .toList();
      });
      return;
    }

    final sorted = libraries.map((lib) {
      final dist = LocationService.instance.calculateDistanceKm(
        position.latitude,
        position.longitude,
        lib.address.latitude,
        lib.address.longitude,
      );
      return _LibraryWithDistance(library: lib, distanceKm: dist);
    }).toList()
      ..sort((a, b) {
        if (a.distanceKm == null) return 1;
        if (b.distanceKm == null) return -1;
        return a.distanceKm!.compareTo(b.distanceKm!);
      });

    setState(() => _sorted = sorted);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DonateBookBloc, DonateBookState>(
      listener: (context, state) {
        if (state is NearestLibrariesLoaded) {
          _sortByDistance(state.libraries);
        }
      },
      builder: (context, state) {
        if (state is DonateBookLoading && _sorted.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (state is DonateBookError && _sorted.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(state.message),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => context
                      .read<DonateBookBloc>()
                      .add(LoadNearestLibraries()),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }
        if (_sorted.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: Text(
                'Select Drop-off Library',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _sorted.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final item = _sorted[index];
                final isSelected =
                    widget.selectedLibrary?.id == item.library.id;

                return _LibraryTile(
                  item: item,
                  isSelected: isSelected,
                  onTap: () => widget.onLibrarySelected(item.library),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

class _LibraryTile extends StatelessWidget {
  final _LibraryWithDistance item;
  final bool isSelected;
  final VoidCallback onTap;

  const _LibraryTile({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final lib = item.library;
    return InkWell(
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
            // Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: lib.isSuperLibrary
                    ? Colors.amber.withValues(alpha: 0.15)
                    : AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                lib.isSuperLibrary ? Icons.star : Icons.local_library,
                size: 20,
                color: lib.isSuperLibrary ? Colors.amber : AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lib.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    lib.address.fullAddress,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Distance
            if (item.distanceKm != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  LocationService.instance.formatDistance(item.distanceKm!),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            // Check mark
            if (isSelected) ...[
              const SizedBox(width: 8),
              const Icon(Icons.check_circle,
                  color: AppColors.primary, size: 22),
            ],
          ],
        ),
      ),
    );
  }
}

class _LibraryWithDistance {
  final LibraryEntity library;
  final double? distanceKm;

  const _LibraryWithDistance({required this.library, this.distanceKm});
}
