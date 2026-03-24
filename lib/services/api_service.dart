import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/animal_model.dart';

class ApiService {
  // 🛑 PASTE YOUR REAL KEYS HERE 🛑
  static const String _ninjaApiKey = 'gsn8Km9nqoJ1NmLopfUpAC2agRRjIUvDcXoqKPci';
  static const String _pexelsApiKey =
      'aDA3CVNsNoQVaZHUwLTkDs1SwS8ydRAAH2FMrzOgW8eXRmmA4sJUB3dw';

  static const List<String> animalPool = [
    'Lion',
    'Elephant',
    'Penguin',
    'Panda',
    'Eagle',
    'Dolphin',
    'Tiger',
    'Wolf',
    'Cheetah',
    'Giraffe',
    'Zebra',
    'Kangaroo',
    'Koala',
    'Sloth',
    'Gorilla',
    'Chameleon',
    'Crocodile',
    'Octopus',
    'Jellyfish',
    'Seahorse',
    'Flamingo',
    'Owl',
    'Falcon',
    'Macaw',
    'Toucan',
    'Moose',
    'Bison',
    'Rhino',
    'Hippo',
    'Leopard',
    'Jaguar',
    'Panther',
    'Fox',
    'Wolverine',
    'Otter',
    'Porcupine',
    'Armadillo',
    'Meerkat',
    'Walrus',
    'Manatee',
    'Narwhal',
    'Orca',
    'Shark',
    'Bear',
  ];

  static const Map<String, List<String>> categoryPools = {
    'Big Cats': [
      'Lion',
      'Tiger',
      'Cheetah',
      'Leopard',
      'Jaguar',
      'Panther',
      'Cougar',
      'Lynx',
    ],
    'Ocean': [
      'Shark',
      'Dolphin',
      'Whale',
      'Orca',
      'Octopus',
      'Jellyfish',
      'Manatee',
      'Seahorse',
      'Stingray',
      'Turtle',
    ],
    'Birds': [
      'Eagle',
      'Owl',
      'Parrot',
      'Macaw',
      'Toucan',
      'Falcon',
      'Penguin',
      'Flamingo',
      'Ostrich',
      'Pelican',
    ],
    'Reptiles': [
      'Crocodile',
      'Chameleon',
      'Snake',
      'Iguana',
      'Gecko',
      'Alligator',
      'Komodo Dragon',
      'Python',
    ],
    'Forest': [
      'Bear',
      'Wolf',
      'Moose',
      'Deer',
      'Fox',
      'Wolverine',
      'Porcupine',
      'Raccoon',
      'Badger',
    ],
    'Savanna': [
      'Elephant',
      'Giraffe',
      'Zebra',
      'Rhino',
      'Hippo',
      'Kangaroo',
      'Meerkat',
      'Baboon',
      'Hyena',
    ],
  };

  static Future<List<Animal>> fetchAnimals(String query) async {
    final ninjaUrl = Uri.parse(
      'https://api.api-ninjas.com/v1/animals?name=$query',
    );
    try {
      final response = await http.get(
        ninjaUrl,
        headers: {'X-Api-Key': _ninjaApiKey},
      );
      if (response.statusCode == 200) {
        List data = json.decode(response.body);
        List<Animal> animals = data
            .map((json) => Animal.fromJson(json))
            .toList();
        for (var animal in animals) {
          animal.gallery = await _fetchImageUrls(animal.name);
          animal.imageUrl = animal.gallery.isNotEmpty
              ? animal.gallery.first
              : 'local_fallback';
        }
        return animals;
      }
    } catch (e) {
      print('Network Error: $e');
    }
    return [];
  }

  // --- NEW: THE CACHE ENGINE ---
  static Future<List<Animal>> fetchShowcaseAnimals() async {
    final prefs = await SharedPreferences.getInstance();

    try {
      List<String> shuffledPool = List.from(animalPool)..shuffle();
      List<String> selectedNames = shuffledPool.take(8).toList();
      List<Animal> animals = await _fetchMultipleConcurrently(selectedNames);

      if (animals.isNotEmpty) {
        // Save to cache!
        List<String> jsonList = animals
            .map((a) => json.encode(a.toJson()))
            .toList();
        await prefs.setStringList('cache_showcase', jsonList);
        return animals;
      }
    } catch (e) {
      print("Showcase fetch failed, trying cache...");
    }

    // If internet fails, load from Cache!
    final List<String>? cachedStrings = prefs.getStringList('cache_showcase');
    if (cachedStrings != null && cachedStrings.isNotEmpty) {
      return cachedStrings
          .map((str) => Animal.fromJson(json.decode(str)))
          .toList();
    }
    return [];
  }

  static Future<List<Animal>> fetchCategory(String category) async {
    final prefs = await SharedPreferences.getInstance();
    String cacheKey = 'cache_cat_$category';

    try {
      List<String> pool = List.from(categoryPools[category] ?? [])..shuffle();
      List<String> selectedNames = pool.take(8).toList();
      List<Animal> animals = await _fetchMultipleConcurrently(selectedNames);

      if (animals.isNotEmpty) {
        List<String> jsonList = animals
            .map((a) => json.encode(a.toJson()))
            .toList();
        await prefs.setStringList(cacheKey, jsonList);
        return animals;
      }
    } catch (e) {
      print("Category fetch failed, trying cache...");
    }

    // Load from Cache if failed
    final List<String>? cachedStrings = prefs.getStringList(cacheKey);
    if (cachedStrings != null && cachedStrings.isNotEmpty) {
      return cachedStrings
          .map((str) => Animal.fromJson(json.decode(str)))
          .toList();
    }
    return [];
  }

  static Future<List<Animal>> _fetchMultipleConcurrently(
    List<String> names,
  ) async {
    List<Animal> results = [];
    await Future.wait(
      names.map((name) async {
        final ninjaUrl = Uri.parse(
          'https://api.api-ninjas.com/v1/animals?name=$name',
        );
        try {
          final response = await http.get(
            ninjaUrl,
            headers: {'X-Api-Key': _ninjaApiKey},
          );
          if (response.statusCode == 200) {
            List data = json.decode(response.body);
            if (data.isNotEmpty) {
              Animal animal = Animal.fromJson(data[0]);
              animal.gallery = await _fetchImageUrls(animal.name);
              animal.imageUrl = animal.gallery.isNotEmpty
                  ? animal.gallery.first
                  : 'local_fallback';
              results.add(animal);
            }
          }
        } catch (e) {
          print('Error fetching animal: $e');
        }
      }),
    );
    results.shuffle();
    return results;
  }

  static List<String> getSuggestions(String query) {
    final q = query.toLowerCase();
    var matches = animalPool
        .where(
          (a) => a.toLowerCase().contains(q) || q.contains(a.toLowerCase()),
        )
        .toList();
    if (matches.isEmpty) {
      return (List<String>.from(animalPool)..shuffle()).take(3).toList();
    }
    return (matches..shuffle()).take(3).toList();
  }

  static Future<List<String>> _fetchImageUrls(String animalName) async {
    final pexelsUrl = Uri.parse(
      'https://api.pexels.com/v1/search?query=$animalName animal&per_page=4',
    );
    try {
      final response = await http.get(
        pexelsUrl,
        headers: {'Authorization': _pexelsApiKey},
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['photos'] != null && data['photos'].isNotEmpty) {
          return (data['photos'] as List)
              .map((photo) => photo['src']['large'].toString())
              .toList();
        }
      }
    } catch (e) {
      print('Pexels Error: $e');
    }
    return ['local_fallback'];
  }
}
