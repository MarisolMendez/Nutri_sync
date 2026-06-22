import '../../domain/entities/profile_entity.dart';

class ProfileModel extends ProfileEntity {
  const ProfileModel({
    required super.id,
    required super.name,
    required super.email,
    super.photoUrl,
    super.weightKg,
    super.heightCm,
    super.dailyWaterGoalMl,
  });

  factory ProfileModel.fromLocal(dynamic data) {
    return ProfileModel(
      id: data.id,
      name: data.name,
      email: data.email,
      photoUrl: data.photoUrl,
      weightKg: data.weightKg,
      heightCm: data.heightCm,
      dailyWaterGoalMl: data.dailyWaterGoalMl,
    );
  }
}