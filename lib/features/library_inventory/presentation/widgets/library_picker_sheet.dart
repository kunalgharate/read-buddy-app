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
        queryParameters: {'city': city},
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

      // Now fetch the actual inventory records to get variantId/formatId per library
      // We use the admin-like GET but the browse already gives us per-library breakdown
      // For the borrow we need: libraryId, variantId (from inventory), formatType
      // Let's query inventory per library
      final options = <_LibraryOption>[];
      for (final lib in cityBook.libraries) {
        if (lib.availableCopies > 0) {
          options.add(_LibraryOption(
            libraryId: lib.libraryId,
            libraryName: lib.libraryName,
            formatType: lib.formatType,
            availableCopies: lib.availableCopies,
            totalCopies: lib.totalCopies,
          ));
        }
      }

      // Also add out-of-stock libraries (disabled)
      for (final lib in cityBook.libraries) {
        if (lib.availableCopies <= 0) {
          options.add(_LibraryOption(
            libraryId: lib.libraryId,
            libraryName: lib.libraryName,
            formatType: lib.formatType,
            availableCopies: 0,
            totalCopies: lib.totalCopies,
          ));
        }
      }

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

  Future<void> _selectLibrary(_LibraryOption option) async {
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
            ..._options.map((opt) => _LibraryOptionTile(
                  option: opt,
                  onTap: opt.availableCopies > 0
                      ? () => _selectLibrary(opt)
                      : null,
                )),

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

  const _LibraryOption({
    required this.libraryId,
    required this.libraryName,
    required this.formatType,
    required this.availableCopies,
    required this.totalCopies,
  });
}

/// Result returned when the user picks a library to borrow from.
class LibraryPickResult {
  final String libraryId;
  final String libraryName;
  final String variantId;
  final String formatId;
  final String formatType;

  const LibraryPickResult({
    required this.libraryId,
    required this.libraryName,
    required this.variantId,
    required this.formatId,
    required this.formatType,
  });
}

// ── Tile widget ────────────────────────────────────────────────────────────────

class _LibraryOptionTile extends StatelessWidget {
  final _LibraryOption option;
  final VoidCallback? onTap;

  const _LibraryOptionTile({required this.option, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isAvailable = option.availableCopies > 0;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
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
          child: Row(
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
                    Text(
                      option.libraryName,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isAvailable
                            ? AppColors.textPrimaryColor(context)
                            : AppColors.textMutedColor(context),
                      ),
                    ),
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
              if (isAvailable)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Borrow',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                )
              else
                Text(
                  'Out of Stock',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.red.shade400,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
