import 'package:equatable/equatable.dart';
import '../../../hydration/domain/entities/hydration_entity.dart';
import '../../../meal_plan/domain/entities/meal_plan_entities.dart';
import '../../../medication/domain/entities/medication_entity.dart';
import '../../../mood/domain/entities/mood_entity.dart';

abstract class DashboardState extends Equatable {
  const DashboardState();
  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {
  const DashboardInitial();
}

class DashboardLoading extends DashboardState {
  const DashboardLoading();
}

class DashboardLoaded extends DashboardState {
  final HydrationSummary hydration;
  final List<MealEntity> todayMeals;
  final List<MedicationEntity> medications;
  final MoodEntity? todayMood;
  final DateTime date;

  const DashboardLoaded({
    required this.hydration,
    required this.todayMeals,
    required this.medications,
    this.todayMood,
    required this.date,
  });

  @override
  List<Object?> get props => [
        hydration,
        todayMeals,
        medications,
        todayMood,
        date,
      ];
}

class DashboardError extends DashboardState {
  final String message;
  const DashboardError(this.message);
  @override
  List<Object?> get props => [message];
}