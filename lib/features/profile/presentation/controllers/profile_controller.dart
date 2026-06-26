import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/daos/user_dao.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../auth/domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/get_profile_usecase.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import 'profile_state.dart';

final profileControllerProvider =
    NotifierProvider<ProfileController, ProfileState>(
  ProfileController.new,
);

class ProfileController extends Notifier<ProfileState> {
  late final GetProfileUseCase _getProfile;
  late final UpdateProfileUseCase _updateProfile;
  late final GetCurrentUserUseCase _getCurrentUser;
  late final UserDao _userDao;

  static const _tempUserId = 'user_1';

  @override
  ProfileState build() {
    _getProfile = sl();
    _updateProfile = sl();
    _getCurrentUser = sl();
    _userDao = sl();
    return const ProfileInitial();
  }

  Future<void> load() async {
    state = const ProfileLoading();

    final result = await _getProfile(
      const ProfileParams(userId: _tempUserId),
    );

    await result.fold(
      (failure) async => state = ProfileError(failure.message),
      (profile) async {
        if (profile == null) {
          // Fallback: intentar leer el usuario desde SharedPreferences
          // y sincronizarlo a SQLite automáticamente.
          await _syncFromSharedPrefs();
          // Reintentar la carga del perfil desde SQLite
          final retry = await _getProfile(
            const ProfileParams(userId: _tempUserId),
          );
          retry.fold(
            (failure) => state = ProfileError(failure.message),
            (retryProfile) {
              if (retryProfile == null) {
                state = const ProfileError('Perfil no encontrado');
              } else {
                state = ProfileLoaded(profile: retryProfile);
              }
            },
          );
        } else {
          state = ProfileLoaded(profile: profile);
        }
      },
    );
  }

  /// Si el usuario existe en SharedPreferences (AuthLocalDatasource)
  /// pero no en SQLite, lo sincroniza automáticamente.
  Future<void> _syncFromSharedPrefs() async {
    final userResult = await _getCurrentUser(const NoParams());
    userResult.fold((_) => null, (user) {
      if (user != null) {
        _userDao.createOrUpdate(
          id: user.id,
          email: user.email,
          name: user.name,
          createdAt: user.createdAt,
          updatedAt: DateTime.now(),
        );
      }
    });
  }

  void toggleEditing() {
    if (state is ProfileLoaded) {
      final current = state as ProfileLoaded;
      state = current.copyWith(isEditing: !current.isEditing, saved: false);
    }
  }

  Future<void> save({
    required String name,
    double? weightKg,
    double? heightCm,
  }) async {
    final result = await _updateProfile(
      UpdateProfileParams(
        userId: _tempUserId,
        name: name,
        weightKg: weightKg,
        heightCm: heightCm,
      ),
    );

    result.fold(
      (failure) => state = ProfileError(failure.message),
      (_) => load(),
    );
  }
}
