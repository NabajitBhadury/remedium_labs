import 'package:flutter/material.dart';
import '../models/lab_test.dart';
import '../services/api_service.dart';

class LabTestProvider extends ChangeNotifier {
  List<LabTest> _tests = [];
  bool _isLoading = false;
  String? _error;

  List<LabTest> get tests => _tests;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// All unique test types/categories from fetched data
  List<String> get categories {
    final types = _tests.map((t) => t.type).toSet().toList()..sort();
    return ['All', ...types];
  }

  Future<void> fetchTests() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final result = await ApiService.getTests(limit: 200);
      debugPrint('fetchTests raw result: $result');
      if (result['success'] == true) {
        final data = result['data'] as List<dynamic>? ?? [];
        debugPrint('fetchTests data count: ${data.length}');
        _tests = [];
        for (int i = 0; i < data.length; i++) {
          try {
            _tests.add(LabTest.fromJson(data[i] as Map<String, dynamic>));
          } catch (e) {
            debugPrint('LabTest.fromJson error at index $i: $e | raw: ${data[i]}');
          }
        }
        debugPrint('fetchTests parsed ${_tests.length} tests successfully');
      } else {
        _error = result['message']?.toString() ?? 'Failed to load tests';
        debugPrint('fetchTests API error: $_error');
      }
    } catch (e) {
      _error = 'Network error: $e';
      debugPrint('Error fetching tests: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
