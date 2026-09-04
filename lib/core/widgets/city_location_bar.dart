import 'package:flutter/material.dart';
import 'package:read_buddy_app/core/services/city_notifier.dart';
import 'package:read_buddy_app/core/theme/app_colors.dart';

/// Zomato-style location bar showing the current city.
/// Tapping opens a bottom sheet with:
///   - "Detect current location" (GPS)
///   - Recent locations
///   - Search field for typing a city
///
/// Place this at the top of the home page, above all content.
class CityLocationBar extends StatelessWidget {
  /// Called when the city changes (so parent can reload data).
  final ValueChanged<String>? onCityChanged;

  const CityLocationBar({super.key, this.onCityChanged});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: CityNotifier.instance,
      builder: (context, city, _) {
        return GestureDetector(
          onTap: () => _openCityPicker(context),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.cardColor(context),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderColor(context)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.location_on, size: 20, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        city ?? 'Select your city',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimaryColor(context),
                        ),
                      ),
                      if (city != null)
                        Text(
                          'Showing books available near you',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.textMutedColor(context),
                          ),
                        ),
                    ],
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppColors.textMutedColor(context),
                  size: 22,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openCityPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: AppColors.cardColor(context),
      builder: (_) => _CityPickerSheet(onCityChanged: onCityChanged),
    );
  }
}

// ─────────────────────────────────────────────
// City Picker Bottom Sheet
// ─────────────────────────────────────────────

class _CityPickerSheet extends StatefulWidget {
  final ValueChanged<String>? onCityChanged;
  const _CityPickerSheet({this.onCityChanged});

  @override
  State<_CityPickerSheet> createState() => _CityPickerSheetState();
}

class _CityPickerSheetState extends State<_CityPickerSheet> {
  final _searchCtrl = TextEditingController();
  bool _detecting = false;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _detectGPS() async {
    setState(() => _detecting = true);
    final city = await CityNotifier.instance.detectFromGPS();
    if (!mounted) return;
    setState(() => _detecting = false);
    if (city != null) {
      widget.onCityChanged?.call(city);
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not detect location. Please enable GPS or type your city.'),
        ),
      );
    }
  }

  void _selectCity(String city) {
    CityNotifier.instance.setCity(city);
    widget.onCityChanged?.call(city);
    Navigator.pop(context);
  }

  void _submitSearch() {
    final text = _searchCtrl.text.trim();
    if (text.isNotEmpty) {
      _selectCity(text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final recents = CityNotifier.instance.recentCities;

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

          // Title
          Text(
            'Choose your city',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimaryColor(context),
            ),
          ),
          const SizedBox(height: 16),

          // GPS Detect
          InkWell(
            onTap: _detecting ? null : _detectGPS,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.my_location,
                    size: 20,
                    color: _detecting ? Colors.grey : AppColors.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Detect current location',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _detecting
                                ? AppColors.textHint
                                : AppColors.primary,
                          ),
                        ),
                        Text(
                          'Using GPS',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textMutedColor(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_detecting)
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                ],
              ),
            ),
          ),

          // Recent Locations
          if (recents.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text(
              'Recent Locations',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondaryColor(context),
              ),
            ),
            const SizedBox(height: 8),
            ...recents.map(
              (city) => ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  Icons.history,
                  size: 18,
                  color: AppColors.textMutedColor(context),
                ),
                title: Text(
                  city,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimaryColor(context),
                  ),
                ),
                onTap: () => _selectCity(city),
              ),
            ),
          ],

          // Search / Type city
          const SizedBox(height: 20),
          Text(
            'Or type your city',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondaryColor(context),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchCtrl,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    hintText: 'e.g. Pune, Mumbai, Nashik...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    isDense: true,
                  ),
                  onSubmitted: (_) => _submitSearch(),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: _submitSearch,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                child: const Text('Go'),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
