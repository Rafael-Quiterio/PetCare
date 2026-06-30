import 'package:animalapp/Services/Animal_store.dart';
import 'package:animalapp/Services/tasks_Store.dart';
import 'package:animalapp/UI/styled_text.dart';
import 'package:animalapp/Views/Animal/animal_profile.dart';
import 'package:animalapp/Views/Create/create.dart';
import 'package:animalapp/Views/Animal/Animal_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AnimalList extends StatelessWidget {
  const AnimalList({super.key});

  @override
  Widget build(BuildContext context) {
    final animals = Provider.of<AnimalStore>(context).animals;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              StyledHeading('My Animals: ${animals.length}'),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (ctx) => const CreateScreen()),
                  );
                },
                child: const ButtonStyledHeading('+  Add Pet'),
              ),
            ],
          ),
        ),

        Expanded(
        
        // So if the animalList is empty it will show a message or else it will show the card with the animals
        child: animals.isEmpty
        ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children:const [
                      Icon(
                        Icons.pets,
                        size: 50,
                        color: Color.fromRGBO(200, 200, 200, 1),
                      ),
                      SizedBox(height: 10),
                      StyledText('No animal found'),
                      SizedBox(height: 5),
                      StyledHeading('Add your first pet to start!'),
                    ],
          )
        )
        : ListView.builder(
            itemCount: animals.length,
            itemBuilder: (context, index) {
              return Center(
                child: SizedBox(
                  width:
                      MediaQuery.of(context).size.width *
                      0.9, //this changes the size of the card and makes it look better. fills 90% of the screen
                  child: Dismissible(
                    // Deletes pet by swiping the card left
                    key: ValueKey(animals[index].id),
                    onDismissed: (direction) {
                      Provider.of<TasksStore>(
                        context,
                        listen: false,
                      ).removeTasksForPet(animals[index].id);
                      Provider.of<AnimalStore>(
                        context,
                        listen: false,
                      ).removeAnimal(animals[index]);
                    },
                    child: AnimalCard(
                      animal: animals[index],
                      onTap: () {
                        //Makes it possible to be a clickable card that navigates to the Profile Screen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (ctx) =>
                                AnimalProfile(animal: animals[index]),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
