import 'package:equatable/equatable.dart';

class ProfileEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? photoUrl;
  final double? weightKg;
  final double? heightCm;
  final int dailyWaterGoalMl;

  const ProfileEntity({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl,
    this.weightKg,
    this.heightCm,
    this.dailyWaterGoalMl = 2000,
  });

  @override
  List<Object?> get props => [
        id, name, email, photoUrl,
        weightKg, heightCm, dailyWaterGoalMl,
      ];
}