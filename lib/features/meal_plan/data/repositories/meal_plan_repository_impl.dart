import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/meal_plan_entities.dart';
import '../../domain/repositories/meal_plan_repository.dart';
import '../datasources/meal_plan_local_datasource.dart';
import '../datasources/meal_plan_remote_datasource.dart';

class MealPlanRepositoryImpl implements MealPlanRepository {
  final MealPlanLocalDatasource localDatasource;
  final MealPlanRemoteDatasource remoteDatasource;
  final NetworkInfo networkInfo;

  MealPlanRepositoryImpl({
    required this.localDatasource,
    required this.remoteDatasource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, WeeklyPlanEntity?>> getWeeklyPlan({
    required String userId,
    required DateTime weekStart,
  }) async {
    final isConnected = await networkInfo.isConnected;

    if (isConnected) {
      try {
        final remoteData = await remoteDatasource.fetchMyPlan();
        if (remoteData == null || remoteData.isEmpty) {
          return const Right(null);
        }

        final plan = _mapRemoteToWeeklyPlan(remoteData, userId, weekStart);

        if (plan != null) {
          try {
            final localPlan = await localDatasource.getWeeklyPlan(userId, weekStart);
            if (localPlan != null) {
              final mergedMeals = plan.meals.map((remoteMeal) {
                final match = localPlan.meals.where(
                  (m) => m.id == remoteMeal.id,
                ).firstOrNull;
                if (match != null && match.isConsumed) {
                  return remoteMeal.copyWith(
                    isConsumed: true,
                    substituteNote: match.substituteNote ?? remoteMeal.substituteNote,
                  );
                }
                return remoteMeal;
              }).toList();
              return Right(plan.copyWith(meals: mergedMeals));
            }
          } catch (_) {}
        }

        return Right(plan);
      } catch (e) {
        return Left(ServerFailure('Error al obtener plan remoto: $e'));
      }
    }

    try {
      final plan = await localDatasource.getWeeklyPlan(userId, weekStart);
      return Right(plan);
    } catch (e) {
      return Left(DatabaseFailure('Error al obtener plan local: $e'));
    }
  }

  WeeklyPlanEntity? _mapRemoteToWeeklyPlan(
    Map<String, dynamic> data,
    String userId,
    DateTime weekStart,
  ) {
    if (data.isEmpty) return null;

    final planId = data['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString();
    final daysRaw = data['days'] as List<dynamic>? ??
        data['weekDays'] as List<dynamic>? ??
        [];
    final meals = <MealEntity>[];

    for (final d in daysRaw) {
      if (d is! Map<String, dynamic>) continue;

      final dayNumber = _toDayNumber(d['dayNumber'] ?? d['dayOfWeek'] ?? d['day']);
      final mealsRaw = d['meals'] as List<dynamic>? ?? [];

      for (final m in mealsRaw) {
        if (m is! Map<String, dynamic>) continue;

        final mealName =
            m['name']?.toString() ?? m['title']?.toString() ?? 'Comida';
        final itemsRaw = m['items'] as List<dynamic>? ??
            m['foodItems'] as List<dynamic>? ??
            [];

        final ingredients = <IngredientEntity>[];
        double totalCal = 0, totalProt = 0, totalCarbs = 0, totalFat = 0;
        String? imageUrl;
        String? dishName;

        for (final item in itemsRaw) {
          if (item is! Map<String, dynamic>) continue;
          final itemName = item['name']?.toString() ?? '';
          final itemPortion = item['portion']?.toString() ?? '';
          final itemCal = num.tryParse(item['calories']?.toString() ?? '')?.toDouble() ?? 0;
          final itemProt = num.tryParse((item['protein'] ?? item['proteinG'])?.toString() ?? '')?.toDouble() ?? 0;
          final itemCarbs = num.tryParse((item['carbs'] ?? item['carbsG'])?.toString() ?? '')?.toDouble() ?? 0;
          final itemFat = num.tryParse((item['fat'] ?? item['fatG'])?.toString() ?? '')?.toDouble() ?? 0;

          totalCal += itemCal;
          totalProt += itemProt;
          totalCarbs += itemCarbs;
          totalFat += itemFat;

          final itemIngredients = item['ingredients'];
          if (itemIngredients is List && itemIngredients.isNotEmpty) {
            if (itemName.isNotEmpty) dishName = itemName;
            for (final ing in itemIngredients) {
              if (ing is! Map<String, dynamic>) continue;
              final ingName = ing['name']?.toString() ?? '';
              final ingQty = ing['quantity']?.toString() ?? '';
              final ingUnit = ing['unit']?.toString() ?? '';
              if (ingName.isNotEmpty) {
                ingredients.add(IngredientEntity(
                  name: '$ingName ($ingQty $ingUnit)',
                  isChecked: false,
                ));
              }
            }
          } else if (itemName.isNotEmpty) {
            ingredients.add(IngredientEntity(
              name: itemPortion.isNotEmpty
                  ? '$itemName ($itemPortion · ${itemCal.round()} kcal)'
                  : '$itemName (${itemCal.round()} kcal)',
              isChecked: false,
            ));
          }

          imageUrl ??= item['imageUrl']?.toString();
        }

        final mealId = m['id']?.toString() ??
            DateTime.now().microsecondsSinceEpoch.toString();
        imageUrl ??= m['imageUrl']?.toString();

        final recipeTitle = dishName ?? (ingredients.isNotEmpty
            ? ingredients.first.name
            : mealName);

        final mealNote = m['note']?.toString();
        final recipe = (ingredients.isNotEmpty || mealNote != null)
            ? RecipeEntity(
                id: mealId,
                mealId: mealId,
                title: recipeTitle,
                imageUrl: imageUrl,
                mealTime: mealName,
                ingredients: ingredients,
                steps: mealNote != null ? [mealNote] : [],
                calories: totalCal.round(),
                proteinG: totalProt > 0 ? totalProt : null,
                carbsG: totalCarbs > 0 ? totalCarbs : null,
                fatG: totalFat > 0 ? totalFat : null,
                observations: mealNote,
              )
            : null;

        meals.add(MealEntity(
          id: mealId,
          weeklyPlanId: planId,
          dayOfWeek: dayNumber,
          mealType:
              _mapMealType(m['mealType']?.toString() ?? m['type']?.toString() ?? mealName),
          name: mealName,
          imageUrl: imageUrl,
          calories: totalCal > 0 ? totalCal.round() : null,
          proteinG: totalProt > 0 ? totalProt : null,
          carbsG: totalCarbs > 0 ? totalCarbs : null,
          fatG: totalFat > 0 ? totalFat : null,
          isConsumed: _toBool(m['isConsumed']),
          substituteNote: m['substituteNote']?.toString(),
          note: m['note']?.toString(),
          recipe: recipe,
        ));
      }
    }

    if (meals.isEmpty) {
      final flatMeals = data['meals'] as List<dynamic>? ?? [];
      for (final m in flatMeals) {
        if (m is! Map<String, dynamic>) continue;

        final mealName =
            m['name']?.toString() ?? m['title']?.toString() ?? 'Comida';
        meals.add(
          MealEntity(
            id: m['id']?.toString() ?? DateTime.now().microsecondsSinceEpoch.toString(),
            weeklyPlanId: planId,
            dayOfWeek: _toDayNumber(m['dayOfWeek'] ?? m['dayNumber'] ?? m['day']),
            mealType: _mapMealType(
              m['mealType']?.toString() ?? m['type']?.toString() ?? mealName,
            ),
            name: mealName,
            imageUrl: m['imageUrl']?.toString(),
            calories: _toInt(m['calories']),
            proteinG: _toDouble(m['protein'] ?? m['proteinG']),
            carbsG: _toDouble(m['carbs'] ?? m['carbsG']),
            fatG: _toDouble(m['fat'] ?? m['fatG']),
            isConsumed: _toBool(m['isConsumed']),
            substituteNote: m['substituteNote']?.toString(),
          ),
        );
      }
    }

    return WeeklyPlanEntity(
      id: planId,
      userId: userId,
      weekStartDate: weekStart,
      nutritionistNotes:
          data['notes']?.toString() ?? data['nutritionistNotes']?.toString(),
      meals: meals,
    );
  }

  int _toDayNumber(dynamic value) {
    if (value is int && value >= 1 && value <= 7) return value;
    if (value is num) {
      final normalized = value.toInt();
      if (normalized >= 1 && normalized <= 7) return normalized;
    }
    if (value is String) {
      final lower = value.toLowerCase();
      final parsedDay = int.tryParse(lower);
      if (parsedDay != null && parsedDay >= 1 && parsedDay <= 7) {
        return parsedDay;
      }
      const dayMap = {
        'monday': 1, 'lunes': 1,
        'tuesday': 2, 'martes': 2,
        'wednesday': 3, 'miercoles': 3, 'miércoles': 3,
        'thursday': 4, 'jueves': 4,
        'friday': 5, 'viernes': 5,
        'saturday': 6, 'sabado': 6, 'sábado': 6,
        'sunday': 7, 'domingo': 7,
      };
      return dayMap[lower] ?? 1;
    }
    return 1;
  }

  String _mapMealType(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('desayuno') || lower.contains('breakfast')) return 'breakfast';
    if (lower.contains('comida') || lower.contains('lunch')) return 'lunch';
    if (lower.contains('cena') || lower.contains('dinner')) return 'dinner';
    return 'snack';
  }

  int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return num.tryParse(value.toString())?.toDouble();
  }

  bool _toBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final normalized = value.toLowerCase().trim();
      return normalized == 'true' || normalized == '1' || normalized == 'yes';
    }
    return false;
  }

  /// Convierte un UUID String a un int para compatibilidad con BD local (SQLite)
  int _uuidToLocalId(String uuid) {
    var hash = 0;
    for (final rune in uuid.runes) {
      hash = (hash * 31 + rune) & 0x7fffffff;
    }
    return hash == 0 ? uuid.hashCode : hash;
  }

  @override
  Future<Either<Failure, void>> updateMealConsumed({
    required String mealId,
    required bool consumed,
    String? substituteNote,
    String? voiceNotePath,
  }) async {
    try {
      final today = DateTime.now().toIso8601String().split('T').first;
      final logResult = await remoteDatasource.logMeal(
        mealName: mealId,
        date: today,
        consumed: consumed,
        consumedAt: consumed ? DateTime.now().toIso8601String() : null,
        note: substituteNote,
      );

      if (voiceNotePath != null) {
        final mealLogId = logResult?['id']?.toString();
        await remoteDatasource.uploadVoiceNote(filePath: voiceNotePath, mealLogId: mealLogId);
      }

      final localId = _uuidToLocalId(mealId);
      await localDatasource.markMealConsumed(localId, consumed);
      if (substituteNote != null || voiceNotePath != null) {
        await localDatasource.saveSubstituteNote(
          mealId: localId,
          note: substituteNote,
          voiceNotePath: voiceNotePath,
        );
      }
      return const Right(null);
    } catch (e) {
      try {
        final localId = _uuidToLocalId(mealId);
        await localDatasource.markMealConsumed(localId, consumed);
        if (substituteNote != null || voiceNotePath != null) {
          await localDatasource.saveSubstituteNote(
            mealId: localId,
            note: substituteNote,
            voiceNotePath: voiceNotePath,
          );
        }
      } catch (_) {}
      return Left(ServerFailure('Error al sincronizar con el servidor: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> saveSubstituteNote({
    required String mealId,
    String? note,
    String? voiceNotePath,
  }) async {
    try {
      final today = DateTime.now().toIso8601String().split('T').first;
      final logResult = await remoteDatasource.logMeal(
        mealName: mealId,
        date: today,
        consumed: true,
        consumedAt: DateTime.now().toIso8601String(),
        note: note,
      );

      if (voiceNotePath != null) {
        final mealLogId = logResult?['id']?.toString();
        await remoteDatasource.uploadVoiceNote(filePath: voiceNotePath, mealLogId: mealLogId);
      }

      final localId = _uuidToLocalId(mealId);
      await localDatasource.saveSubstituteNote(
        mealId: localId,
        note: note,
        voiceNotePath: voiceNotePath,
      );
      return const Right(null);
    } catch (e) {
      try {
        final localId = _uuidToLocalId(mealId);
        await localDatasource.saveSubstituteNote(
          mealId: localId,
          note: note,
          voiceNotePath: voiceNotePath,
        );
      } catch (_) {}
      return Left(ServerFailure('Error al sincronizar nota sustituta: $e'));
    }
  }

  @override
  Future<Either<Failure, RecipeEntity?>> getRecipeByMeal({
    required String mealId,
  }) async {
    try {
      final localId = _uuidToLocalId(mealId);
      final recipe = await localDatasource.getRecipeByMealId(localId);
      return Right(recipe);
    } catch (e) {
      return Left(DatabaseFailure('Error al obtener receta: $e'));
    }
  }
}