import '../../domain/entities/hydration_entity.dart';

class HydrationModel extends HydrationEntity {
  const HydrationModel({
    required super.id,
    required super.userId,
    required super.amountMl,
    required super.loggedAt,
  });

  factory HydrationModel.fromLocal(dynamic data) {
    return HydrationModel(
      id: data.id,
      userId: data.userId,
      amountMl: data.amountMl,
      loggedAt: data.loggedAt,
    );
  }
}