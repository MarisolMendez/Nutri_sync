import 'dart:io';
import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';

/// Datasource remoto del plan de comidas.
/// El nutriólogo crea los planes desde su plataforma web y los envía
/// al paciente vía `POST /v1/meal-plans/:id/assign`.
///
/// El paciente consulta su plan activo con `GET /v1/meal-plans/my-plan`.
abstract class MealPlanRemoteDatasource {
  Future<Map<String, dynamic>?> fetchMyPlan();
  Future<Map<String, dynamic>?> logMeal({
    required String mealName,
    required String date,
    String? planId,
    bool consumed = true,
    String? consumedAt,
    String? note,
  });
  Future<Map<String, dynamic>?> uploadVoiceNote({
    required String filePath,
    String? mealLogId,
  });
}

class MealPlanRemoteDatasourceImpl implements MealPlanRemoteDatasource {
  final ApiClient client;

  const MealPlanRemoteDatasourceImpl({required this.client});

  @override
  Future<Map<String, dynamic>?> fetchMyPlan() async {
    final response = await client.get(ApiEndpoints.myPlan);
    final raw = response.data;

    if (raw is! Map<String, dynamic>) return null;

    // Compatible con distintos envelopes:
    // 1) { success: true, data: {...} }
    // 2) { success: true, data: { plan: {...} } }
    // 3) { plan: {...} }
    // 4) payload plano del plan
    if (raw.containsKey('success') && raw['success'] != true) return null;

    final data = raw['data'];
    if (data is Map<String, dynamic>) {
      final nestedPlan = data['plan'];
      if (nestedPlan is Map<String, dynamic>) {
        return nestedPlan;
      }
      return data;
    }

    final topLevelPlan = raw['plan'];
    if (topLevelPlan is Map<String, dynamic>) {
      return topLevelPlan;
    }

    return raw;
  }

  @override
  Future<Map<String, dynamic>?> logMeal({
    required String mealName,
    required String date,
    String? planId,
    bool consumed = true,
    String? consumedAt,
    String? note,
  }) async {
    final body = <String, dynamic>{
      'mealName': mealName,
      'date': date,
      'consumed': consumed,
    };
    if (planId != null) body['planId'] = planId;
    if (consumedAt != null) body['consumedAt'] = consumedAt;
    if (note != null) body['note'] = note;

    final response = await client.post(ApiEndpoints.mealLogs, data: body);
    final raw = response.data;
    if (raw is Map<String, dynamic>) {
      final data = raw['data'];
      if (data is Map<String, dynamic>) return data;
      return raw;
    }
    return null;
  }

  @override
  Future<Map<String, dynamic>?> uploadVoiceNote({
    required String filePath,
    String? mealLogId,
  }) async {
    final file = File(filePath);
    final bytes = await file.readAsBytes();
    final ext = filePath.split('.').last;
    final formData = FormData.fromMap({
      'voice': MultipartFile.fromBytes(bytes, filename: 'voice_note.$ext'),
      'mealLogId': mealLogId ?? '',
    });
    final response = await client.post(ApiEndpoints.voiceNoteUpload, data: formData);
    final raw = response.data;
    if (raw is Map<String, dynamic>) return raw;
    return null;
  }
}