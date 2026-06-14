/// Datasource remoto del plan de comidas.
/// El nutriólogo crea los planes desde su plataforma web y los envía
/// al paciente. Por ahora es un placeholder hasta que el backend esté listo.
abstract class MealPlanRemoteDatasource {
  // TODO: implementar cuando el backend del nutriólogo esté disponible
  // Future<WeeklyPlanModel> fetchWeeklyPlan(String userId, DateTime weekStart);
}

class MealPlanRemoteDatasourceImpl implements MealPlanRemoteDatasource {
  const MealPlanRemoteDatasourceImpl();
  // TODO: inyectar ApiClient cuando el backend esté listo
}
