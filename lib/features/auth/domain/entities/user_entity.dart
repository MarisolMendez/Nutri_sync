import 'package:equatable/equatable.dart';

/// Entidad de usuario — vive en domain, no sabe nada de Firebase ni de Drift.
/// Es el contrato puro de lo que es un usuario para la app.
class UserEntity extends Equatable {
  final String id;
  final String email;
  final String name;
  final String role;
  final String? photoUrl;
  final double? weightKg;
  final double? heightCm;
  final int dailyWaterGoalMl;
  final DateTime createdAt;

  const UserEntity({
    required this.id,
    required this.email,
    required this.name,
    this.role = 'patient',
    this.photoUrl,
    this.weightKg,
    this.heightCm,
    this.dailyWaterGoalMl = 2000,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        email,
        name,
        role,
        photoUrl,
        weightKg,
        heightCm,
        dailyWaterGoalMl,
        createdAt,
      ];
}
