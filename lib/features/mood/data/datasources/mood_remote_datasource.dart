import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';

abstract class MoodRemoteDatasource {
  Future<void> logMood(String mood, String date, {String? note});
}

class MoodRemoteDatasourceImpl implements MoodRemoteDatasource {
  final ApiClient client;

  const MoodRemoteDatasourceImpl({required this.client});

  @override
  Future<void> logMood(String mood, String date, {String? note}) async {
    final data = <String, dynamic>{
      'mood': mood,
      'date': date,
    };
    if (note != null && note.isNotEmpty) {
      data['note'] = note;
    }
    await client.post(ApiEndpoints.mood, data: data);
  }
}
