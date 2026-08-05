import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../domain/entities/medication_entity.dart';

abstract class MedicationRemoteDatasource {
  Future<void> saveMedication({
    required String name,
    required String dosage,
    required bool reminderEnabled,
    required List<String> times,
    required List<String> days,
    int? intervalHours,
  });
  Future<List<MedicationEntity>> listMedications();
  Future<void> updateMedication({
    required String id,
    String? name,
    String? dosage,
    bool? reminderEnabled,
    List<String>? times,
    List<String>? days,
    int? intervalHours,
  });
  Future<void> deleteMedication(String id);
  Future<void> logMedicationTaken(String id);
}

class MedicationRemoteDatasourceImpl implements MedicationRemoteDatasource {
  final ApiClient client;

  const MedicationRemoteDatasourceImpl({required this.client});

  @override
  Future<void> saveMedication({
    required String name,
    required String dosage,
    required bool reminderEnabled,
    required List<String> times,
    required List<String> days,
    int? intervalHours,
  }) async {
    final data = <String, dynamic>{
      'name': name,
      'dosage': dosage,
      'reminderEnabled': reminderEnabled,
      'times': times,
      'days': days,
    };
    if (intervalHours != null) {
      data['intervalHours'] = intervalHours;
    }
    await client.post(ApiEndpoints.medications, data: data);
  }

  @override
  Future<List<MedicationEntity>> listMedications() async {
    final response = await client.get(ApiEndpoints.medications);
    final data = response.data;
    final list = (data is Map ? (data['data'] ?? data) : data);
    if (list is List) {
      return list.map((item) {
        final map = item as Map<String, dynamic>;
        final backendId = map['id']?.toString() ?? '';
        return MedicationEntity(
          id: backendId.hashCode.abs(),
          remoteId: backendId.isNotEmpty ? backendId : null,
          userId: map['patientUserId']?.toString() ?? map['userId']?.toString() ?? '',
          name: map['name']?.toString() ?? '',
          dosage: map['dosage']?.toString() ?? '',
          reminderEnabled: map['reminderEnabled'] == true,
          times: (map['times'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
          days: (map['days'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
          intervalHours: (map['intervalHours'] as num?)?.toInt(),
          createdAt: DateTime.tryParse(map['createdAt']?.toString() ?? '') ?? DateTime.now(),
        );
      }).toList();
    }
    return [];
  }

  @override
  Future<void> updateMedication({
    required String id,
    String? name,
    String? dosage,
    bool? reminderEnabled,
    List<String>? times,
    List<String>? days,
    int? intervalHours,
  }) async {
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (dosage != null) data['dosage'] = dosage;
    if (reminderEnabled != null) data['reminderEnabled'] = reminderEnabled;
    if (times != null) data['times'] = times;
    if (days != null) data['days'] = days;
    if (intervalHours != null) data['intervalHours'] = intervalHours;
    await client.patch('${ApiEndpoints.medications}/$id', data: data);
  }

  @override
  Future<void> deleteMedication(String id) async {
    await client.delete('${ApiEndpoints.medications}/$id');
  }

  @override
  Future<void> logMedicationTaken(String id) async {
    await client.post('${ApiEndpoints.medications}/$id/take');
  }
}
