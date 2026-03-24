import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/animal_model.dart';

class VersusScreen extends StatelessWidget {
  final Animal animal1;
  final Animal animal2;

  const VersusScreen({super.key, required this.animal1, required this.animal2});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Versus Mode',
          style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // The Fighters!
              Row(
                children: [
                  Expanded(child: _buildFighterHeader(animal1)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'VS',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF00E676),
                      ),
                    ),
                  ).animate().scale(delay: 500.ms, curve: Curves.elasticOut),
                  Expanded(child: _buildFighterHeader(animal2)),
                ],
              ),
              const SizedBox(height: 40),

              // The Stats Table
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white10),
                ),
                child: Column(
                  children: [
                    _buildStatRow(
                      'Top Speed',
                      animal1.topSpeed,
                      animal2.topSpeed,
                    ),
                    _buildDivider(),
                    _buildStatRow('Weight', animal1.weight, animal2.weight),
                    _buildDivider(),
                    _buildStatRow(
                      'Lifespan',
                      animal1.lifespan,
                      animal2.lifespan,
                    ),
                    _buildDivider(),
                    _buildStatRow('Diet', animal1.diet, animal2.diet),
                    _buildDivider(),
                    _buildStatRow(
                      'Biggest Threat',
                      animal1.biggestThreat,
                      animal2.biggestThreat,
                    ),
                  ],
                ),
              ).animate().fade(delay: 300.ms).slideY(begin: 0.2, end: 0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFighterHeader(Animal animal) {
    return Column(
      children: [
        Container(
          height: 120,
          width: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF00E676), width: 3),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00E676).withOpacity(0.3),
                blurRadius: 15,
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: animal.imageUrl == 'local_fallback'
              ? Image.asset('assets/images/fallback.jpg', fit: BoxFit.cover)
              : CachedNetworkImage(
                  imageUrl: animal.imageUrl,
                  fit: BoxFit.cover,
                ),
        ),
        const SizedBox(height: 12),
        Text(
          animal.name,
          textAlign: TextAlign.center,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    ).animate().fade(duration: 400.ms).scale();
  }

  Widget _buildStatRow(String label, String val1, String val2) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
      child: Column(
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: const Color(0xFF00E676),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  val1,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(height: 30, width: 1, color: Colors.white10),
              Expanded(
                child: Text(
                  val2,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() => Divider(color: Colors.white10, height: 1);
}
