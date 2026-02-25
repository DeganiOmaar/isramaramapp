import 'dart:convert';
import 'package:get/get.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class AuthController extends GetxController {
  final ApiService _api = ApiService();

  final Rxn<UserModel> _user = Rxn<UserModel>();
  final _isLoading = false.obs;
  final _initialized = false.obs;

  UserModel? get user => _user.value;
  bool get isLoading => _isLoading.value;
  bool get isLoggedIn => _user.value != null && _api.token != null;
  bool get isRegistrationComplete => _user.value?.registrationComplete ?? false;
  @override
  bool get initialized => _initialized.value;
  bool get isFournisseur => _user.value?.role == 'fournisseur';

  @override
  void onInit() {
    super.onInit();
    init();
  }

  Future<void> init() async {
    if (_initialized.value) return;
    _initialized.value = true;
    final token = await StorageService.getToken();
    if (token == null || token.isEmpty) {
      update();
      return;
    }
    _api.setToken(token);
    try {
      final res = await _api.get('/auth/me');
      final u = res['user'];
      if (u != null) {
        _user.value = UserModel.fromJson(Map<String, dynamic>.from(u));
      }
    } catch (_) {
      await logout();
    }
    update();
  }

  Future<String?> register(String nom, String prenom, String email, String password) async {
    _isLoading.value = true;
    update();
    try {
      await _api.post('/auth/register', {
        'nom': nom,
        'prenom': prenom,
        'email': email,
        'password': password,
      });
      _isLoading.value = false;
      update();
      return null;
    } on ApiException catch (e) {
      _isLoading.value = false;
      update();
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
    _isLoading.value = true;
    update();
    try {
      final res = await _api.post('/auth/verify-otp', {'email': email, 'otp': otp});
      _api.setToken(res['token']);
      await StorageService.saveToken(res['token']);
      _user.value = UserModel.fromJson(Map<String, dynamic>.from(res['user']));
      await StorageService.saveUserJson(jsonEncode(res['user']));
      _isLoading.value = false;
      update();
      return null;
    } on ApiException catch (e) {
      _isLoading.value = false;
      update();
      return e.message;
    }
  }

  Future<String?> login(String email, String password) async {
    _isLoading.value = true;
    update();
    try {
      final res = await _api.post('/auth/login', {'email': email, 'password': password});
      _api.setToken(res['token']);
      await StorageService.saveToken(res['token']);
      _user.value = UserModel.fromJson(Map<String, dynamic>.from(res['user']));
      await StorageService.saveUserJson(jsonEncode(res['user']));
      _isLoading.value = false;
      update();
      return null;
    } on ApiException catch (e) {
      _isLoading.value = false;
      update();
      return e.message;
    }
  }

  Future<String?> chooseRole(String role) async {
    _isLoading.value = true;
    update();
    try {
      final res = await _api.post('/auth/choose-role', {'role': role});
      _api.setToken(res['token']);
      await StorageService.saveToken(res['token']);
      _user.value = UserModel.fromJson(Map<String, dynamic>.from(res['user']));
      await StorageService.saveUserJson(jsonEncode(res['user']));
      _isLoading.value = false;
      update();
      return null;
    } on ApiException catch (e) {
      _isLoading.value = false;
      update();
      return e.message;
    }
  }

  Future<String?> updateFournisseurInfo({
    required String societeNom,
    required String produitAVendre,
    required String descriptionActivite,
  }) async {
    _isLoading.value = true;
    update();
    try {
      final res = await _api.post('/auth/fournisseur-info', {
        'societeNom': societeNom,
        'produitAVendre': produitAVendre,
        'descriptionActivite': descriptionActivite,
      });
      _api.setToken(res['token']);
      await StorageService.saveToken(res['token']);
      _user.value = UserModel.fromJson(Map<String, dynamic>.from(res['user']));
      await StorageService.saveUserJson(jsonEncode(res['user']));
      _isLoading.value = false;
      update();
      return null;
    } on ApiException catch (e) {
      _isLoading.value = false;
      update();
      return e.message;
    }
  }

  Future<void> logout() async {
    _user.value = null;
    _api.setToken(null);
    await StorageService.removeToken();
    update();
  }
}
