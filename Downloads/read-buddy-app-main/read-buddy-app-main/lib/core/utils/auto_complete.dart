import 'package:flutter/material.dart';

class GenericAutocomplete<T extends Object> extends StatelessWidget {
  final List<T> options;
  final TextEditingController controller;

  final String Function(T) displayString;
  final void Function(T) onSelected;
  final String? Function(String?)? validator;
  final String hintText;

  const GenericAutocomplete({
    super.key,
    required this.options,
    required this.controller,
    required this.displayString,
    required this.onSelected,
    this.validator,
    this.hintText = 'Search',
  });

  @override
  Widget build(BuildContext context) {
    return Autocomplete<T>(
      // ✅ Set initial value from external controller
      initialValue: TextEditingValue(text: controller.text),
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return Iterable<T>.empty(); // ✅ no const
        }
        return options.where((T item) {
          return displayString(item)
              .toLowerCase()
              .contains(textEditingValue.text.toLowerCase());
        });
      },
      displayStringForOption: displayString,
      fieldViewBuilder:
          (context, textEditingController, focusNode, onFieldSubmitted) {
        controller.value = textEditingController.value;
        return TextFormField(
          controller: textEditingController,
          focusNode: focusNode,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
            hintText: hintText,
          ),
          validator: validator,
        );
      },
      onSelected: (T item) {
        controller.text = displayString(item);
        onSelected(item);
      },
    );
  }
}
