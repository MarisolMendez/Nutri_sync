import '../../domain/entities/user_entity.dart';

/// Modelo de la capa data — sabe convertirse desde/hacia
/// Firebase (Map) y Drift (UsersTableData).
/// La entidad no sabe nada de esto.
class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    required super.name,
    super.role,
    super.photoUrl,
    super.weightKg,
    super.heightCm,
    super.dailyWaterGoalMl,
    required super.createdAt,
  });

  /// Desde Firestore
  factory UserModel.fromFirestore(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      photoUrl: map['photoUrl'],
      weightKg: (map['weightKg'] as num?)?.toDouble(),
      heightCm: (map['heightCm'] as num?)?.toDouble(),
      dailyWaterGoalMl: map['dailyWaterGoalMl'] ?? 2000,
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  /// Hacia Firestore
  Map<String, dynamic> toFirestore() => {
        'email': email,
        'name': name,
        'photoUrl': photoUrl,
        'weightKg': weightKg,
        'heightCm': heightCm,
        'dailyWaterGoalMl': dailyWaterGoalMl,
        'createdAt': createdAt.toIso8601String(),
      };

  /// Desde Drift (base de datos local)
  factory UserModel.fromLocal(dynamic data) {
    return UserModel(
      id: data.id,
      email: data.email,
      name: data.name,
      photoUrl: data.photoUrl,
      weightKg: data.weightKg,
      heightCm: data.heightCm,
      dailyWaterGoalMl: data.dailyWaterGoalMl,
      createdAt: data.createdAt,
    );
  }

  /// Desde SharedPreferences
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      name: json['name'] as String? ?? '',
      photoUrl: json['photoUrl'] as String?,
      weightKg: (json['weightKg'] as num?)?.toDouble(),
      heightCm: (json['heightCm'] as num?)?.toDouble(),
      dailyWaterGoalMl: json['dailyWaterGoalMl'] is num
          ? (json['dailyWaterGoalMl'] as num).toInt()
          : 2000,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'photoUrl': photoUrl,
      'weightKg': weightKg,
      'heightCm': heightCm,
      'dailyWaterGoalMl': dailyWaterGoalMl,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
