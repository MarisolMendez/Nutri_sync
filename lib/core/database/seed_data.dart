import 'dart:convert';
import 'package:drift/drift.dart';
import 'app_database.dart';

/// Inserta datos de ejemplo en la base de datos local para poder
/// visualizar el plan de comidas mientras no haya backend conectado.
///
/// Solo inserta si no existe un plan para la semana actual.
Future<void> seedSampleData(AppDatabase db) async {
  final now = DateTime.now();
  final monday = DateTime(now.year, now.month, now.day - (now.weekday - 1));
  final weekStart = DateTime(monday.year, monday.month, monday.day);

  // Verificar si ya hay datos para esta semana
  final dao = db.mealDao;
  final existing = await dao.getWeeklyPlan('user_1', weekStart);
  if (existing != null) return; // ya hay datos

  // ── Insertar el plan semanal ──────────────────────────────────────────
  final planId = await db.into(db.weeklyPlansTable).insert(
        WeeklyPlansTableCompanion(
          userId: const Value('user_1'),
          weekStartDate: Value(weekStart),
          nutritionistNotes: const Value(
            'Plan enfocado en mantener energía estable durante el día.',
          ),
        ),
      );

  // ── Comidas por día (Lun=1 … Dom=7) ─────────────────────────────────
  final meals = <_MealSeed>[
    // ── Lunes (día 1) ─────────────────────────────────────────────────
    _MealSeed(
      dayOfWeek: 1,
      mealType: 'breakfast',
      name: 'Omelette de claras con espinacas',
      imageUrl: 'https://images.pexels.com/photos/25631957/pexels-photo-25631957.jpeg?w=400',
      calories: 320,
      proteinG: 28,
      carbsG: 12,
      fatG: 16,
      recipe: _RecipeSeed(
        title: 'Omelette de claras con espinacas',
        imageUrl: 'https://images.pexels.com/photos/25631957/pexels-photo-25631957.jpeg?w=400',
        mealTime: 'Desayuno • 08:00 AM',
        ingredients: [
          '4 claras de huevo',
          '1 taza de espinacas frescas',
          '¼ de cebolla picada',
          '1 cda de aceite de oliva',
          'Sal y pimienta al gusto',
        ],
        steps: [
          'Bate las claras hasta que estén espumosas.',
          'Saltea la cebolla y las espinacas en aceite de oliva.',
          'Vierte las claras sobre las verduras y cocina a fuego medio.',
          'Dobla el omelette y cocina 2 minutos más.',
          'Sirve caliente con sal y pimienta.',
        ],
        calories: 320,
        proteinG: 28,
        carbsG: 12,
        fatG: 16,
        observations: 'Puedes agregar queso panela desmenuzado.',
      ),
    ),
    _MealSeed(
      dayOfWeek: 1,
      mealType: 'lunch',
      name: 'Pechuga de pollo con quinoa',
      imageUrl: 'https://images.pexels.com/photos/25631957/pexels-photo-25631957.jpeg?w=400',
      calories: 480,
      proteinG: 35,
      carbsG: 40,
      fatG: 14,
      recipe: _RecipeSeed(
        title: 'Pechuga de pollo con quinoa y verduras',
        imageUrl: 'https://images.pexels.com/photos/25631957/pexels-photo-25631957.jpeg?w=400',
        mealTime: 'Comida • 14:00 PM',
        ingredients: [
          '1 pechuga de pollo (150g)',
          '½ taza de quinoa cocida',
          '1 taza de brócoli',
          '½ pimiento morrón',
          '1 cda de aceite de oliva',
          'Especias al gusto (orégano, ajo en polvo)',
        ],
        steps: [
          'Sazona la pechuga con especias y cocina a la plancha.',
          'Cocina la quinoa según instrucciones del paquete.',
          'Saltea el brócoli y pimiento en aceite de oliva.',
          'Sirve todo junto y disfruta.',
        ],
        calories: 480,
        proteinG: 35,
        carbsG: 40,
        fatG: 14,
        observations: null,
      ),
    ),
    _MealSeed(
      dayOfWeek: 1,
      mealType: 'dinner',
      name: 'Ensalada de atún',
      imageUrl: 'https://images.pexels.com/photos/25631957/pexels-photo-25631957.jpeg?w=400',
      calories: 280,
      proteinG: 22,
      carbsG: 15,
      fatG: 12,
      recipe: _RecipeSeed(
        title: 'Ensalada de atún con aguacate',
        imageUrl:'https://images.pexels.com/photos/25631957/pexels-photo-25631957.jpeg?w=400',
        mealTime: 'Cena • 20:00 PM',
        ingredients: [
          '1 lata de atún en agua',
          '½ aguacate',
          '2 tazas de lechuga mixta',
          '½ jitomate picado',
          'Jugo de ½ limón',
          'Sal y pimienta',
        ],
        steps: [
          'Mezcla la lechuga, jitomate y aguacate en un tazón.',
          'Desmenuza el atún y agrégalo a la ensalada.',
          'Aliña con jugo de limón, sal y pimienta.',
          'Mezcla bien y sirve.',
        ],
        calories: 280,
        proteinG: 22,
        carbsG: 15,
        fatG: 12,
        observations: null,
      ),
    ),
    // ── Martes (día 2) ────────────────────────────────────────────────
    _MealSeed(
      dayOfWeek: 2,
      mealType: 'breakfast',
      name: 'Smoothie bowl de frutas',
      imageUrl: 'https://images.pexels.com/photos/1099680/pexels-photo-1099680.jpeg?w=400',
      calories: 290,
      proteinG: 18,
      carbsG: 45,
      fatG: 6,
      recipe: _RecipeSeed(
        title: 'Smoothie bowl de frutas y granola',
        imageUrl: 'https://images.pexels.com/photos/1099680/pexels-photo-1099680.jpeg?w=400',
        mealTime: 'Desayuno • 08:00 AM',
        ingredients: [
          '1 plátano congelado',
          '½ taza de fresas',
          '½ taza de leche de almendras',
          '2 cdas de proteína en polvo (opcional)',
          '2 cdas de granola',
          '1 cda de semillas de chía',
        ],
        steps: [
          'Licúa el plátano, fresas y leche de almendras.',
          'Vierte en un tazón.',
          'Decora con granola y semillas de chía.',
          'Sirve inmediatamente.',
        ],
        calories: 290,
        proteinG: 18,
        carbsG: 45,
        fatG: 6,
        observations: null,
      ),
    ),
    _MealSeed(
      dayOfWeek: 2,
      mealType: 'lunch',
      name: 'Salmón al horno con espárragos',
      imageUrl: 'https://images.pexels.com/photos/566344/pexels-photo-566344.jpeg?w=400',
      calories: 420,
      proteinG: 32,
      carbsG: 18,
      fatG: 22,
      recipe: _RecipeSeed(
        title: 'Salmón al horno con espárragos y papa',
        imageUrl: 'https://images.pexels.com/photos/566344/pexels-photo-566344.jpeg?w=400',
        mealTime: 'Comida • 14:00 PM',
        ingredients: [
          '1 filete de salmón (150g)',
          '6 espárragos',
          '1 papa mediana',
          '1 cda de aceite de oliva',
          'Jugo de ½ limón',
          'Eneldo y ajo en polvo',
        ],
        steps: [
          'Precalienta el horno a 200°C.',
          'Coloca el salmón y espárragos en una bandeja.',
          'Rocía con aceite de oliva y jugo de limón.',
          'Hornea por 18-20 minutos.',
          'Cocina la papa aparte (horneada o hervida).',
          'Sirve y sazona con eneldo.',
        ],
        calories: 420,
        proteinG: 32,
        carbsG: 18,
        fatG: 22,
        observations: 'Puedes sustituir la papa por camote.',
      ),
    ),
    _MealSeed(
      dayOfWeek: 2,
      mealType: 'dinner',
      name: 'Wrap de pollo',
      imageUrl: 'https://images.pexels.com/photos/27944347/pexels-photo-27944347.jpeg?w=400',
      calories: 310,
      proteinG: 25,
      carbsG: 28,
      fatG: 10,
      recipe: _RecipeSeed(
        title: 'Wrap integral de pollo y verduras',
        imageUrl: 'https://images.pexels.com/photos/27944347/pexels-photo-27944347.jpeg?w=400',
        mealTime: 'Cena • 20:00 PM',
        ingredients: [
          '1 tortilla integral',
          '100g de pechuga de pollo deshebrada',
          '½ taza de lechuga',
          '¼ de aguacate',
          '2 cdas de yogurt griego',
          'Sal y pimienta',
        ],
        steps: [
          'Calienta la tortilla integral.',
          'Mezcla el pollo con el yogurt griego.',
          'Coloca la lechuga y el pollo en la tortilla.',
          'Añade el aguacate en rebanadas.',
          'Envuelve y sirve.',
        ],
        calories: 310,
        proteinG: 25,
        carbsG: 28,
        fatG: 10,
        observations: null,
      ),
    ),
    // ── Miércoles (día 3) ─────────────────────────────────────────────
    _MealSeed(dayOfWeek: 3, mealType: 'breakfast', name: 'Avena con frutos rojos', calories: 310, proteinG: 20, carbsG: 48, fatG: 5),
    _MealSeed(dayOfWeek: 3, mealType: 'lunch', name: 'Bowl de quinoa y verduras', calories: 400, proteinG: 15, carbsG: 55, fatG: 12),
    _MealSeed(dayOfWeek: 3, mealType: 'dinner', name: 'Tostadas de tinga de pollo', calories: 340, proteinG: 24, carbsG: 30, fatG: 14),
    // ── Jueves (día 4) ────────────────────────────────────────────────
    _MealSeed(dayOfWeek: 4, mealType: 'breakfast', name: 'Chilaquiles saludables', calories: 350, proteinG: 22, carbsG: 40, fatG: 12),
    _MealSeed(dayOfWeek: 4, mealType: 'lunch', name: 'Pechuga empanizada al horno', calories: 390, proteinG: 30, carbsG: 35, fatG: 10),
    _MealSeed(dayOfWeek: 4, mealType: 'dinner', name: 'Sopa de verduras con pollo', calories: 260, proteinG: 20, carbsG: 22, fatG: 8),
    // ── Viernes (día 5) ───────────────────────────────────────────────
    _MealSeed(dayOfWeek: 5, mealType: 'breakfast', name: 'Hotcakes de avena', calories: 300, proteinG: 18, carbsG: 42, fatG: 8),
    _MealSeed(dayOfWeek: 5, mealType: 'lunch', name: 'Pescado a la veracruzana', calories: 380, proteinG: 28, carbsG: 20, fatG: 18),
    _MealSeed(dayOfWeek: 5, mealType: 'dinner', name: 'Ensalada César de pollo', calories: 290, proteinG: 24, carbsG: 12, fatG: 16),
    // ── Sábado (día 6) ────────────────────────────────────────────────
    _MealSeed(dayOfWeek: 6, mealType: 'breakfast', name: 'Huevos revueltos con verduras', calories: 280, proteinG: 24, carbsG: 10, fatG: 16),
    _MealSeed(dayOfWeek: 6, mealType: 'lunch', name: 'Lomo de cerdo con puré de camote', calories: 450, proteinG: 34, carbsG: 38, fatG: 16),
    _MealSeed(dayOfWeek: 6, mealType: 'dinner', name: 'Pizza de coliflor', calories: 270, proteinG: 18, carbsG: 20, fatG: 14),
    // ── Domingo (día 7) ───────────────────────────────────────────────
    _MealSeed(dayOfWeek: 7, mealType: 'breakfast', name: 'Pan tostado con aguacate y huevo', calories: 330, proteinG: 22, carbsG: 28, fatG: 16),
    _MealSeed(dayOfWeek: 7, mealType: 'lunch', name: 'Pollo al curry con arroz integral', calories: 460, proteinG: 32, carbsG: 45, fatG: 14),
    _MealSeed(dayOfWeek: 7, mealType: 'dinner', name: 'Crema de calabaza', calories: 240, proteinG: 10, carbsG: 28, fatG: 10),
  ];

  for (final meal in meals) {
    final mealId = await db.into(db.mealsTable).insert(
          MealsTableCompanion(
            weeklyPlanId: Value(planId),
            dayOfWeek: Value(meal.dayOfWeek),
            mealType: Value(meal.mealType),
            name: Value(meal.name),
            imageUrl: Value(meal.imageUrl),
            calories: Value(meal.calories),
            proteinG: Value(meal.proteinG),
            carbsG: Value(meal.carbsG),
            fatG: Value(meal.fatG),
          ),
        );

    if (meal.recipe != null) {
      await db.into(db.recipesTable).insert(
            RecipesTableCompanion(
              mealId: Value(mealId),
              title: Value(meal.recipe!.title),
              imageUrl: Value(meal.recipe!.imageUrl),
              mealTime: Value(meal.recipe!.mealTime),
              ingredientsJson: Value(jsonEncode(meal.recipe!.ingredients)),
              stepsJson: Value(jsonEncode(meal.recipe!.steps)),
              calories: Value(meal.recipe!.calories),
              proteinG: Value(meal.recipe!.proteinG),
              carbsG: Value(meal.recipe!.carbsG),
              fatG: Value(meal.recipe!.fatG),
              observations: Value(meal.recipe!.observations),
            ),
          );
    }
  }
}

class _MealSeed {
  final int dayOfWeek;
  final String mealType;
  final String name;
  final String? imageUrl;
  final int? calories;
  final double? proteinG;
  final double? carbsG;
  final double? fatG;
  final _RecipeSeed? recipe;

  const _MealSeed({
    required this.dayOfWeek,
    required this.mealType,
    required this.name,
    this.imageUrl,
    this.calories,
    this.proteinG,
    this.carbsG,
    this.fatG,
    this.recipe,
  });
}

class _RecipeSeed {
  final String title;
  final String? imageUrl;
  final String? mealTime;
  final List<String> ingredients;
  final List<String> steps;
  final int? calories;
  final double? proteinG;
  final double? carbsG;
  final double? fatG;
  final String? observations;

  const _RecipeSeed({
    required this.title,
    this.imageUrl,
    this.mealTime,
    required this.ingredients,
    required this.steps,
    this.calories,
    this.proteinG,
    this.carbsG,
    this.fatG,
    this.observations,
  });
}