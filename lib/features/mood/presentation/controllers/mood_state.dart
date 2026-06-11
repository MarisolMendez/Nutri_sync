import 'package:equatable/equatable.dart';
import '../../domain/entities/mood_entity.dart';

abstract class MoodState extends Equatable {
  const MoodState();
  @override
  List<Object?> get props => [];
}

class MoodInitial extends MoodState {
  const MoodInitial();
}

class MoodLoading extends MoodState {
  const MoodLoading();
}

class MoodLoaded extends MoodState {
  final MoodEntity? todayMood;
  final WeekMoodSummary weekSummary;
  final MoodValue? selectedMood;
  final String note;
  final bool saved;

  const MoodLoaded({
    required this.todayMood,
    required this.weekSummary,
    this.selectedMood,
    this.note = '',
    this.saved = false,
  });

  MoodLoaded copyWith({
    MoodEntity? todayMood,
    WeekMoodSummary? weekSummary,
    MoodValue? selectedMood,
    String? note,
    bool? saved,
  }) {
    return MoodLoaded(
      todayMood: todayMood ?? this.todayMood,
      weekSummary: weekSummary ?? this.weekSummary,
      selectedMood: selectedMood ?? this.selectedMood,
      note: note ?? this.note,
      saved: saved ?? this.saved,
    );
  }

  @override
  List<Object?> get props => [todayMood, weekSummary, selectedMood, note, saved];
}

class MoodError extends MoodState {
  final String message;
  const MoodError(this.message);
  @override
  List<Object?> get props => [message];
}