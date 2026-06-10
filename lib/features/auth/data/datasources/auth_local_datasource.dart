import '../models/user_model.dart';

abstract class AuthLocalDatasource {
  Future<UserModel?> getCachedUser(String id);
  Future<void> cacheUser(UserModel user);
  Future<void> clearUser(String id);
}

class AuthLocalDatasourceImpl implements AuthLocalDatasource {
  const AuthLocalDatasourceImpl();

  @override
  Future<UserModel?> getCachedUser(String id) async {
    // TODO: Implementar cuando Drift esté disponible
    return null;
  }

  @override
  Future<void> cacheUser(UserModel user) async {
    // TODO: Implementar cuando Drift esté disponible
  }

  @override
  Future<void> clearUser(String id) async {
    // TODO: Implementar cuando Drift esté disponible
  }
}