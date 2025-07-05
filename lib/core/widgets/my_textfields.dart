//import 'package:common_ui/common_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:common_ui/src/blocs/theme_bloc/theme_bloc.dart';

class MyTextField extends StatelessWidget {
  final TextEditingController controller;
  final int? length;
  final String hintText;
  final bool? enable;
  final bool obscureText;
  final Pattern? type;
  final TextInputType keyboardType;
  final Widget? suffixIcon;
  final VoidCallback? onTap;
  final Widget? prefixIcon;
  final String? Function(String?)? validator;
  final FocusNode? focusNode;
  final String? errorMsg;
  final String? Function(String?)? onChanged;
  final bool isReadOnly;
  final bool isContentPadding;
  final int maxlines;
  final bool digitsOnly;

  const MyTextField(
      {super.key,
      required this.controller,
      required this.hintText,
      this.enable,
      required this.obscureText,
      required this.keyboardType,
      this.suffixIcon,
      this.length,
      this.onTap,
      this.type,
      this.prefixIcon,
      this.validator,
      this.focusNode,
      this.errorMsg,
      this.onChanged,
      this.isReadOnly = false,
      this.isContentPadding = true,
      this.maxlines = 1,
      this.digitsOnly = false});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      enabled: enable,
      validator: validator,
      controller: controller,
      maxLines: maxlines,
      obscureText: obscureText,
      keyboardType: keyboardType,
      focusNode: focusNode,
      inputFormatters: [
        if (digitsOnly) FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(length),
      ],
      style: Theme.of(context).textTheme.titleLarge,
      cursorColor: const Color.fromARGB(255, 70, 69, 71),
      // (ThemeBloc.systemIsDark) ? AppColors.lightAubergine30 : AppColors.darkAubergine90,
      onTap: onTap,
      textInputAction: TextInputAction.next,
      onChanged: onChanged,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      readOnly: isReadOnly,
      decoration: InputDecoration(
        suffixIcon: suffixIcon,
        prefixIcon: prefixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: const BorderSide(color: Colors.black54),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: const BorderSide(color: Colors.black54),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: const BorderSide(color: Colors.black26),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: const BorderSide(color: Colors.grey
              //color: Theme.of(context).colorScheme.primary, width: 2
              ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: const BorderSide(color: Colors.red),
        ),
        hintText: hintText,
        hintStyle: const TextStyle(
            fontSize: 16,
            color: Colors
                .black26), //Theme.of(context).inputDecorationTheme.hintStyle,
        errorText: errorMsg,
        contentPadding: isContentPadding
            ? const EdgeInsets.symmetric(vertical: 5, horizontal: 5)
            : null,
      ),
    );
  }
}
