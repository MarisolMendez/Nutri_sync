import 'package:equatable/equatable.dart';

class ProfileEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? photoUrl;
  final double? weightKg;
  final double? heightCm;
  final DateTime? dateOfBirth;
  final String? gender;
  final int dailyWaterGoalMl;

  const ProfileEntity({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl,
    this.weightKg,
    this.heightCm,
    this.dateOfBirth,
    this.gender,
    this.dailyWaterGoalMl = 2000,
  });

  @override
  List<Object?> get props => [
        id, name, email, photoUrl,
        weightKg, heightCm, dateOfBirth, gender, dailyWaterGoalMl,
      ];
}