import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../auth/presentation/controllers/auth_state.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import 'profile_state.dart';

final profileControllerProvider =
    NotifierProvider<ProfileController, ProfileState>(
  ProfileController.new,
);

class ProfileController extends Notifier<ProfileState> {
  late final UpdateProfileUseCase _updateProfile;
  late final ApiClient _client;

  @override
  ProfileState build() {
    _updateProfile = sl();
    _client = sl();
    return const ProfileInitial();
  }

  Future<void> load() async {
    state = const ProfileLoading();

    final authState = ref.read(authControllerProvider);
    if (authState is AuthAuthenticated) {
      final user = authState.user;
      double? weightKg;
      double? heightCm;
      String? gender;
      DateTime? dateOfBirth;

      try {
        final response = await _client.get(ApiEndpoints.clinicalRecordMetrics);
        final body = response.data as Map<String, dynamic>?;
        if (body?['success'] == true && body?['data'] is Map) {
          final data = body!['data'] as Map<String, dynamic>;
          weightKg = num.tryParse(data['weightKg']?.toString() ?? '')?.toDouble();
          heightCm = num.tryParse(data['heightCm']?.toString() ?? '')?.toDouble();
          gender = data['sex']?.toString() == 'Masculino' ? 'male' : data['sex']?.toString() == 'Femenino' ? 'female' : null;
          // dateOfBirth no se guarda actualmente en el ClinicalRecord flat
        }
      } catch (_) {}

      state = ProfileLoaded(profile: ProfileEntity(
        id: user.id,
        name: user.name,
        email: user.email,
        photoUrl: user.photoUrl,
        weightKg: weightKg,
        heightCm: heightCm,
        gender: gender,
        dateOfBirth: dateOfBirth,
      ));
      return;
    }

    state = const ProfileError('Perfil no encontrado');
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
    DateTime? dateOfBirth,
    String? gender,
  }) async {
    final authState = ref.read(authControllerProvider);
    if (authState is! AuthAuthenticated) return;

    final user = authState.user;

    final result = await _updateProfile(
      UpdateProfileParams(
        userId: user.id,
        name: name,
        weightKg: weightKg,
        heightCm: heightCm,
      ),
    );

    if (weightKg != null && heightCm != null && weightKg > 0 && heightCm > 0) {
      try {
        await _client.post(ApiEndpoints.clinicalRecordMetrics, data: {
          'name': name,
          'weightKg': weightKg,
          'heightCm': heightCm,
          'dateOfBirth': dateOfBirth?.toIso8601String(),
          'gender': gender,
        });
      } catch (_) {}
    }

    result.fold(
      (failure) => state = ProfileError(failure.message),
      (_) => load(),
    );
  }
}