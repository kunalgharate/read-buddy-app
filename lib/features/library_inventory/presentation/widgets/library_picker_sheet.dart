import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:read_buddy_app/core/di/injection.dart';
import 'package:read_buddy_app/core/network/api_constants.dart';
import 'package:read_buddy_app/core/services/city_notifier.dart';
import 'package:read_buddy_app/core/theme/app_colors.dart';
import '../../data/models/library_inventory_model.dart';

/// A bottom sheet that shows which libraries in the user's city have a
/// specific book available, and lets the user pick one.
///
/// Returns a [LibraryPickResult] with the selected library's info, or
/// null if the user dismissed without selecting.
///
/// Usage:
/// ```dart
/// final result = await LibraryPickerSheet.show(
///   context,
///   bookId: '...',
///   bookTitle: 'The Alchemist',
/// );
/// if (result != null) {
///   // Proceed with borrow using result.libraryId, result.variantId, result.formatId
/// }
/// ```
class LibraryPickerSheet extends StatefulWidget {
  final String bookId;
  final String bookTitle;

  const LibraryPickerSheet({
    super.key,
    required this.bookId,
    required this.bookTitle,
  });

  /// Show the picker and return selected library info, or null if dismissed.
  static Future<LibraryPickResult?> show(
    BuildContext context, {
    required String bookId,
    required String bookTitle,
  }) {
    return showModalBottomSheet<LibraryPickResult>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => LibraryPickerSheet(
        bookId: bookId,
        bookTitle: bookTitle,
      ),
    );
  }

  @override
  State<LibraryPickerSheet> createState() => _LibraryPickerSheetState();
}

class _LibraryPickerSheetState extends State<LibraryPickerSheet> {
  bool _loading = true;
  String? _error;
  // We also need variantId and formatId for the selected library
  // The browse API groups by bookId — we need per-library detail
  List<_LibraryOption> _options = [];

  @override
  void initState() {
    super.initState();
    _loadAvailability();
  }

  Future<void> _loadAvailability() async {
    final city = CityNotifier.instance.value;
    if (city == null || city.isEmpty) {
      setState(() {
        _loading = false;
        _error = 'Please select your city first.';
      });
      return;
    }

    try {
      final dio = getIt<Dio>();
      final response = await dio.get(
        ApiConstants.libraryInventoryBrowse,
        queryParameters: {
          'city': city,
          if (CityNotifier.instance.latitude != null)
            'lat': CityNotifier.instance.latitude,
          if (CityNotifier.instance.longitude != null)
            'lng': CityNotifier.instance.longitude,
        },
      );
      final data = response.data;
      final books = (data['books'] as List<dynamic>?) ?? [];

      // Find the specific book in results
      final bookData = books.firstWhere(
        (b) => b['bookId']?.toString() == widget.bookId,
        orElse: () => null,
      );

      if (bookData == null) {
        setState(() {
          _loading = false;
          _error = 'This book is not available in any library in $city.';
        });
        return;
      }

      final cityBook = CityBookModel.fromJson(
        bookData as Map<String, dynamic>,
      );

      // Build options from the per-library breakdown (already distance-sorted
      // and coordinate-filtered by the backend when user coords were sent).
      final options = <_LibraryOption>[];
      for (final lib in cityBook.libraries) {
        options.add(
          _LibraryOption(
            libraryId: lib.libraryId,
            libraryName: lib.libraryName,
            formatType: lib.formatType,
            availableCopies: lib.availableCopies,
            totalCopies: lib.totalCopies,
            distanceKm: lib.distanceKm,
            pickupEligible: lib.pickupEligible,
          ),
        );
      }

      // Nearest, in-stock libraries first; out-of-stock sink to the bottom.
      options.sort((a, b) {
        if ((a.availableCopies > 0) != (b.availableCopies > 0)) {
          return a.availableCopies > 0 ? -1 : 1;
        }
        if (a.distanceKm == null && b.distanceKm == null) return 0;
        if (a.distanceKm == null) return 1;
        if (b.distanceKm == null) return -1;
        return a.distanceKm!.compareTo(b.distanceKm!);
      });

      setState(() {
        _options = options;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = 'Failed to load library availability.';
      });
    }
  }

  Future<void> _selectLibrary(
    _LibraryOption option,
    String fulfillmentMethod,
  ) async {
    // We need variantId and formatId. Fetch inventory record for this library+book.
    try {
      final dio = getIt<Dio>();
      final response = await dio.get(
        ApiConstants.libraryInventory,
        queryParameters: {'libraryId': option.libraryId},
      );
      final data = response.data;
      final inventory = (data['inventory'] as List?) ?? [];

      // Find the inventory record matching this book and format
      final record = inventory.firstWhere(
        (inv) {
          final bookId = inv['bookId'] is Map
              ? inv['bookId']['_id']?.toString()
              : inv['bookId']?.toString();
          return bookId == widget.bookId &&
              inv['formatType'] == option.formatType;
        },
        orElse: () => null,
      );

      if (record == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not find inventory details.')),
          );
        }
        return;
      }

      final variantId = record['variantId'] is Map
          ? record['variantId']['_id']?.toString() ?? ''
          : record['variantId']?.toString() ?? '';

      // We need formatId from BookVariant.formats[] — look it up
      final variantResponse = await dio.get(
        '${ApiConstants.bookVariants}/book/${widget.bookId}',
      );
      final variantData = variantResponse.data;
      final variants =
          variantData['variants'] ?? variantData['data'] ?? variantData;
      String? formatId;
      if (variants is List) {
        for (final v in variants) {
          if ((v['_id'] ?? v['id'])?.toString() == variantId) {
            final formats = v['formats'] as List? ?? [];
            for (final f in formats) {
              if (f['type'] == option.formatType) {
                formatId = (f['_id'] ?? f['id'])?.toString();
                break;
              }
            }
            break;
          }
        }
      }

      if (formatId == null || variantId.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not resolve format details.')),
          );
        }
        return;
      }

      if (mounted) {
        Navigator.pop(
          context,
          LibraryPickResult(
            libraryId: option.libraryId,
            libraryName: option.libraryName,
            variantId: variantId,
            formatId: formatId,
            formatType: option.formatType,
            fulfillmentMethod: fulfillmentMethod,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          Text(
            'Borrow from',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimaryColor(context),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.bookTitle,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondaryColor(context),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),

          if (_loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else if (_error != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(
                  _error!,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondaryColor(context),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else if (_options.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(
                  'No libraries have this book in your city.',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondaryColor(context),
                  ),
                ),
              ),
            )
          else
            ..._options.map(
              (opt) => _LibraryOptionTile(
                option: opt,
                onPickup: opt.availableCopies > 0 && opt.pickupEligible
                    ? () => _selectLibrary(opt, 'PICKUP')
                    : null,
                onDelivery: opt.availableCopies > 0
                    ? () => _selectLibrary(opt, 'DELIVERY')
                    : null,
              ),
            ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ── Data classes ────────────────────────────────────────────────────────────────

class _LibraryOption {
  final String libraryId;
  final String libraryName;
  final String formatType;
  final int availableCopies;
  final int totalCopies;
  final double? distanceKm;
  final bool pickupEligible;

  const _LibraryOption({
    required this.libraryId,
    required this.libraryName,
    required this.formatType,
    required this.availableCopies,
    required this.totalCopies,
    this.distanceKm,
    this.pickupEligible = false,
  });
}

/// Result returned when the user picks a library to borrow from.
class LibraryPickResult {
  final String libraryId;
  final String libraryName;
  final String variantId;
  final String formatId;
  final String formatType;

  /// 'DELIVERY' or 'PICKUP' — how the user wants to receive the book.
  final String fulfillmentMethod;

  const LibraryPickResult({
    required this.libraryId,
    required this.libraryName,
    required this.variantId,
    required this.formatId,
    required this.formatType,
    this.fulfillmentMethod = 'DELIVERY',
  });
}

// ── Tile widget ────────────────────────────────────────────────────────────────

class _LibraryOptionTile extends StatelessWidget {
  final _LibraryOption option;
  final VoidCallback? onPickup;
  final VoidCallback? onDelivery;

  const _LibraryOptionTile({
    required this.option,
    this.onPickup,
    this.onDelivery,
  });

  String _distanceLabel(double km) {
    if (km < 1.0) return '${(km * 1000).round()} m away';
    return '${km.toStringAsFixed(1)} km away';
  }

  @override
  Widget build(BuildContext context) {
    final isAvailable = option.availableCopies > 0;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isAvailable
                ? AppColors.primary.withValues(alpha: 0.3)
                : Colors.grey.shade200,
          ),
          color: isAvailable ? null : Colors.grey.shade50,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.local_library,
                  size: 20,
                  color: isAvailable ? AppColors.primary : Colors.grey,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              option.libraryName,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isAvailable
                                    ? AppColors.textPrimaryColor(context)
                                    : AppColors.textMutedColor(context),
                              ),
                            ),
                          ),
                          if (option.distanceKm != null)
                            Text(
                              _distanceLabel(option.distanceKm!),
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${option.formatType} • ${option.availableCopies} of ${option.totalCopies} available',
                        style: TextStyle(
                          fontSize: 11,
                          color: isAvailable
                              ? AppColors.textSecondaryColor(context)
                              : AppColors.textMutedColor(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (isAvailable) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  // Pickup — only within the pickup radius.
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onPickup,
                      icon: const Icon(Icons.store_mall_directory, size: 16),
                      label: const Text('Pickup'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        foregroundColor: onPickup != null
                            ? AppColors.primary
                            : AppColors.textMutedColor(context),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Delivery — available anywhere in the city (courier).
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: onDelivery,
                      icon: const Icon(Icons.local_shipping, size: 16),
                      label: const Text('Delivery'),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                ],
              ),
              if (onPickup == null && option.distanceKm != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    'Pickup unavailable — too far. Delivery only.',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.textMutedColor(context),
                    ),
                  ),
                ),
            ] else
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Out of Stock',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.red.shade400,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
