import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/animal_model.dart';
import 'detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<Animal> _savedAnimals = [];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> savedStrings =
        prefs.getStringList('favorite_animals') ?? [];

    setState(() {
      _savedAnimals = savedStrings
          .map((str) => Animal.fromJson(json.decode(str)))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Vault',
          style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold),
        ),
      ),
      body: _savedAnimals.isEmpty
          ? Center(
              child: Text(
                'No animals saved yet.\nGo favorite some!',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(color: Colors.white54),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: MasonryGridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                itemCount: _savedAnimals.length,
                itemBuilder: (context, index) {
                  final animal = _savedAnimals[index];
                  final heroTag = 'fav_${animal.name}_$index';
                  return GestureDetector(
                    onTap: () async {
                      // Wait for user to return, then reload in case they unfavorited it
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              DetailScreen(animal: animal, heroTag: heroTag),
                        ),
                      );
                      _loadFavorites();
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: const Color(0xFF1E1E1E),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Hero(
                            tag: heroTag,
                            child: animal.imageUrl == 'local_fallback'
                                ? Image.asset(
                                    'assets/images/fallback.jpg',
                                    fit: BoxFit.cover,
                                  )
                                : CachedNetworkImage(
                                    imageUrl: animal.imageUrl,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Text(
                              animal.name,
                              style: GoogleFonts.spaceGrotesk(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ).animate().fade().slideY(begin: 0.2, end: 0),
                  );
                },
              ),
            ),
    );
  }
}
