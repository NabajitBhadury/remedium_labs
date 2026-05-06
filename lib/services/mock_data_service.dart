import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../models/disease.dart';
import '../models/banner_model.dart';
import '../models/organ.dart';

/// MockDataService now ONLY provides data for entities that have NO backend API:
/// - Banners (promotional)
/// - Organs (organ-based navigation)
/// - Diseases  (disease-based navigation)
/// - Popular Services (pre-defined health package listings)
///
/// ALL entities with a backend API (Labs/Franchises, Bookings, Tests, Auth,
/// Profile, Family Members, Coupons) are handled by their respective
/// Providers + ApiService. Do NOT add mock API-backed data here.
class MockDataService {
  static final List<Disease> diseases = [
    Disease(
      name: 'Fever',
      icon: FontAwesomeIcons.temperatureHigh,
      color: Colors.red,
    ),
    Disease(
      name: 'Covid-19',
      icon: FontAwesomeIcons.virus,
      color: Colors.purple,
    ),
    Disease(
      name: 'Diabetes',
      icon: FontAwesomeIcons.syringe,
      color: Colors.blue,
    ),
    Disease(
      name: 'Heart',
      icon: FontAwesomeIcons.heartPulse,
      color: Colors.redAccent,
    ),
    Disease(
      name: 'Kidney',
      icon: FontAwesomeIcons.tablets,
      color: Colors.orange,
    ),
  ];

  Future<List<Disease>> getDiseases() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return diseases;
  }

  Future<List<BannerModel>> getBanners() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return [
      BannerModel(
        title: "Full Body Checkup",
        subtitle: "Get 20% Off today!",
        buttonText: "Book Now",
        imageUrl:
            "https://images.unsplash.com/photo-1576091160399-112ba8d25d1d?auto=format&fit=crop&q=80&w=500",
        gradientColors: [Color(0xFF10217D), Color(0xFF1557B0)],
        buttonColor: Colors.white,
        buttonTextColor: Color(0xFF10217D),
      ),
      BannerModel(
        title: "Health Package",
        subtitle: "Comprehensive health check",
        buttonText: "Learn More",
        imageUrl:
            "https://images.unsplash.com/photo-1579154204601-01588f351e67?auto=format&fit=crop&q=80&w=500",
        gradientColors: [Color(0xFFFF9431), Colors.orange.shade700],
        buttonColor: Colors.white,
        buttonTextColor: Color(0xFFFF9431),
      ),
      BannerModel(
        title: "Covid-19 Test",
        subtitle: "Safe & Fast Results",
        buttonText: "Book Test",
        imageUrl:
            "https://images.unsplash.com/photo-1584036561566-b93241b48581?auto=format&fit=crop&q=80&w=500",
        gradientColors: [Colors.teal, Colors.teal.shade700],
        buttonColor: Colors.white,
        buttonTextColor: Colors.teal,
      ),
    ];
  }

  static final List<Organ> organs = [
    Organ(name: 'Heart', icon: FontAwesomeIcons.heartPulse, color: Colors.red),
    Organ(name: 'Kidney', icon: FontAwesomeIcons.tablets, color: Colors.orange),
    Organ(
      name: 'Liver',
      icon: Icons.bloodtype,
      color: Colors.brown,
    ),
    Organ(name: 'Lungs', icon: FontAwesomeIcons.lungs, color: Colors.blue),
    Organ(name: 'Brain', icon: FontAwesomeIcons.brain, color: Colors.pink),
    Organ(name: 'Stomach', icon: FontAwesomeIcons.burger, color: Colors.green),
  ];

  Future<List<Organ>> getOrgans() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return organs;
  }
}
