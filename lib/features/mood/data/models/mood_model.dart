import '../../domain/entities/mood_entity.dart';

class MoodModel extends MoodEntity {
  const MoodModel({
    required super.id,
    required super.userId,
    required super.mood,
    super.note,
    required super.loggedAt,
  });

  factory MoodModel.fromLocal(dynamic data) {
    return MoodModel(
      id: data.id,
      userId: data.userId,
      mood: MoodValue.fromString(data.moodValue),
      note: data.note,
      loggedAt: data.loggedAt,
    );
  }
}