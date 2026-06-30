
import 'package:animalapp/Services/firestore_service.dart';
import 'package:animalapp/models/Animal.dart';
import 'package:flutter/material.dart';

// local state management and UI interaction
class AnimalStore extends ChangeNotifier{
  final List<Animal> _animals = [];

  List<Animal> get animals => _animals;

  // fetch animals
 Future<void> fetchAnimals() async {
    if (_animals.isNotEmpty) return; // prevent refetching

    final snapshot = await FirestoreService.getAnimal();

    // doc.data() already returns Animal because of withConverter
    _animals.addAll(snapshot.docs.map((doc) => doc.data()));

    notifyListeners();
  }


  //add animal
  void addAnimal(Animal animal) {

    FirestoreService.addAnimal(animal);

    _animals.add(animal);
    notifyListeners();   // Notify all listeners to add new data
  }


  // Save/update animal
  Future<void> saveAnimal(Animal animal) async {
    await FirestoreService.updateAnimal(animal);

    // // Clears the list and reloads it from Firestore to get updated data
    _animals.clear();
    final snapshot = await FirestoreService.getAnimal();
    _animals.addAll(snapshot.docs.map((doc) => doc.data()));

    notifyListeners(); // Notify all listeners to rebuild with new data
    return;
  }

  //remove animal
  void removeAnimal(Animal animal) async {
    await FirestoreService.deleteAnimal(animal);

    _animals.remove(animal);
    notifyListeners(); // Notify all listeners to delete data
  }

}