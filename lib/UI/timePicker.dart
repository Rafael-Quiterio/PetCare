import 'package:flutter/material.dart';
import 'package:animalapp/UI/theme.dart'; 

class Timepicker extends StatefulWidget {
  final TextEditingController time;
  final String label;

  const Timepicker({super.key, required this.time, required this.label});

  @override
  State<Timepicker> createState() => _TimepickerState();
}

class _TimepickerState extends State<Timepicker> {
  
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.time,
      decoration: AppStyles.inputDecoration(widget.label, Icons.access_time),
      readOnly: true, // The user can't write, only click
      onTap: () async {
        // Opens the time picker
        TimeOfDay? pickedTime = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
          
          // Cores
          builder: (context, child) {
            return Theme(
              data: ThemeData.light().copyWith(
                colorScheme: ColorScheme.light(
                  primary: AppColors.primaryColor,
                  onPrimary: Colors.white,         
                  onSurface: AppColors.titleColor, 
                ),
                textButtonTheme: TextButtonThemeData(
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primaryColor, 
                  ),
                ),
              ),
              child: child!,
            );
          },

        );

        if (pickedTime != null) {
          String hour = pickedTime.hour.toString().padLeft(2, '0');
          String minute = pickedTime.minute.toString().padLeft(2, '0');
          
          setState(() {
            widget.time.text = "$hour:$minute";
          });
        }
      },
    );
  }
}