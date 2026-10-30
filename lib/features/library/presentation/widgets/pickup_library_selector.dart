import 'package:flutter/material.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/library_entity.dart';
import '../../domain/usecases/library_usecases.dart';

// ΓöÇΓöÇΓöÇ Pickup Library Selector ΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇΓöÇ

/// Fetches libraries and shows only those within 15 km of the user's current
/// location, nearest first, and auto-selects the nearest one. Degrades
/// gracefully when the location is unavailable (shows the list unsorted with a
/// hint) and shows a clear empty message when none are within 15 km.
///
/// [fallbackSentence] is appended to the empty-state messages so each flow can
/// point at its own alternative (the Borrow Cart suggests Delivery, the return
/// drop-off flow suggests home Pick Up).
class PickupLibrarySelector extends StatefulWidget {
  final LibraryEntity? selectedLibrary;
  final ValueChanged<LibraryEntity?> onSelected;
  final String fallbackSentence;

  const PickupLibrarySelector({
    super.key,
    required this.selectedLibrary,
    required this.onSelected,
    this.fallbackSentence = 'Try Delivery instead.',
  });

  @override
  State<PickupLibrarySelector> createState() => _PickupLibrarySelectorState();
}

class _PickupLibrarySelectorState extends State<PickupLibrarySelector> {
  static const double _radiusKm = 15.0;

  bool _loading = true;
  String? _error;
  bool _locationUnavailable = false;
  bool _hadLibraries = false;
  List<_LibraryWithDistance> _libraries = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  // The location-unavailable message reads mid-sentence ("ΓÇªor try Delivery
  // instead."), so its first letter is lowercased to keep both usages natural.
  String get _fallbackSentenceMidSentence {
    final s = widget.fallbackSentence;
    if (s.isEmpty) return s;
    return s[0].toLowerCase() + s.substring(1);
  }

  // Reconciles the parent's selection against the current list. Keep the
  // current selection if it's still offered. Otherwise auto-select only the
  // nearest IN-RANGE (known-distance) library ΓÇö never a coord-less fallback,
  // which could be far / in another city and must be an explicit user choice.
  void _reconcileSelection(List<_LibraryWithDistance> items) {
    final currentId = widget.selectedLibrary?.id;
    final stillValid =
        currentId != null && items.any((l) => l.library.id == currentId);
    if (stillValid) return;
    final firstInRange = items.where((l) => l.distanceKm != null);
    if (firstInRange.isNotEmpty) {
      widget.onSelected(firstInRange.first.library);
    } else {
      widget.onSelected(null);
    }
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
      _locationUnavailable = false;
    });
    try {
      final all = await getIt<GetLibraryDetails>()();
      if (!mounted) return;
      final position = await LocationService.instance.getCurrentLocation();
      if (!mounted) return;

      if (position == null) {
        // Graceful degradation: no location -> show all (no distance), let the
        // user pick manually. Do NOT auto-select.
        final listed = all
            .map((l) => _LibraryWithDistance(library: l, distanceKm: null))
            .toList();
        _reconcileSelection(listed);
        setState(() {
          _locationUnavailable = true;
          _hadLibraries = all.isNotEmpty;
          _libraries = listed;
          _loading = false;
        });
        return;
      }

      final within = <_LibraryWithDistance>[];
      final noCoords = <_LibraryWithDistance>[];
      for (final lib in all) {
        final lat = lib.address.latitude;
        final lng = lib.address.longitude;
        // Either coordinate absent/zero => coord-less (a partial pair can't be
        // distance-filtered reliably, so keep it as a fallback, don't hide it).
        if (lat == 0 || lng == 0) {
          noCoords.add(_LibraryWithDistance(library: lib, distanceKm: null));
          continue;
        }
        final km = LocationService.instance.calculateDistanceKm(
          position.latitude,
          position.longitude,
          lat,
          lng,
        );
        if (km <= _radiusKm) {
          within.add(_LibraryWithDistance(library: lib, distanceKm: km));
        }
      }
      within.sort((a, b) => a.distanceKm!.compareTo(b.distanceKm!));
      // In-range (nearest first) then coord-less fallbacks.
      final visible = [...within, ...noCoords];

      _reconcileSelection(visible);

      setState(() {
        _hadLibraries = all.isNotEmpty;
        _libraries = visible;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      widget.onSelected(null);
      setState(() {
        _error = 'Could not load libraries. Please try again.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (_error != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_error!, style: const TextStyle(color: AppColors.error)),
          const SizedBox(height: 8),
          TextButton(onPressed: _load, child: const Text('Retry')),
        ],
      );
    }

    if (_libraries.isEmpty) {
      // Distinguish the three empty cases so the message is accurate.
      final String message;
      if (_locationUnavailable) {
        message = 'Location unavailable ΓÇö enable location to find nearby '
            'libraries, or $_fallbackSentenceMidSentence';
      } else if (_hadLibraries) {
        message = 'No libraries within 15 km of your location. '
            '${widget.fallbackSentence}';
      } else {
        message = 'No libraries are available right now. '
            '${widget.fallbackSentence}';
      }
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.orange.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.location_off, color: Colors.orange, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Pickup Library',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        if (_locationUnavailable) ...[
          const SizedBox(height: 6),
          const Text(
            'Location unavailable ΓÇö showing all libraries. '
            'Enable location to see the nearest ones.',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ],
        const SizedBox(height: 10),
        ..._libraries.map((item) {
          final isSelected = widget.selectedLibrary?.id == item.library.id;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: GestureDetector(
              onTap: () => widget.onSelected(item.library),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color:
                        isSelected ? AppColors.primary : Colors.grey.shade300,
                    width: isSelected ? 2 : 1,
                  ),
                  color: isSelected
                      ? AppColors.primary.withValues(alpha: 0.05)
                      : Colors.white,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: item.library.isSuperLibrary
                            ? Colors.amber.withValues(alpha: 0.15)
                            : AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        item.library.isSuperLibrary
                            ? Icons.star
                            : Icons.local_library,
                        size: 20,
                        color: item.library.isSuperLibrary
                            ? Colors.amber
                            : AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.library.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.library.address.fullAddress,
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
                    if (item.distanceKm != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          LocationService.instance
                              .formatDistance(item.distanceKm!),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    if (isSelected) ...[
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.check_circle,
                        color: AppColors.primary,
                        size: 22,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _LibraryWithDistance {
  final LibraryEntity library;
  final double? distanceKm;

  const _LibraryWithDistance({required this.library, this.distanceKm});
}
