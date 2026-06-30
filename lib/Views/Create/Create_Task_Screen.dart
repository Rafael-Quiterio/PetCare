import 'package:animalapp/Services/Animal_store.dart';
import 'package:animalapp/Services/tasks_Store.dart';
import 'package:animalapp/Services/notification_service.dart';
import 'package:animalapp/models/tasks_model.dart';
import 'package:animalapp/UI/styled_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animalapp/UI/theme.dart'; 

class CreateTaskScreen extends StatefulWidget {
  const CreateTaskScreen({super.key});

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final _titleController = TextEditingController();
  
  final List<TimeOfDay> _selectedTimes = [];

  String? _selectedPetId;
  String _selectedType = 'activity';

  final List<Map<String, dynamic>> _taskTypes = [
    {'value': 'activity', 'label': 'Activity / Walk', 'icon': Icons.directions_walk_rounded},
    {'value': 'food', 'label': 'Food', 'icon': Icons.restaurant_rounded},
    {'value': 'health', 'label': 'Health / Vet', 'icon': Icons.medical_services_rounded},
    {'value': 'other', 'label': 'Other', 'icon': Icons.notifications_active_rounded},
  ];

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title, style: TextStyle(color: AppColors.titleColor)),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryColor),
            child: const Text('Close', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Function for picking and choosing the time
  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryColor,
              onPrimary: Colors.white,
              onSurface: AppColors.titleColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      if (!_selectedTimes.contains(picked)) {
        setState(() {
          _selectedTimes.add(picked);
          _selectedTimes.sort((a, b) => (a.hour * 60 + a.minute).compareTo(b.hour * 60 + b.minute));
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Time already added!")),
        );
      }
    }
  }

  void handleSubmit() async {

    if (_titleController.text.trim().isEmpty) {
      _showErrorDialog('Missing title', 'Please enter a task title.');
      return;
    }

    if (_selectedTimes.isEmpty) {
      _showErrorDialog('Missing time', 'Please add at least one time.');
      return;
    }
    if (_selectedPetId == null) {
      _showErrorDialog('Missing Pet', 'Please select a pet.');
      return;
    }

    final now = DateTime.now();

    //For a specific hour their a separted task
    for (int i = 0; i < _selectedTimes.length; i++) {
      final time = _selectedTimes[i];
      
      // Calculates de date
      DateTime scheduledTime = DateTime(now.year, now.month, now.day, time.hour, time.minute);

      // if the time that was input is already over by today, the task will be moved for tomorrow
      if (scheduledTime.isBefore(now)) {
        scheduledTime = scheduledTime.add(const Duration(days: 1));
      }

      final uniqueId = (DateTime.now().millisecondsSinceEpoch + i).remainder(2147483647);

      final newTask = Task(
        id: uniqueId,
        animalId: _selectedPetId!,
        title: _titleController.text.trim(),
        time: scheduledTime,
        taskType: _selectedType,
        isCompleted: false,
      );

      // Save
      Provider.of<TasksStore>(context, listen: false).addTask(newTask);

      // schedule notification
      try {
        await NotificationService().scheduleReminder(
          id: newTask.id,
          title: "Task: ${newTask.title}",
          body: "Time for ${newTask.taskType}!",
          scheduledTime: newTask.time,
        );
      } catch (e) {
        print("Notification Error for task $i: $e");
      }
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final animals = Provider.of<AnimalStore>(context).animals;

    return Scaffold(
      backgroundColor: AppColors.secondaryColor, 
      appBar: AppBar(
        title: const StyledHeading("New Task"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            
            // --- 1. SELECT PET ---
            const Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(bottom: 8, left: 5),
                child: StyledHeading("Who is this for?"),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              decoration: AppStyles.boxDecoration,
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedPetId,
                  hint: Text("Select a Pet", style: TextStyle(color: Colors.grey[400])),
                  isExpanded: true,
                  icon: Icon(Icons.keyboard_arrow_down, color: AppColors.primaryColor),
                  items: animals.map((animal) {
                    return DropdownMenuItem(
                      value: animal.id,
                      child: Row(
                        children: [
                          Icon(Icons.pets, color: AppColors.primaryColor, size: 20),
                          const SizedBox(width: 10),
                          Text(animal.name, style: TextStyle(color: AppColors.textColor)),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _selectedPetId = value),
                ),
              ),
            ),

            const SizedBox(height: 25),

            // --- 2. SELECT TYPE ---
            const Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(bottom: 8, left: 5),
                child: StyledHeading("Task Type"),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              decoration: AppStyles.boxDecoration,
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedType,
                  isExpanded: true,
                  icon: Icon(Icons.keyboard_arrow_down, color: AppColors.primaryColor),
                  items: _taskTypes.map((type) {
                    return DropdownMenuItem(
                      value: type['value'] as String,
                      child: Row(
                        children: [
                          Icon(type['icon'] as IconData, color: AppColors.primaryColor, size: 20),
                          const SizedBox(width: 10),
                          Text(type['label'] as String, style: TextStyle(color: AppColors.textColor)),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedType = val!),
                ),
              ),
            ),

            const SizedBox(height: 25),

            // --- 3. DETAILS CARD (Title & Multiple Times) ---
            const Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(bottom: 8, left: 5),
                child: StyledHeading("Details"),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: AppStyles.boxDecoration,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title Input
                  TextField(
                    controller: _titleController,
                    style: TextStyle(color: AppColors.textColor),
                    decoration: InputDecoration(
                      hintText: "Ex: Give Medicine",
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      labelText: "Task Title",
                      labelStyle: TextStyle(color: AppColors.textColor.withValues(alpha: 0.7)),
                      prefixIcon: Icon(Icons.edit, color: AppColors.primaryColor),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                  ),
                  
                  const Divider(height: 30, thickness: 1),

                  // MUDANÇA 4: Interface de Múltiplos Horários
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Times Selected:", 
                        style: TextStyle(color: AppColors.textColor, fontWeight: FontWeight.bold)
                      ),
                      TextButton.icon(
                        onPressed: _pickTime,
                        icon: const Icon(Icons.add_alarm),
                        label: const Text("Add Time"),
                        style: TextButton.styleFrom(foregroundColor: AppColors.primaryColor),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 10),

                  // Mostra as horas escolhidas 
                  _selectedTimes.isEmpty 
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Text("No times added yet.", style: TextStyle(color: Colors.grey[400], fontSize: 13, fontStyle: FontStyle.italic)),
                      )
                    : Wrap(
                        spacing: 8.0,
                        children: _selectedTimes.map((time) {
                          return Chip(
                            label: Text(time.format(context)),
                            backgroundColor: AppColors.secondaryAccent,
                            deleteIcon: const Icon(Icons.close, size: 18),
                            onDeleted: () {
                              setState(() {
                                _selectedTimes.remove(time);
                              });
                            },
                          );
                        }).toList(),
                      ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // --- 4. SAVE BUTTON ---
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  elevation: 5,
                  shadowColor: AppColors.primaryColor.withValues(alpha: 0.4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: const Text(
                  "SCHEDULE TASKS", 
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.2)
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}