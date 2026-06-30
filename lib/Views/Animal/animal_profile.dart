import 'dart:io';
import 'package:animalapp/UI/theme.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:animalapp/models/Animal.dart';
import 'package:animalapp/Services/Animal_store.dart';
import 'package:animalapp/UI/editable_field.dart';
import 'package:animalapp/UI/styled_text.dart';
import 'package:animalapp/Services/Cat_Dog_Api_Service.dart';

class AnimalProfile extends StatefulWidget {
  final Animal animal;

  const AnimalProfile({super.key, required this.animal});

  @override
  State<AnimalProfile> createState() => _AnimalProfileState();
}

class _AnimalProfileState extends State<AnimalProfile> {
  bool _isEditing = false;

  late TextEditingController _nameController;
  late TextEditingController _specieController;
  late TextEditingController _breedController;
  late TextEditingController _weightController;
  late TextEditingController _ageController;
  late TextEditingController _notesController;

  String? _imagePath;

  //Needs a list for the dropdown, just like in the create screen
  final List<String> _species = ['Dog', 'Cat'];
  //Necessary for the Breeds to work
  List<String> _breeds = [];
  bool _isLoadingBreeds = false;

  @override
  void initState() {
    super.initState();
    final a = widget.animal;
    _nameController = TextEditingController(text: a.name);
    _specieController = TextEditingController(text: a.specie);
    _breedController = TextEditingController(text: a.breed);
    _weightController = TextEditingController(text: a.weight);
    _ageController = TextEditingController(text: a.age);
    _notesController = TextEditingController(text: a.notes);
    _imagePath = a.image;

    _fetchBreeds(a.specie);
  }

  // API logic bc there's a possibility that the specie and breed will change
  Future<void> _fetchBreeds(String species) async {
    setState(() {
      _isLoadingBreeds = true;
      _breeds = []; // Clear old list to avoid mismatches
    });

    try {
      List<String> fetchedBreeds;
      if (species == 'Dog') {
        fetchedBreeds = await CatDogBreeds.FetchDogBreeds();
      } else if (species == 'Cat') {
        fetchedBreeds = await CatDogBreeds.FetchCatBreeds();
      } else {
        fetchedBreeds = [];
      }

      if (mounted) {
        setState(() {
          _breeds = fetchedBreeds;
          _isLoadingBreeds = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingBreeds = false);
      }
      print('Error fetching breeds: $e');
    }
  }


  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _imagePath = picked.path);
    }
  }

  void _saveChanges() {
    final updatedAnimal = widget.animal.copyWith(
      name: _nameController.text.trim(),
      specie: _specieController.text.trim(),
      breed: _breedController.text.trim(),
      weight: _weightController.text.trim(),
      age: _ageController.text.trim(),
      notes: _notesController.text.trim(),
      image: _imagePath,
    );

    Provider.of<AnimalStore>(context, listen: false).saveAnimal(updatedAnimal);
    setState(() => _isEditing = false);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final displayImage = (_imagePath?.startsWith('assets/') ?? false)
        ? Image.asset(_imagePath!, width: 150, height: 150, fit: BoxFit.cover)
        : Image.file(
            File(_imagePath!),
            width: 150,
            height: 150,
            fit: BoxFit.cover,
          );

    return Scaffold(
      backgroundColor: AppColors.secondaryColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: StyledHeading(widget.animal.name),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isEditing ? Icons.check : Icons.edit,
              color: AppColors.primaryColor,
              size: 28,
            ),
            onPressed: () {
              if (_isEditing) {
                _saveChanges();
              } else {
                setState(() => _isEditing = true);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Photo section
            GestureDetector(
              onTap: _isEditing ? _pickImage : null,
              child: Container(
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
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Stack(
                    children: [
                      displayImage,
                      if (_isEditing)
                        Positioned.fill(
                          child: Container(
                            color: Colors.black26,
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 25),

            // Identity section
            const Align(
              alignment: Alignment.centerLeft,
              child: StyledHeading("Identity"),
            ),
            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.secondaryAccent,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryColor.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ONLY SHOW LABEL IF NOT EDITING
                  if (!_isEditing) _buildLabel("PET NAME"),
                  EditableField(
                    isEnabled: _isEditing,
                    controller: _nameController,
                    displayValue: widget.animal.name,
                    label: "Pet Name",
                  ),
                  const Divider(height: 30, thickness: 1),

                  // 2. SPECIES (SMART LOGIC)
                  if (!_isEditing) ...[
                    _buildLabel("SPECIE"),
                    EditableField(
                      isEnabled: false,
                      controller: _specieController,
                      displayValue: widget.animal.specie,
                      label: "Specie",
                    ),
                  ] else ...[
                    _buildLabel("SPECIE"),
                    const SizedBox(height: 5),
                    DropdownButtonFormField<String>(
                      initialValue: _species.contains(_specieController.text)
                          ? _specieController.text
                          : null,
                      decoration: AppStyles.inputDecoration(
                        "Specie",
                        Icons.category,
                      ),
                      items: _species
                          .map(
                            (s) => DropdownMenuItem(value: s, child: Text(s)),
                          )
                          .toList(),
                      onChanged: (val) {
                        setState(() {
                          if (val == null) return;
                          _specieController.text = val;

                          // Reset breed when species changes
                          _breedController.text = '';

                          // Fetch new list of breeds
                          _fetchBreeds(val);

                          // Smart Image Swap
                          if (_imagePath != null &&
                              _imagePath!.startsWith('assets/')) {
                            if (val == 'Dog') {
                              _imagePath = 'assets/img/dummy1.jpg';
                            } else if (val == 'Cat') {
                              _imagePath = 'assets/img/dummy2.jpg';
                            }
                          }
                        });
                      },
                    ),
                  ],

                  const Divider(height: 30, thickness: 1),

                  // 3. BREED 
                  if (!_isEditing) ...[
                    _buildLabel("BREED"),
                    EditableField(
                      isEnabled: false,
                      controller: _breedController,
                      displayValue: widget.animal.breed,
                      label: "Breed",
                    ),
                  ] else ...[
                    // EDIT MODE: Show Dropdown or Loader
                    _buildLabel("BREED"),
                    const SizedBox(height: 5),

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

                        isExpanded: true, //there was an overflow issue with the names so this is necessary
                        // Check if current text is valid in list, else null
                        initialValue: _breeds.contains(_breedController.text)
                            ? _breedController.text
                            : null,
                        decoration: AppStyles.inputDecoration(
                          "Select Breed",
                          Icons.workspaces_outline,
                        ),
                        items: _breeds
                            .map(
                              (b) => DropdownMenuItem(value: b, child: Text(b)),
                            )
                            .toList(),
                        onChanged: (val) {
                          setState(() {
                            if (val != null) _breedController.text = val;
                          });
                        },
                      ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 25),

            // stats
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryAccent,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withValues(alpha: 0.1),
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!_isEditing) _buildLabel("WEIGHT"),
                        EditableField(
                          isEnabled: _isEditing,
                          controller: _weightController,
                          displayValue: ' ${widget.animal.weight}kg',
                          label: "Weight",
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryAccent,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withValues(alpha: 0.1),
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!_isEditing) _buildLabel("AGE"),
                        EditableField(
                          isEnabled: _isEditing,
                          controller: _ageController,
                          displayValue: '${widget.animal.age}yo',
                          label: "Age",
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),

            //Notes
            const Align(
              alignment: Alignment.centerLeft,
              child: StyledHeading("Notes"),
            ),
            const SizedBox(height: 10),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.secondaryAccent,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.1),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!_isEditing) _buildLabel("ADDITIONAL INFORMATION"),
                  const SizedBox(height: 5),
                  EditableField(
                    isEnabled: _isEditing,
                    controller: _notesController,
                    displayValue: widget.animal.notes.isEmpty
                        ? "No notes added"
                        : widget.animal.notes,
                    label: "Notes",
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0, left: 2.0),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}
