import 'package:cloud_firestore/cloud_firestore.dart';

//Model class
class Animal {
  // fields
  final String id;
  final String name;
  final String age;
  final String breed;
  final String weight;
  final String specie;
  final String notes;
  final String image; //It will store the URL

  

  //Constructor
  Animal({
    required this.name,
    required this.age,
    required this.breed,
    required this.id,
    required this.weight,
    required this.specie,
    required this.notes,
    required this.image,
  });

  //Animal to firestore (map)
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'age': age,
      'breed': breed,
      'weight': weight,
      'specie': specie,
      'notes': notes,
      'image': image,
    };
  }

  // Animal from Firestore
  factory Animal.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    //get data from snapshot
    final data = snapshot.data()!;

    // Make the Animal instance
    Animal animal = Animal(
      id: snapshot.id,
      name: data['name'] ?? '',
      age: data['age'] ?? '',
      breed: data['breed'] ?? '',
      weight: data['weight'] ?? '',
      specie: data['specie'] ?? '',
      notes: data['notes'] ?? '',
      image: data['image'] ?? '',
    );

    return animal;
  }

  // Method to create a copy of an Animal with updated fields
  // This is useful when editing - specific fields can be changed while while keeping others the same
  Animal copyWith({
    // fields
    String? id,
    String? name,
    String? age,
    String? breed,
    String? weight,
    String? specie,
    String? notes,
    String? image, //It will store the URL

  }) {
    // Returns a new Animal with the updated values and if any parameter is not provided it returns the current one
    return Animal(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      breed: breed ?? this.breed,
      weight: weight ?? this.weight,
      specie: specie ?? this.specie,
      notes: notes ?? this.notes,
      image: image ?? this.image,
    );
  }
}


//Tentar ter o gemini mais context-aware