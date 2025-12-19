class Monkey {
  final String name;
  final String scientificName;
  final String imagePath;
  final String description;
  final String lifespan;
  final String place;
  final String diet;
  final String habitat;
  final double latitude;
  final double longitude;

  const Monkey({
    required this.name,
    required this.scientificName,
    required this.imagePath,
    required this.description,
    required this.lifespan,
    required this.place,
    this.diet = "Omnivore",
    this.habitat = "Forest",
    this.latitude = 0.0,
    this.longitude = 0.0,
  });
}

const List<Monkey> monkeyData = [
  Monkey(
    name: "Bald Uakari",
    scientificName: "Cacajao calvus",
    imagePath: "assets/images/bald_uakari.jpg",
    description: "The bald uakari is a small New World monkey characterized by a very short tail; bright, crimson face; a bald head; and long coat.",
    lifespan: "15-20 years",
    place: "Amazon Basin",
    habitat: "Flooded Forests",
    diet: "Seeds & Fruit",
    latitude: -3.4653,
    longitude: -62.2159, // Amazon Basin, Brazil
  ),
  Monkey(
    name: "Common Squirrel Monkey",
    scientificName: "Saimiri sciureus",
    imagePath: "assets/images/common_squirrel_monkey.jpg",
    description: "The common squirrel monkey is a small New World monkey of the family Cebidae, native to the Amazon Basin.",
    lifespan: "15-20 years",
    place: "Amazon Basin",
    habitat: "Tropical Rainforest",
    diet: "Omnivore",
    latitude: -2.0, 
    longitude: -60.0, // Amazon Basin
  ),
  Monkey(
    name: "Japanese Macaque",
    scientificName: "Macaca fuscata",
    imagePath: "assets/images/japanese_macaque.jpg",
    description: "The Japanese macaque is a terrestrial Old World monkey species that is native to Japan. They are also known as snow monkeys.",
    lifespan: "6-30 years",
    place: "Japan",
    habitat: "Broadleaf Forest",
    diet: "Omnivore",
    latitude: 36.2048,
    longitude: 138.2529, // Nagano, Japan (Jigokudani Monkey Park)
  ),
  Monkey(
    name: "Mantled Howler",
    scientificName: "Alouatta palliata",
    imagePath: "assets/images/mantled_howler_monkey.jpg",
    description: "The mantled howler is a species of howler monkey, a type of New World monkey, from Central and South America. It is one of the monkeys most often seen and heard in the wild in Central America.",
    lifespan: "16-25 years",
    place: "Central & South America",
    habitat: "Rainforest",
    diet: "Herbivore (Leaves)",
    latitude: 10.0,
    longitude: -84.0, // Costa Rica
  ),
  Monkey(
    name: "Nilgiri Langur",
    scientificName: "Semnopithecus johnii",
    imagePath: "assets/images/nilgiri_langur.jpg",
    description: "The Nilgiri langur is a colobine primate containing Old World monkeys found in the Nilgiri Hills of the Western Ghats in South India.",
    lifespan: "20-29 years",
    place: "Western Ghats, India",
    habitat: "Hill Forests",
    diet: "Folivore (Leaves)",
    latitude: 11.4,
    longitude: 76.6, // Nilgiri Hills, India
  ),
  Monkey(
    name: "Panamanian Night Monkey",
    scientificName: "Aotus zonalis",
    imagePath: "assets/images/panamanian_night_monkey.jpg",
    description: "The Panamanian night monkey or Chocoan night monkey is a species of night monkey, a type of New World monkey, found in Panama and Colombia.",
    lifespan: "11-18 years",
    place: "Panama & Colombia",
    habitat: "Cloud Forest",
    diet: "Frugivore",
    latitude: 8.5,
    longitude: -80.0, // Panama
  ),
  Monkey(
    name: "Patas Monkey",
    scientificName: "Erythrocebus patas",
    imagePath: "assets/images/patas_monkey.jpg",
    description: "The patas monkey, also known as the wadi monkey or hussar monkey, is a ground-dwelling monkey distributed over semi-arid areas of West Africa, and into East Africa.",
    lifespan: "12-20 years",
    place: "Central Africa",
    habitat: "Savanna",
    diet: "Omnivore",
    latitude: 10.0,
    longitude: 12.0, // Nigeria/Cameroon area
  ),
  Monkey(
    name: "Pygmy Marmoset",
    scientificName: "Cebuella pygmaea",
    imagePath: "assets/images/pygmy_marmoset.jpg",
    description: "The pygmy marmoset is a small genus of New World monkey native to rainforests of the western Amazon Basin in South America.",
    lifespan: "12-15 years",
    place: "Western Amazon Basin",
    habitat: "Rainforest edges",
    diet: "Gums & Insects",
    latitude: -3.0,
    longitude: -70.0, // Amazon (Peru/Brazil/Colombia border)
  ),
  Monkey(
    name: "Silvery Marmoset",
    scientificName: "Mico argentatus",
    imagePath: "assets/images/silvery_marmoset.jpg",
    description: "The silvery marmoset is a New World monkey that lives in the eastern Amazon Rainforest in Brazil.",
    lifespan: "10-16 years",
    place: "Brazil",
    habitat: "Secondary Forest",
    diet: "Exudativore",
    latitude: -3.0,
    longitude: -55.0, // Tapajos River area, Brazil
  ),
  Monkey(
    name: "White-headed Capuchin",
    scientificName: "Cebus capucinus",
    imagePath: "assets/images/white_headed_capuchin.jpg",
    description: "The white-headed capuchin, also known as the white-faced capuchin or white-throated capuchin, is a medium-sized New World monkey of the family Cebidae, subfamily Cebinae.",
    lifespan: "25-50 years",
    place: "Central America",
    habitat: "Forests",
    diet: "Omnivore",
    latitude: 9.0,
    longitude: -83.5, // Costa Rica
  ),
];
