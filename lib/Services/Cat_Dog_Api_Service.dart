import 'dart:convert';
import 'package:http/http.dart' as http;

class CatDogBreeds {
  
  // This is if the API isn't working so it will use a list with some breeds
  static const List<String> _fallbackDogs = [
    'Beagle', 'Boxer', 'Bulldog', 'Chihuahua', 'Corgi', 'Dalmatian', 
    'German Shepherd', 'Golden Retriever', 'Husky', 'Labrador', 
    'Poodle', 'Pug', 'Rottweiler', 'Shih Tzu', 'Yorkie'
  ];

  static const List<String> _fallbackCats = [
    'Abyssinian', 'American Shorthair', 'Bengal', 'Birman', 'Bombay',
    'British Shorthair', 'Maine Coon', 'Persian', 'Ragdoll', 'Russian Blue',
    'Scottish Fold', 'Siamese', 'Sphynx', 'Tabby', 'Tuxedo'
  ];


  // Dog CEO API
  static Future<List<String>> FetchDogBreeds() async {
    try {
      print("Fetching Dogs...");
      final url = Uri.parse('https://dog.ceo/api/breeds/list/all');
      
      // Timeout after 5 seconds so the user doesn't wait forever
      final response = await http.get(url).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final Map<String, dynamic> breedsMap = data['message'];
        
        return breedsMap.keys.map((breed) {
          return breed[0].toUpperCase() + breed.substring(1);
        }).toList();
      }
      
      print("Dog API Error: ${response.statusCode}. Using Fallback.");
      return _fallbackDogs;

    } catch (e) {
      print("Dog API Exception: $e. Using Fallback.");
      return _fallbackDogs; // <--- The Safety Net
    }
  }

  // TheCatAPI
  // APi is currently not working bc they changed some rules, so it will only retrieve my list for now. It was working before tho
  static Future<List<String>> FetchCatBreeds() async {
    try {
      print("Fetching Cats...");
      final url = Uri.parse('https://api.thecatapi.com/v1/breeds');
      
      final response = await http.get(url).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((catJson) => catJson['name'].toString()).toList();
      }
      
      print("Cat API Error: ${response.statusCode}. Using Fallback.");
      return _fallbackCats;

    } catch (e) {
      print("Cat API Exception: $e. Using Fallback.");
      return _fallbackCats; // <--- The Safety Net
    }
  }
}