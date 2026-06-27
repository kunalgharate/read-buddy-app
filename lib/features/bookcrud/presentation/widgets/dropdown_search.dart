import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';

class SearchableDD extends StatelessWidget {
  final String? hintText;
  final TextStyle? hintStyle;
  final String? label;
  final TextStyle? labelStyle;
  final String? selectedItem;
  final List<String> items;
  final Function(String?)? onChanged;
  final String? Function(String?)? validate;
  final bool? showSelectedItem;
  final bool? showClearButton;
  final TextEditingController? controller;

  const SearchableDD({
    super.key,
    this.hintText,
    this.hintStyle,
    this.controller,
    this.label,
    this.labelStyle,
    this.selectedItem,
    required this.items,
    this.onChanged,
    this.validate,
    this.showSelectedItem = true,
    this.showClearButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownSearch<String>(
      selectedItem: selectedItem,

      // asyncItems: (String? filter) async {
      //   if (filter == null || filter.isEmpty) return items;
      //   return items.where((item) => item.toLowerCase().contains(filter.toLowerCase())).toList();
      // },
      onChanged: onChanged,
      validator: validate,

      //clearButtonProps: ClearButtonProps(isVisible: showClearButton ?? false),
      itemAsString: (item) => item,
      dropdownBuilder: (context, String? selectedItem) {
        return Text(
          selectedItem ?? hintText ?? "Select item",
          style: selectedItem == null
              ? hintStyle ??
                  const TextStyle(color: Colors.black54, fontSize: 14)
              : const TextStyle(color: Colors.black87, fontSize: 16),
        );
      },

      /// ⬇️ Updated decorator
      decoratorProps: DropDownDecoratorProps(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: labelStyle ?? const TextStyle(fontSize: 16),
          hintText: hintText,
          hintStyle:
              hintStyle ?? const TextStyle(fontSize: 14, color: Colors.grey),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.grey),
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.blue),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),

      /// ⬇️ Updated popup
      popupProps: PopupProps.menu(
        fit: FlexFit.tight,
        showSelectedItems: showSelectedItem ?? true,
        showSearchBox: true,
        constraints: const BoxConstraints(maxHeight: 200),
        searchFieldProps: TextFieldProps(
          controller: controller,
          decoration: InputDecoration(
            hintText: hintText ?? "Search...",
            hintStyle: hintStyle ?? const TextStyle(fontSize: 12),
            contentPadding: const EdgeInsets.all(5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        // itemBuilder: (context, item, isSelected) {
        //   return SizedBox(
        //     height: 40,
        //     child: ListTile(
        //       contentPadding: const EdgeInsets.symmetric(horizontal: 10),
        //       title: Text(item, style: const TextStyle(fontSize: 14)),
        //     ),
        //   );
        // },
      ),
    );
  }
}
