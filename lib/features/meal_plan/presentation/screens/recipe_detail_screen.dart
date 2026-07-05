import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/meal_plan_entities.dart';
import '../controllers/meal_plan_controller.dart';
import '../controllers/meal_plan_state.dart';

class RecipeDetailScreen extends ConsumerStatefulWidget {
  final MealEntity meal;
  const RecipeDetailScreen({super.key, required this.meal});

  @override
  ConsumerState<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends ConsumerState<RecipeDetailScreen> {
  late List<IngredientEntity> _ingredients;
  late bool _isConsumed;

  @override
  void initState() {
    super.initState();
    _ingredients = widget.meal.recipe?.ingredients.map((i) => i).toList() ?? [];
    _isConsumed = widget.meal.isConsumed;
  }

  void _toggleIngredient(int index) {
    setState(() {
      _ingredients[index] = _ingredients[index].copyWith(
        isChecked: !_ingredients[index].isChecked,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(recipeDetailStateProvider(widget.meal));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.meal.name),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      backgroundColor: NutriColors.background,
      body: switch (state) {
        RecipeDetailLoading() => const Center(
            child: CircularProgressIndicator(color: NutriColors.primary),
          ),
        RecipeDetailError(:final message) => Center(child: Text(message)),
        RecipeDetailLoaded() => _RecipeContent(
            state: state,
            ingredients: _ingredients,
            isConsumed: _isConsumed,
            onToggleIngredient: _toggleIngredient,
            onRegister: () async {
              if (_isConsumed) return;

              setState(() {
                _isConsumed = true;
              });

              await ref
                  .read(mealPlanControllerProvider.notifier)
                  .toggleMealConsumed(widget.meal);
            },
          ),
        _ => const SizedBox(),
      },
    );
  }
}

class _RecipeContent extends StatelessWidget {
  final RecipeDetailLoaded state;
  final List<IngredientEntity> ingredients;
  final bool isConsumed;
  final void Function(int) onToggleIngredient;
  final VoidCallback onRegister;

  const _RecipeContent({
    required this.state,
    required this.ingredients,
    required this.isConsumed,
    required this.onToggleIngredient,
    required this.onRegister,
  });

  @override
  Widget build(BuildContext context) {
    final recipe = state.recipe;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Imagen hero con tag de horario ─────────────────────────
          Stack(
            children: [
              if (recipe.imageUrl != null)
                CachedNetworkImage(
                  imageUrl: recipe.imageUrl!,
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => Container(
                    height: 220,
                    color: NutriColors.inputFill,
                    child: const Icon(Icons.restaurant,
                        size: 60, color: NutriColors.textSecondary),
                  ),
                )
              else
                Container(
                  height: 220,
                  color: NutriColors.inputFill,
                  child: const Center(
                    child: Icon(Icons.restaurant,
                        size: 60, color: NutriColors.textSecondary),
                  ),
                ),

              // Tag de horario — "Desayuno • 08:30 AM"
              if (recipe.mealTime != null)
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      recipe.mealTime!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Título ───────────────────────────────────────────
                Text(
                  recipe.title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 20),

                // ── Ingredientes ─────────────────────────────────────
                Text('Ingredientes',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                ...List.generate(ingredients.length, (i) {
                  final ing = ingredients[i];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: NutriColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: NutriColors.border),
                    ),
                    child: CheckboxListTile(
                      value: ing.isChecked,
                      onChanged: (_) => onToggleIngredient(i),
                      title: Text(
                        ing.name,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      activeColor: NutriColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                  );
                }),
                const SizedBox(height: 20),

                // ── Preparación ──────────────────────────────────────
                Text('Preparación',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                ...List.generate(recipe.steps.length, (i) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: const BoxDecoration(
                            color: NutriColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${i + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            recipe.steps[i],
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 20),

                // ── Información Nutricional ───────────────────────────
                Text('Información Nutricional',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: NutriColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: NutriColors.border),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          _NutriItem(
                            label: 'Calorías',
                            value: '${recipe.calories ?? 0} kcal',
                          ),
                          _NutriItem(
                            label: 'Proteína',
                            value: '${recipe.proteinG?.toInt() ?? 0}g',
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _NutriItem(
                            label: 'Carbohidratos',
                            value: '${recipe.carbsG?.toInt() ?? 0}g',
                          ),
                          _NutriItem(
                            label: 'Grasas',
                            value: '${recipe.fatG?.toInt() ?? 0}g',
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _NutriItem(
                            label: 'Fibra',
                            value: '${recipe.fiberG?.toInt() ?? 0}g',
                          ),
                          _NutriItem(
                            label: 'Sodio',
                            value: '${recipe.sodiumMg?.toInt() ?? 0}mg',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // ── Observaciones ─────────────────────────────────────
                if (recipe.observations != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: NutriColors.inputFill,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: NutriColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.lightbulb_outline,
                                size: 16, color: NutriColors.primaryDark),
                            const SizedBox(width: 6),
                            Text(
                              'Observaciones',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                      color: NutriColors.primaryDark),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '"${recipe.observations}"',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                  color: NutriColors.textSecondary,
                                  fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 24),

                // ── Botón registrar ───────────────────────────────────
                ElevatedButton(
                  onPressed: onRegister,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isConsumed
                        ? NutriColors.primary
                        : NutriColors.success,
                    foregroundColor: NutriColors.textOnPrimary,
                    minimumSize: const Size(double.infinity, 44),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    isConsumed ? 'Consumido' : 'Registrar como consumido',
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NutriItem extends StatelessWidget {
  final String label;
  final String value;

  const _NutriItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: NutriColors.textSecondary,
                  )),
          const SizedBox(height: 2),
          Text(value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  )),
        ],
      ),
    );
  }
}