// main_menu.dart
import 'package:animalapp/Services/Animal_store.dart';
import 'package:animalapp/UI/segmented_button.dart';
import 'package:animalapp/Views/Gemini/Gemini.dart';
import 'package:animalapp/Views/Tasks/Tasks.dart';
import 'package:animalapp/UI/styled_text.dart';
import 'package:flutter/material.dart';
import 'package:animalapp/Views/Animal/Animal_List.dart';
import 'package:provider/provider.dart';

enum Pages { Pets, Tasks, Gemini }

class MainMenu extends StatefulWidget {
  const MainMenu({super.key});

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  Pages _selectedPage = Pages.Pets;

    @override
  void initState() {
    super.initState();
    // Fetch animals once when MainMenu is first built
    Provider.of<AnimalStore>(context, listen: false).fetchAnimals();
  }

   @override
  Widget build(BuildContext context) {
    Widget content;
    switch (_selectedPage) {
      case Pages.Pets:
        content = const AnimalList();
        break;
      case Pages.Tasks:
        content = const TasksPage();
        break;
      case Pages.Gemini:
        content = const GeminiPage();
        break;
    }

    return Scaffold(
      appBar: AppBar(
        title: const StyledTitleBar('Pet Guardian',),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: MySegmentedButton(
                selected: _selectedPage,
                onSelectionChanged: (newPage) {
                  setState(() => _selectedPage = newPage);
                },
              ),
            ),
          ),
          Expanded(child: content),
        ],
      ),
    );
  }
}
