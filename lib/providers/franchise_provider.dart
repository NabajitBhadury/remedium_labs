import 'package:flutter/material.dart';
import '../models/franchise.dart';
import '../services/api_service.dart';

class FranchiseProvider extends ChangeNotifier {
  List<Franchise> _franchises = [];
  bool _isLoading = false;
  String? _error;

  List<Franchise> get franchises => _franchises;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// All unique cities from fetched franchises
  List<String> get cities {
    final uniqueCities = _franchises
        .map((f) => f.city)
        .where((c) => c.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    return uniqueCities;
  }

  Future<void> fetchFranchises({String? q, String? city}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final result = await ApiService.getAllFranchises(
        limit: 100,
        q: q,
        city: city,
      );
      if (result['success'] == true) {
        final data = result['data'] as List<dynamic>? ?? [];
        _franchises = data
            .map((e) => Franchise.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        _error = result['message']?.toString() ?? 'Failed to load franchises';
      }
    } catch (e) {
      _error = 'Network error: $e';
      debugPrint('Error fetching franchises: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Franchise?> viewFranchise(String franchiseId) async {
    try {
      final result = await ApiService.viewFranchise(franchiseId);
      if (result['success'] == true) {
        return Franchise.fromJson(result['data'] as Map<String, dynamic>);
      }
    } catch (e) {
      debugPrint('Error fetching franchise: $e');
    }
    return null;
  }
}
