import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/family_member.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  static const _keyUser = 'session_user';
  static const _keyLoggedIn = 'session_logged_in';

  bool _isAuthenticated = false;
  User? _user;
  List<FamilyMember> _familyMembers = [];
  bool _isFamilyLoading = false;
  bool _isRestoringSession = true; // true while reading SharedPreferences

  bool get isAuthenticated => _isAuthenticated;
  bool get isRestoringSession => _isRestoringSession;
  User? get user => _user;
  int? get userId => _user?.id;
  String? get userName => _user?.name;
  String? get userPhone => _user?.phone;
  String? get userGender => _user?.gender;
  String? get userEmail => _user?.email;

  List<FamilyMember> get familyMembers => _familyMembers;
  bool get isFamilyLoading => _isFamilyLoading;

  // ─── Session Persistence ───────────────────────────────────────────────────

  /// Call once at app startup (e.g. from SplashScreen or main) to restore
  /// a previously saved login session from SharedPreferences.
  Future<void> tryRestoreSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final loggedIn = prefs.getBool(_keyLoggedIn) ?? false;
      final userJson = prefs.getString(_keyUser);
      if (loggedIn && userJson != null) {
        _user = User.fromJson(
          jsonDecode(userJson) as Map<String, dynamic>,
        );
        _isAuthenticated = true;
        // Silently refresh family members in background
        _fetchFamilyMembersInBackground();
      }
    } catch (e) {
      debugPrint('Session restore error: $e');
    } finally {
      _isRestoringSession = false;
      notifyListeners();
    }
  }

  Future<void> _saveSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyLoggedIn, true);
      await prefs.setString(_keyUser, jsonEncode(_user!.toJson()));
    } catch (e) {
      debugPrint('Session save error: $e');
    }
  }

  Future<void> _clearSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyLoggedIn);
      await prefs.remove(_keyUser);
    } catch (e) {
      debugPrint('Session clear error: $e');
    }
  }

  // ─── Auth ──────────────────────────────────────────────────────────────────

  Future<String?> login(String phone, String password) async {
    final result = await ApiService.login(phone, password);
    if (result['success'] == true) {
      _user = User.fromJson(result['data'] as Map<String, dynamic>);
      _isAuthenticated = true;
      notifyListeners();
      await _saveSession();
      // Fetch family members silently after login
      _fetchFamilyMembersInBackground();
      return null; // null = success
    }
    return result['message']?.toString() ?? 'Login failed';
  }

  Future<String?> register(
    String name,
    String phone,
    String email,
    int age,
    String password, {
    String gender = 'Male',
  }) async {
    final result = await ApiService.register(name, phone, email, age, gender, password);
    if (result['success'] == true) {
      _user = User.fromJson(result['data'] as Map<String, dynamic>);
      _isAuthenticated = true;
      _familyMembers = [];
      notifyListeners();
      await _saveSession();
      return null;
    }
    return result['message']?.toString() ?? 'Registration failed';
  }

  Future<void> logout() async {
    _isAuthenticated = false;
    _user = null;
    _familyMembers = [];
    notifyListeners();
    await _clearSession();
  }

  // ─── Profile ───────────────────────────────────────────────────────────────

  Future<String?> updateProfile({
    String? name,
    String? phone,
    String? gender,
  }) async {
    if (_user == null) return 'Not authenticated';
    final result = await ApiService.updateProfile(
      _user!.id,
      name: name,
      phone: phone,
      gender: gender,
    );
    if (result['success'] == true) {
      _user = User.fromJson(result['data'] as Map<String, dynamic>);
      notifyListeners();
      await _saveSession(); // persist updated profile
      return null;
    }
    return result['message']?.toString() ?? 'Update failed';
  }

  // ─── Family Members ────────────────────────────────────────────────────────

  Future<void> fetchFamilyMembers() async {
    if (_user == null) return;
    _isFamilyLoading = true;
    notifyListeners();
    try {
      final result = await ApiService.getFamilyMembers(_user!.id);
      if (result['success'] == true) {
        final data = result['data'] as List<dynamic>? ?? [];
        _familyMembers = data
            .map((e) => FamilyMember.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      debugPrint('Error fetching family members: $e');
    } finally {
      _isFamilyLoading = false;
      notifyListeners();
    }
  }

  void _fetchFamilyMembersInBackground() {
    fetchFamilyMembers();
  }

  Future<String?> addFamilyMember(FamilyMember member) async {
    if (_user == null) return 'Not authenticated';
    final result = await ApiService.addFamilyMember(
      userId: _user!.id,
      name: member.name,
      relation: member.relation,
      gender: member.gender,
      age: int.tryParse(member.age) ?? 0,
      phone: member.phone,
    );
    if (result['success'] == true) {
      // Refresh list from server
      await fetchFamilyMembers();
      return null;
    }
    return result['message']?.toString() ?? 'Failed to add member';
  }

  Future<String?> removeFamilyMember(String memberId) async {
    if (_user == null) return 'Not authenticated';
    final result = await ApiService.deleteFamilyMember(
      memberId: int.tryParse(memberId) ?? 0,
      userId: _user!.id,
    );
    if (result['success'] == true) {
      _familyMembers.removeWhere((m) => m.id == memberId);
      notifyListeners();
      return null;
    }
    return result['message']?.toString() ?? 'Failed to remove member';
  }
}
