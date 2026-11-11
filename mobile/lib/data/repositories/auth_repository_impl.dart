import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/remote/api_client.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<User?> currentUser() async {
    final json = await _apiClient.get('/auth/me');
    if (json.isEmpty) {
      return null;
    }
    return UserModel.fromJson(json).toEntity();
  }

  @override
  Future<User> login(String email, String password) async {
    final json = await _apiClient.post(
      '/auth/login',
      data: {'email': email, 'password': password},
    );
    return UserModel.fromJson(json).toEntity();
  }

  @override
  Future<void> logout() async {
    await _apiClient.post('/auth/logout');
  }
}
