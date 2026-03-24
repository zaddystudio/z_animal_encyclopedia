import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:palette_generator/palette_generator.dart';
import '../models/animal_model.dart';
import '../services/api_service.dart';
import 'versus_screen.dart'; // NEW IMPORT

class DetailScreen extends StatefulWidget {
  final Animal animal;
  final String heroTag;

  const DetailScreen({super.key, required this.animal, required this.heroTag});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isPlaying = false;
  bool _isFavorite = false;
  int _currentImageIndex = 0;
  Color _accentColor = const Color(0xFF00E676);

  @override
  void initState() {
    super.initState();
    _initTts();
    _checkIfFavorite();
    _extractColor();
  }

  Future<void> _extractColor() async {
    String currentUrl = widget.animal.gallery.isNotEmpty
        ? widget.animal.gallery[_currentImageIndex]
        : widget.animal.imageUrl;
    ImageProvider imageProvider = currentUrl == 'local_fallback'
        ? const AssetImage('assets/images/fallback.jpg') as ImageProvider
        : CachedNetworkImageProvider(currentUrl);
    try {
      final PaletteGenerator palette = await PaletteGenerator.fromImageProvider(
        imageProvider,
      );
      if (palette.dominantColor != null && mounted) {
        setState(() {
          _accentColor = palette.dominantColor!.color;
        });
      }
    } catch (e) {
      print("Color extraction failed: $e");
    }
  }

  Future<void> _checkIfFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> savedStrings =
        prefs.getStringList('favorite_animals') ?? [];
    setState(() {
      _isFavorite = savedStrings.any(
        (str) => str.contains('"name":"${widget.animal.name}"'),
      );
    });
  }

  Future<void> _toggleFavorite() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> savedStrings = prefs.getStringList('favorite_animals') ?? [];
    if (_isFavorite) {
      savedStrings.removeWhere(
        (str) => str.contains('"name":"${widget.animal.name}"'),
      );
    } else {
      savedStrings.add(json.encode(widget.animal.toJson()));
    }
    await prefs.setStringList('favorite_animals', savedStrings);
    setState(() {
      _isFavorite = !_isFavorite;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isFavorite ? 'Saved to Vault! 💚' : 'Removed from Vault.',
        ),
        backgroundColor: const Color(0xFF1E1E1E),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _initTts() {
    _flutterTts.setCompletionHandler(() {
      if (mounted) {
        setState(() {
          _isPlaying = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  Future<void> _toggleVoice() async {
    if (_isPlaying) {
      await _flutterTts.stop();
      setState(() {
        _isPlaying = false;
      });
      return;
    }
    setState(() {
      _isPlaying = true;
    });
    String script = "Meet the ${widget.animal.name}. ";
    if (widget.animal.slogan.isNotEmpty) script += "${widget.animal.slogan} ";
    if (widget.animal.diet != 'N/A')
      script += "It is a ${widget.animal.diet}. ";
    if (widget.animal.topSpeed != 'N/A')
      script += "It can reach a top speed of ${widget.animal.topSpeed}. ";
    if (widget.animal.distinctiveFeature != 'N/A')
      script +=
          "A very distinctive feature is its ${widget.animal.distinctiveFeature}. ";
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setPitch(1.0);
    await _flutterTts.speak(script);
  }

  void _shareAnimal() {
    final String shareText =
        '''
Discover the ${widget.animal.name}! 🐾\n🔬 Scientific Name: ${widget.animal.scientificName}\n🌍 Locations: ${widget.animal.location}\n⚡ Top Speed: ${widget.animal.topSpeed != 'N/A' ? widget.animal.topSpeed : 'Unknown'}\n\nCooked by Zaddy Digital Solutions 👨🏾‍💻\nhi@zaddyhost.top
''';
    Share.share(shareText);
  }

  // --- NEW: TRIGGER VERSUS MODE ---
  void _triggerVersusMode() {
    final TextEditingController vsController = TextEditingController();
    bool isSearching = false;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Container(
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
                  Text(
                    'Choose Challenger',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Who will face the ${widget.animal.name}?',
                    style: GoogleFonts.poppins(color: Colors.white54),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF121212),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: _accentColor),
                    ),
                    child: TextField(
                      controller: vsController,
                      style: GoogleFonts.poppins(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'e.g., Lion, Bear...',
                        hintStyle: GoogleFonts.poppins(color: Colors.white38),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  isSearching
                      ? CircularProgressIndicator(color: _accentColor)
                      : ElevatedButton(
                          onPressed: () async {
                            if (vsController.text.isEmpty) return;
                            setModalState(() {
                              isSearching = true;
                            });
                            final results = await ApiService.fetchAnimals(
                              vsController.text,
                            );
                            setModalState(() {
                              isSearching = false;
                            });

                            if (results.isNotEmpty) {
                              Navigator.pop(context); // Close modal
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => VersusScreen(
                                    animal1: widget.animal,
                                    animal2: results.first,
                                  ),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Challenger not found!'),
                                  backgroundColor: Colors.redAccent,
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _accentColor,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: Text(
                            'Battle!',
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF121212),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleVoice,
        backgroundColor: _accentColor,
        elevation: 8,
        child: Icon(
          _isPlaying ? Icons.stop_rounded : Icons.volume_up_rounded,
          color: Colors.white,
          size: 28,
        ),
      ).animate().scale(delay: 600.ms, curve: Curves.easeOutBack),

      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 400.0,
            pinned: true,
            backgroundColor: const Color(0xFF121212),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              // NEW: The Versus Button (Swords icon)
              IconButton(
                icon: Icon(Icons.sports_kabaddi, color: _accentColor),
                onPressed: _triggerVersusMode,
              ).animate().fade(delay: 300.ms),
              IconButton(
                icon: Icon(
                  _isFavorite ? Icons.bookmark : Icons.bookmark_border,
                  color: _isFavorite ? _accentColor : Colors.white,
                ),
                onPressed: _toggleFavorite,
              ).animate().fade(delay: 400.ms),
              IconButton(
                icon: const Icon(Icons.ios_share, color: Colors.white),
                onPressed: _shareAnimal,
              ).animate().fade(delay: 500.ms),
            ],
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
              title: Text(
                widget.animal.name,
                style: GoogleFonts.spaceGrotesk(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      offset: const Offset(0, 2),
                      blurRadius: 10.0,
                      color: Colors.black.withOpacity(0.8),
                    ),
                  ],
                ),
              ),
              background: Hero(
                tag: widget.heroTag,
                child: widget.animal.gallery.length <= 1
                    ? _buildSingleImage(widget.animal.imageUrl)
                    : Stack(
                        fit: StackFit.expand,
                        children: [
                          PageView.builder(
                            itemCount: widget.animal.gallery.length,
                            onPageChanged: (index) {
                              setState(() => _currentImageIndex = index);
                              _extractColor();
                            },
                            itemBuilder: (context, index) =>
                                _buildSingleImage(widget.animal.gallery[index]),
                          ),
                          Positioned(
                            bottom: 20,
                            right: 20,
                            child: Row(
                              children: List.generate(
                                widget.animal.gallery.length,
                                (index) => AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  height: 8,
                                  width: _currentImageIndex == index ? 24 : 8,
                                  decoration: BoxDecoration(
                                    color: _currentImageIndex == index
                                        ? _accentColor
                                        : Colors.white54,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.animal.scientificName,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      color: _accentColor,
                      fontStyle: FontStyle.italic,
                    ),
                  ).animate().fade(duration: 500.ms).slideX(),
                  const SizedBox(height: 20),
                  if (widget.animal.slogan.isNotEmpty) ...[
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _accentColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: _accentColor.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.format_quote, color: _accentColor),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              widget.animal.slogan,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.white,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ).animate().fade(delay: 100.ms).slideY(begin: 0.2, end: 0),
                    const SizedBox(height: 24),
                  ],
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          Icons.speed,
                          'Top Speed',
                          widget.animal.topSpeed,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                          Icons.restaurant,
                          'Diet',
                          widget.animal.diet,
                        ),
                      ),
                    ],
                  ).animate().fade(delay: 200.ms).slideY(begin: 0.2, end: 0),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          Icons.monitor_weight_outlined,
                          'Weight',
                          widget.animal.weight,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                          Icons.favorite_border,
                          'Lifespan',
                          widget.animal.lifespan,
                        ),
                      ),
                    ],
                  ).animate().fade(delay: 300.ms).slideY(begin: 0.2, end: 0),

                  const SizedBox(height: 32),
                  _buildSectionTitle('Characteristics'),
                  const SizedBox(height: 16),
                  _buildInfoRow(
                    Icons.star_border,
                    'Distinctive Feature',
                    widget.animal.distinctiveFeature,
                  ),
                  _buildInfoRow(
                    Icons.child_care,
                    'Name of Young',
                    widget.animal.nameOfYoung,
                  ),
                  _buildInfoRow(
                    Icons.texture,
                    'Skin Type',
                    widget.animal.skinType,
                  ),
                  _buildInfoRow(
                    Icons.color_lens_outlined,
                    'Color',
                    widget.animal.color,
                  ),
                  _buildInfoRow(
                    Icons.public,
                    'Locations',
                    widget.animal.location,
                  ),
                  _buildInfoRow(
                    Icons.landscape,
                    'Habitat',
                    widget.animal.habitat,
                  ),
                  _buildInfoRow(Icons.bug_report, 'Prey', widget.animal.prey),
                  _buildInfoRow(
                    Icons.warning_amber_rounded,
                    'Biggest Threat',
                    widget.animal.biggestThreat,
                  ),
                  _buildInfoRow(
                    Icons.wb_sunny_outlined,
                    'Lifestyle',
                    widget.animal.lifestyle,
                  ),

                  const SizedBox(height: 32),
                  _buildSectionTitle('Taxonomy'),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _buildTaxonomyChip('Kingdom', widget.animal.kingdom),
                      _buildTaxonomyChip('Phylum', widget.animal.phylum),
                      _buildTaxonomyChip('Class', widget.animal.animalClass),
                      _buildTaxonomyChip('Family', widget.animal.family),
                    ],
                  ).animate().fade(delay: 500.ms).slideY(begin: 0.2, end: 0),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSingleImage(String url) => url == 'local_fallback'
      ? Image.asset('assets/images/fallback.jpg', fit: BoxFit.cover)
      : CachedNetworkImage(
          imageUrl: url,
          fit: BoxFit.cover,
          placeholder: (c, u) => Container(color: Colors.grey[900]),
          errorWidget: (c, u, e) =>
              Image.asset('assets/images/fallback.jpg', fit: BoxFit.cover),
        );
  Widget _buildSectionTitle(String title) => Text(
    title,
    style: GoogleFonts.spaceGrotesk(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
  ).animate().fade(delay: 400.ms).slideX();
  Widget _buildInfoRow(IconData icon, String title, String value) {
    if (value == 'N/A' || value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: _accentColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.white54,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ).animate().fade(delay: 450.ms),
    );
  }

  Widget _buildTaxonomyChip(String label, String value) {
    if (value == 'N/A' || value.isEmpty) return const SizedBox.shrink();
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(fontSize: 10, color: _accentColor),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(IconData icon, String title, String value) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: _accentColor, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.white54,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
