import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class AuthController extends ChangeNotifier {
  final ApiService _api = ApiService();
  
  UserModel? _user;
  bool _isLoading = false;
  bool _initialized = false;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _user != null && _api.token != null;
  bool get isRegistrationComplete => _user?.registrationComplete ?? false;
  bool get initialized => _initialized;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    final token = await StorageService.getToken();
    if (token == null || token.isEmpty) {
      notifyListeners();
      return;
    }
    _api.setToken(token);
    try {
      final res = await _api.get('/auth/me');
      final u = res['user'];
      if (u != null) {
        _user = UserModel.fromJson(Map<String, dynamic>.from(u));
      }
    } catch (_) {
      await logout();
    }
    notifyListeners();
  }

  Future<String?> register(String nom, String prenom, String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await _api.post('/auth/register', {
        'nom': nom,
        'prenom': prenom,
        'email': email,
        'password': password,
      });
      _isLoading = false;
      notifyListeners();
      return null;
    } on ApiException catch (e) {
      _isLoading = false;
      notifyListeners();
      return e.message;
    }
  }

  Future<String?> resendOtp(String email) async {
    try {
      await _api.post('/auth/resend-otp', {'email': email});
      return null;
    } on ApiException catch (e) {
      return e.message;
    }
  }

  Future<String?> verifyOtp(String email, String otp) async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await _api.post('/auth/verify-otp', {
        'email': email,
        'otp': otp,
      });
      _api.setToken(res['token']);
      await StorageService.saveToken(res['token']);
      _user = UserModel.fromJson(Map<String, dynamic>.from(res['user']));
      await StorageService.saveUserJson(jsonEncode(res['user']));
      _isLoading = false;
      notifyListeners();
      return null;
    } on ApiException catch (e) {
      _isLoading = false;
      notifyListeners();
      return e.message;
    }
  }

  Future<String?> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await _api.post('/auth/login', {
        'email': email,
        'password': password,
      });
      _api.setToken(res['token']);
      await StorageService.saveToken(res['token']);
      _user = UserModel.fromJson(Map<String, dynamic>.from(res['user']));
      await StorageService.saveUserJson(jsonEncode(res['user']));
      _isLoading = false;
      notifyListeners();
      return null;
    } on ApiException catch (e) {
      _isLoading = false;
      notifyListeners();
      return e.message;
    }
  }

  Future<String?> chooseRole(String role) async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await _api.post('/auth/choose-role', {'role': role});
      _api.setToken(res['token']);
      await StorageService.saveToken(res['token']);
      _user = UserModel.fromJson(Map<String, dynamic>.from(res['user']));
      await StorageService.saveUserJson(jsonEncode(res['user']));
      _isLoading = false;
      notifyListeners();
      return null;
    } on ApiException catch (e) {
      _isLoading = false;
      notifyListeners();
      return e.message;
    }
  }

  Future<String?> updateFournisseurInfo({
    required String societeNom,
    required String produitAVendre,
    required String descriptionActivite,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await _api.post('/auth/fournisseur-info', {
        'societeNom': societeNom,
        'produitAVendre': produitAVendre,
        'descriptionActivite': descriptionActivite,
      });
      _api.setToken(res['token']);
      await StorageService.saveToken(res['token']);
      _user = UserModel.fromJson(Map<String, dynamic>.from(res['user']));
      await StorageService.saveUserJson(jsonEncode(res['user']));
      _isLoading = false;
      notifyListeners();
      return null;
    } on ApiException catch (e) {
      _isLoading = false;
      notifyListeners();
      return e.message;
    }
  }

  Future<void> logout() async {
    _user = null;
    _api.setToken(null);
    await StorageService.removeToken();
    notifyListeners();
  }
}
