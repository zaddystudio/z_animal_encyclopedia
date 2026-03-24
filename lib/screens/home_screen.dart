import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart'; // NEW
import '../models/animal_model.dart';
import '../services/api_service.dart';
import 'detail_screen.dart';
import 'favorites_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Animal> _animals = [];
  List<String> _suggestions = [];
  bool _isLoading = false;
  String _selectedCategory = 'All';
  final List<String> _categories = [
    'All',
    'Big Cats',
    'Ocean',
    'Birds',
    'Reptiles',
    'Forest',
    'Savanna',
  ];

  @override
  void initState() {
    super.initState();
    _loadShowcase();
  }

  void _loadShowcase() async {
    setState(() {
      _isLoading = true;
      _selectedCategory = 'All';
      _suggestions = [];
    });
    final results = await ApiService.fetchShowcaseAnimals();
    if (mounted) {
      setState(() {
        _animals = results;
        _isLoading = false;
      });
    }
  }

  void _loadCategory(String category) async {
    if (category == 'All') {
      _loadShowcase();
      return;
    }
    setState(() {
      _isLoading = true;
      _selectedCategory = category;
      _suggestions = [];
      _searchController.clear();
    });
    final results = await ApiService.fetchCategory(category);
    if (mounted) {
      setState(() {
        _animals = results;
        _isLoading = false;
      });
    }
  }

  void _searchAnimals(String query) async {
    if (query.isEmpty) {
      _loadShowcase();
      return;
    }
    setState(() {
      _isLoading = true;
      _selectedCategory = '';
      _suggestions = [];
    });
    final results = await ApiService.fetchAnimals(query);
    if (mounted) {
      setState(() {
        _animals = results;
        _isLoading = false;
        if (_animals.isEmpty) {
          _suggestions = ApiService.getSuggestions(query);
        }
      });
    }
  }

  // --- NEW: ZADDY ABOUT MODAL ---
  void _showAboutZaddy() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Color(0xFF1E1E1E),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Zaddy Digital Solutions',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF00E676),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '...digitally outstanding',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'We build custom apps for different fields and industries. Bring your vision to life.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
            ),
            const SizedBox(height: 32),
            // Website Button
            ElevatedButton.icon(
              onPressed: () =>
                  launchUrl(Uri.parse('https://zaddyhost.top/creatives')),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00E676),
                foregroundColor: const Color(0xFF121212),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              icon: const Icon(Icons.language),
              label: Text(
                'See Our Recent Apps',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            // WhatsApp Button
            OutlinedButton.icon(
              onPressed: () =>
                  launchUrl(Uri.parse('https://wa.me/2347060633216')),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white24),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              icon: const Icon(Icons.chat_bubble_outline),
              label: Text('Chat on WhatsApp', style: GoogleFonts.poppins()),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ).animate().slideY(begin: 1, end: 0, curve: Curves.easeOutBack),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // NEW: The floating Zaddy Info Button!
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: FloatingActionButton(
          heroTag: 'zaddy_btn',
          onPressed: _showAboutZaddy,
          backgroundColor: const Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: const BorderSide(color: Color(0xFF00E676), width: 1.5),
          ),
          child: const Icon(
            Icons.info_outline_rounded,
            color: Color(0xFF00E676),
          ),
        ).animate().scale(delay: 1000.ms),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                            _selectedCategory.isEmpty
                                ? 'Search Results'
                                : 'Discover',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          )
                          .animate()
                          .fade(duration: 500.ms)
                          .slideY(begin: -0.2, end: 0),
                      Text(
                        _selectedCategory.isEmpty
                            ? 'Exploring the animal kingdom'
                            : 'The wild awaits...',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.white54,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.bookmarks_rounded,
                      color: Color(0xFF00E676),
                      size: 30,
                    ),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FavoritesScreen(),
                      ),
                    ),
                  ).animate().scale(),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  style: GoogleFonts.poppins(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search animals (e.g., Fox, Bear)...',
                    hintStyle: GoogleFonts.poppins(color: Colors.white38),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Color(0xFF00E676),
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(
                              Icons.clear,
                              color: Colors.white38,
                            ),
                            onPressed: () {
                              _searchController.clear();
                              _loadShowcase();
                              FocusScope.of(context).unfocus();
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 16,
                    ),
                  ),
                  onSubmitted: _searchAnimals,
                  onChanged: (text) => setState(() {}),
                ),
              ).animate().fade(duration: 700.ms).scale(),
              const SizedBox(height: 20),
              SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    final isSelected = _selectedCategory == category;
                    return GestureDetector(
                      onTap: () => _loadCategory(category),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF00E676)
                              : const Color(0xFF1E1E1E),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF00E676)
                                : Colors.white10,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            category,
                            style: GoogleFonts.poppins(
                              color: isSelected
                                  ? const Color(0xFF121212)
                                  : Colors.white70,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ).animate().fade(delay: 800.ms).slideX(begin: 0.2, end: 0),
              const SizedBox(height: 20),
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF00E676),
                        ),
                      )
                    : _animals.isEmpty
                    ? _buildEmptyState()
                    : MasonryGridView.count(
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        itemCount: _animals.length,
                        itemBuilder: (context, index) =>
                            _buildAnimalCard(_animals[index], index),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off_rounded, size: 64, color: Colors.white24),
          const SizedBox(height: 16),
          Text(
            'No animals found.',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Did you mean:',
            style: GoogleFonts.poppins(color: Colors.white54),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            alignment: WrapAlignment.center,
            children: _suggestions
                .map(
                  (suggestion) => ActionChip(
                    backgroundColor: const Color(0xFF1E1E1E),
                    side: const BorderSide(color: Color(0xFF00E676), width: 1),
                    labelStyle: GoogleFonts.poppins(
                      color: const Color(0xFF00E676),
                      fontWeight: FontWeight.w600,
                    ),
                    label: Text(suggestion),
                    onPressed: () {
                      _searchController.text = suggestion;
                      _searchAnimals(suggestion);
                      FocusScope.of(context).unfocus();
                    },
                  ),
                )
                .toList(),
          ).animate().fade(delay: 200.ms).slideY(begin: 0.2, end: 0),
        ],
      ).animate().fade(duration: 400.ms),
    );
  }

  Widget _buildAnimalCard(Animal animal, int index) {
    final uniqueHeroTag = '${animal.name}_$index';
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              DetailScreen(animal: animal, heroTag: uniqueHeroTag),
        ),
      ),
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
              tag: uniqueHeroTag,
              child: animal.imageUrl == 'local_fallback'
                  ? Image.asset('assets/images/fallback.jpg', fit: BoxFit.cover)
                  : CachedNetworkImage(
                      imageUrl: animal.imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (c, u) =>
                          Container(height: 150, color: Colors.grey[900]),
                      errorWidget: (c, u, e) => Image.asset(
                        'assets/images/fallback.jpg',
                        fit: BoxFit.cover,
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    animal.name,
                    style: GoogleFonts.spaceGrotesk(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    animal.scientificName,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: const Color(0xFF00E676),
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ).animate().fade(delay: (100 * index).ms).slideY(begin: 0.2, end: 0),
    );
  }
}
