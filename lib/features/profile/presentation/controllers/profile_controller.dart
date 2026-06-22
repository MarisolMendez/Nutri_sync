import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/providers.dart';
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

  static const _tempUserId = 'user_1';

  @override
  ProfileState build() {
    _getProfile = sl();
    _updateProfile = sl();
    return const ProfileInitial();
  }

  Future<void> load() async {
    state = const ProfileLoading();

    final result = await _getProfile(
      const ProfileParams(userId: _tempUserId),
    );

    result.fold(
      (failure) => state = ProfileError(failure.message),
      (profile) {
        if (profile == null) {
          state = const ProfileError('Perfil no encontrado');
        } else {
          state = ProfileLoaded(profile: profile);
        }
      },
    );
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
