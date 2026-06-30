import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:animalapp/models/Animal.dart';

// data access layer (CRUD)
class FirestoreService {

static final ref = FirebaseFirestore.instance
.collection('animals')
.withConverter(
  fromFirestore: Animal.fromFirestore,
  toFirestore: (Animal a, _) => a.toFirestore()
);


// add a new animal
static Future<void> addAnimal(Animal animal) async {
  await ref.doc(animal.id).set(animal);
}


//get animals
static Future<QuerySnapshot<Animal>> getAnimal() {
  return ref.get();
}



// update an animal
static Future<void> updateAnimal(Animal animal) async {
  await ref.doc(animal.id).update(animal.toFirestore());
}


//delete an animal
static Future<void> deleteAnimal(Animal animal) async {
  await ref.doc(animal.id).delete();
}

}

