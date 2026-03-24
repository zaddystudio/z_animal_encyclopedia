class Animal {
  final String name;
  final String scientificName;
  final String location;
  final String diet;
  final String topSpeed;
  final String lifespan;
  final String weight;
  final String kingdom;
  final String phylum;
  final String animalClass;
  final String family;
  final String prey;
  final String biggestThreat;
  final String habitat;
  final String slogan;
  final String lifestyle;
  final String nameOfYoung;
  final String skinType;
  final String color;
  final String distinctiveFeature;

  String imageUrl;
  List<String> gallery; // NEW: Holds our multiple images!

  Animal({
    required this.name,
    required this.scientificName,
    required this.location,
    required this.diet,
    required this.topSpeed,
    required this.lifespan,
    required this.weight,
    required this.kingdom,
    required this.phylum,
    required this.animalClass,
    required this.family,
    required this.prey,
    required this.biggestThreat,
    required this.habitat,
    required this.slogan,
    required this.lifestyle,
    required this.nameOfYoung,
    required this.skinType,
    required this.color,
    required this.distinctiveFeature,
    this.imageUrl = '',
    this.gallery = const [],
  });

  factory Animal.fromJson(Map<String, dynamic> json) {
    final taxonomy = json['taxonomy'] ?? {};
    final chars = json['characteristics'] ?? {};

    return Animal(
      name: json['name'] ?? 'Unknown Animal',
      scientificName:
          taxonomy['scientific_name'] ??
          json['scientificName'] ??
          'Not specified',
      location:
          (json['locations'] as List?)?.join(', ') ??
          json['location'] ??
          'Not specified',
      diet: chars['diet'] ?? json['diet'] ?? 'N/A',
      topSpeed: chars['top_speed'] ?? json['topSpeed'] ?? 'N/A',
      lifespan: chars['lifespan'] ?? json['lifespan'] ?? 'N/A',
      weight: chars['weight'] ?? json['weight'] ?? 'N/A',
      kingdom: taxonomy['kingdom'] ?? json['kingdom'] ?? 'N/A',
      phylum: taxonomy['phylum'] ?? json['phylum'] ?? 'N/A',
      animalClass: taxonomy['class'] ?? json['animalClass'] ?? 'N/A',
      family: taxonomy['family'] ?? json['family'] ?? 'N/A',
      prey: chars['prey'] ?? json['prey'] ?? 'N/A',
      biggestThreat: chars['biggest_threat'] ?? json['biggestThreat'] ?? 'N/A',
      habitat: chars['habitat'] ?? json['habitat'] ?? 'N/A',
      slogan: chars['slogan'] ?? json['slogan'] ?? '',
      lifestyle: chars['lifestyle'] ?? json['lifestyle'] ?? 'N/A',
      nameOfYoung: chars['name_of_young'] ?? json['nameOfYoung'] ?? 'N/A',
      skinType: chars['skin_type'] ?? json['skinType'] ?? 'N/A',
      color: chars['color'] ?? json['color'] ?? 'N/A',
      distinctiveFeature:
          chars['most_distinctive_feature'] ??
          json['distinctiveFeature'] ??
          'N/A',
      imageUrl: json['imageUrl'] ?? '',
      gallery: List<String>.from(json['gallery'] ?? []),
    );
  }

  // NEW: Converts the object to a map so we can save it to the hard drive
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'scientificName': scientificName,
      'location': location,
      'diet': diet,
      'topSpeed': topSpeed,
      'lifespan': lifespan,
      'weight': weight,
      'kingdom': kingdom,
      'phylum': phylum,
      'animalClass': animalClass,
      'family': family,
      'prey': prey,
      'biggestThreat': biggestThreat,
      'habitat': habitat,
      'slogan': slogan,
      'lifestyle': lifestyle,
      'nameOfYoung': nameOfYoung,
      'skinType': skinType,
      'color': color,
      'distinctiveFeature': distinctiveFeature,
      'imageUrl': imageUrl,
      'gallery': gallery,
    };
  }
}
