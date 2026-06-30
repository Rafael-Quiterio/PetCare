import 'package:animalapp/UI/styled_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EditableField extends StatelessWidget {
  const EditableField({
    super.key,
    required this.isEnabled,
    required this.controller,
    required this.displayValue,
    required this.label,
    this.icon,
    this.keyboardType,
    this.inputFormatters,
  });

  final bool isEnabled; //To make sure if it's in view or edit mode
  final TextEditingController controller;
  final String displayValue; //This is what will show when the view is not in edit mode
  final String label;
  final IconData? icon;
  final TextInputType? keyboardType; //This is optional so it won't appear if I don't use it on the profile
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    return isEnabled
        ? TextField(
            controller: controller,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            decoration: InputDecoration(
              prefixIcon: icon != null ? Icon(icon) : null,
              label: StyledText(label),
            ),
          )
        : StyledText(displayValue);
  }
}
