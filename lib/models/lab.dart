import 'service.dart';

final dummyHomeLab = Lab(
  id: 'home_collection',
  name: 'Home Collection',
  address: 'At your doorstep',
  distance: 0.0,
  rating: 5.0,
  imageUrl: 'https://cdn-icons-png.flaticon.com/512/2554/2554978.png',
  services: [],
);

class Lab {
  final String id;
  final String name;
  final String address;
  final double distance;
  final double rating;
  final String imageUrl;
  final List<Service> services;

  Lab({
    required this.id,
    required this.name,
    required this.address,
    required this.distance,
    required this.rating,
    required this.imageUrl,
    required this.services,
  });
}
