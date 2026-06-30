import 'package:animalapp/UI/theme.dart';
import 'package:animalapp/Views/MainMenu.dart';
import 'package:flutter/material.dart';


class MySegmentedButton extends StatelessWidget {
  final Pages selected;
  final ValueChanged<Pages> onSelectionChanged;
  
  const MySegmentedButton({super.key, required this.selected, required this.onSelectionChanged});
  
  @override
  Widget build(BuildContext context) {
    return SegmentedButton<Pages>(
      style: SegmentedButton.styleFrom(
        backgroundColor: AppColors.secondaryAccent,
        foregroundColor: Colors.black,
        selectedForegroundColor: Colors.white,
        selectedBackgroundColor: AppColors.primaryAccent,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        visualDensity: VisualDensity.compact,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      segments: const <ButtonSegment<Pages>>[
        ButtonSegment<Pages>(
          value: Pages.Pets,
          label: Text('Pets', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
          icon: Icon(Icons.pets, size: 18),
        ),
        ButtonSegment<Pages>(
          value: Pages.Tasks,
          label: Text('Tasks', 
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
          icon: Icon(Icons.notification_add, size: 18),
        ),
        ButtonSegment<Pages>(
          value: Pages.Gemini,
          label: Text('Gemini', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
          icon: Icon(Icons.bubble_chart, size: 18),
        ),
      ],
      selected: {selected},
      onSelectionChanged: (newSelection) {
        onSelectionChanged(newSelection.first);
      },
      multiSelectionEnabled: false,
    );
  }
}