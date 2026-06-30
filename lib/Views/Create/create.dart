import 'dart:io';
import 'package:animalapp/Services/Animal_store.dart';
import 'package:animalapp/Services/Cat_Dog_Api_Service.dart';
import 'package:animalapp/Services/tasks_Store.dart';
import 'package:animalapp/Services/notification_service.dart';
import 'package:animalapp/UI/styled_text.dart';
import 'package:animalapp/models/Animal.dart';
import 'package:animalapp/models/tasks_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:provider/provider.dart';
import 'package:animalapp/UI/timePicker.dart';
import 'package:intl/intl.dart';

// Assuming AppColors is imported from your theme file.
// If not, keep your local class. I will use the names you provided.
import 'package:animalapp/UI/theme.dart';

var uuid = const Uuid();

class CreateScreen extends StatefulWidget {
  const CreateScreen({super.key});

  @override
  State<CreateScreen> createState() => _CreateState();
}

class _CreateState extends State<CreateScreen> {
  // ============ TEXT CONTROLLERS ============
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _breedController = TextEditingController();
  final _weightController = TextEditingController();
  final _specieController = TextEditingController();
  final _notesController = TextEditingController();
  final _walksController = TextEditingController();
  final _foodController = TextEditingController();

  // ============ STATE VARIABLES ============
  String? _imagePath;
  String? _selectedSpecies;
  String? _selectedBreed;
  List<String> _breeds = [];
  bool _isLoadingBreeds = false;
  final List<String> _species = ['Dog', 'Cat'];

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _breedController.dispose();
    _weightController.dispose();
    _specieController.dispose();
    _notesController.dispose();
    _walksController.dispose();
    _foodController.dispose();
    super.dispose();
  }

  // ============ IMAGE HANDLING ============
  Future<void> selectImage() async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 600,
      );
      if (pickedFile == null) return;
      setState(() {
        _imagePath = pickedFile.path;
      });
    } catch (e) {
      _showErrorDialog("Image Error", "Could not pick image.");
    }
  }

  // Api method to get the breeds
  Future<void> _fetchBreeds(String species) async {
    setState(() {
      _isLoadingBreeds = true;
      _selectedBreed = null;
      _breeds = []; //This is to clear or empty the list
    });
    try {
      List<String> breeds;
      if (species == 'Dog') {
        breeds = await CatDogBreeds.FetchDogBreeds();
      } else if (species == 'Cat') {
        breeds = await CatDogBreeds.FetchCatBreeds();
      } else {
        breeds = [];
      }


      setState(() {
        _breeds = breeds;
        _isLoadingBreeds = false;
      });
    } catch (e) {
      setState(() => _isLoadingBreeds = false);
      print('Error fetching breeds: $e');
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title, style: TextStyle(color: AppColors.titleColor)),
        content: Text(message, style: TextStyle(color: AppColors.textColor)),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
            ),
            child: const Text('Close', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // This happens if there's any of the controllers that is empty
  void handleSubmit() async {
    // 1. Validations
    if (_nameController.text.trim().isEmpty) {
      _showErrorDialog('Missing Name', 'Please enter pet name.');
      return;
    }
    if (_ageController.text.trim().isEmpty) {
      _showErrorDialog('Missing Age', 'Please enter pet age.');
      return;
    }
    if (_selectedBreed == null) {
      _showErrorDialog('Missing Breed', 'Please select a breed.');
      return;
    }


    String imagePathFinal;

    if(_imagePath != null) {
      imagePathFinal = _imagePath!;
    } else if (_selectedSpecies == 'Dog') {
      imagePathFinal = 'assets/img/dummy1.jpg';
    } else if (_selectedSpecies == 'Cat') {
      imagePathFinal = 'assets/img/dummy2.jpg';
    } else {
      imagePathFinal = 'assets/img/dummy1.jpg'; //This is needed as a fallback, so when I haven't selected species, it still works
    }
    final newAnimalId = uuid.v4();

    // 2. Create Animal
    final animal = Animal(
      id: newAnimalId,
      name: _nameController.text.trim(),
      age: _ageController.text.trim(),
      breed: _selectedBreed!,
      weight: _weightController.text.trim(),
      specie: _specieController.text.trim(),
      notes: _notesController.text.trim(),
      image: imagePathFinal,
    );

    Provider.of<AnimalStore>(context, listen: false).addAnimal(animal);

    // Create Task (Optional since I don't need to add a task right away)
    if (_walksController.text.isNotEmpty) {
      try {
        final timeString = _walksController.text.trim();
        DateTime parsedTime;
        try {
          parsedTime = DateFormat.jm().parse(timeString);
        } catch (e) {
          parsedTime = DateFormat("HH:mm").parse(timeString);
        }

        final now = DateTime.now();
        DateTime scheduledTime = DateTime(
          now.year,
          now.month,
          now.day,
          parsedTime.hour,
          parsedTime.minute,
        );

        if (scheduledTime.isBefore(now)) {
          scheduledTime = scheduledTime.add(const Duration(days: 1));
        }

        final newTask = Task(
          id: DateTime.now().millisecondsSinceEpoch.remainder(2147483647),
          animalId: newAnimalId,
          title: "Walk ${_nameController.text}",
          time: scheduledTime,
          taskType: 'activity',
          isCompleted: false,
        );

        Provider.of<TasksStore>(context, listen: false).addTask(newTask);

        // TRIGGER NOTIFICATION
        try {
          await NotificationService().scheduleReminder(
            id: newTask.id,
            title: "Task: ${newTask.title}",
            body: "Time for a walk!",
            scheduledTime: newTask.time,
          );
        } catch (e) {
          print("Notif Error: $e");
        }
      } catch (e) {
        print("Task Error: $e");
      }
    }

    Navigator.pop(context);
  }

  // UI
  @override
  Widget build(BuildContext context) {

    InputDecoration inputStyle(String label, IconData icon) {
      return InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: AppColors.textColor.withValues(alpha: 0.7),
        ),
        prefixIcon: Icon(icon, color: AppColors.primaryColor),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primaryColor, width: 1.5),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.secondaryColor, // Cream Background
      appBar: AppBar(
        title: const StyledHeading('New Pet'),
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
            // Photo
            GestureDetector(
              onTap: selectImage,
              child: Container(
                width: 150,
                height: 150,
                padding: const EdgeInsets.all(5), 
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20), 
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: _imagePath != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(
                          15,
                        ), 
                        child: Image.file(
                          File(_imagePath!),
                          width: 140,
                          height: 140,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Icon(
                        Icons.add_a_photo_rounded,
                        size: 50,
                        color: AppColors.primaryColor.withValues(alpha: 0.5),
                      ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Tap to add photo",
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),

            const SizedBox(height: 30),

            //  Idenitity section
            const Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(bottom: 8, left: 5),
                child: StyledHeading("Identity"),
              ),
            ),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.secondaryAccent,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.secondaryColor.withValues(alpha: 0.5),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _nameController,
                    style: TextStyle(color: AppColors.textColor),
                    decoration: inputStyle("Pet Name", Icons.pets),
                  ),
                  const SizedBox(height: 15),

                  // Species Dropdown
                  DropdownButtonFormField<String>(
                    initialValue: _selectedSpecies,
                    decoration: inputStyle("Species", Icons.category),
                    dropdownColor: AppColors.secondaryColor,
                    style: TextStyle(color: AppColors.textColor, fontSize: 16),
                    items: _species
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedSpecies = val;
                        _specieController.text = val ?? '';
                        _fetchBreeds(val!);
                      });
                    },
                  ),
                  const SizedBox(height: 15),

                  // Breed Dropdown
                  if (_isLoadingBreeds)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(
                          color: AppColors.primaryColor,
                        ),
                      ),
                    )
                  else
                    DropdownButtonFormField<String>(
                      initialValue: _selectedBreed,
                      decoration: inputStyle("Breed", Icons.workspaces_outline),
                      dropdownColor: AppColors.secondaryColor,
                      style: TextStyle(
                        color: AppColors.textColor,
                        fontSize: 16,
                      ),
                      items: _breeds
                          .map(
                            (b) => DropdownMenuItem(value: b, child: Text(b)),
                          )
                          .toList(),
                      onChanged: (val) => setState(() => _selectedBreed = val),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // --- 3. STATS ROW (Age & Weight) ---
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryAccent,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.secondaryColor.withValues(
                            alpha: 0.5,
                          ),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _weightController,
                      keyboardType: TextInputType.number,
                      style: TextStyle(color: AppColors.textColor),
                      decoration: inputStyle(
                        "Weight (kg)",
                        Icons.monitor_weight,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryAccent,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.secondaryColor.withValues(
                            alpha: 0.5,
                          ),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _ageController,
                      keyboardType: TextInputType.number,
                      style: TextStyle(color: AppColors.textColor),
                      decoration: inputStyle("Age (yrs)", Icons.cake),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),

            // CARE SECTION ---
            const Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(bottom: 8, left: 5),
                child: StyledHeading("Care & Initial Tasks"),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.secondaryAccent,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.secondaryColor.withValues(alpha: 0.5),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const SizedBox(height: 15),
                  Timepicker(time: _walksController, label: "First Walk Time"),
                ],
              ),
            ),

            const SizedBox(height: 25),

            //  NOTES SECTION ---
            const Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(bottom: 8, left: 5),
                child: StyledHeading("Notes"),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.secondaryAccent,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.secondaryColor.withValues(alpha: 0.5),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _notesController,
                maxLines: 3,
                style: TextStyle(color: AppColors.textColor),
                decoration: InputDecoration(
                  hintText: "Allergies, habits, etc...",
                  hintStyle: TextStyle(
                    color: AppColors.textColor.withValues(alpha: 0.5),
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),

            const SizedBox(height: 40),

            // --- SAVE BUTTON ---
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: handleSubmit,
                child: const ButtonStyledHeading("Save Pet"),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
