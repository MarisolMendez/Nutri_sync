import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';

abstract class HydrationRemoteDatasource {
  Future<void> logWater(String date, int amountMl);
  Future<int> getDailyTotalMl(String date);
}

class HydrationRemoteDatasourceImpl implements HydrationRemoteDatasource {
  final ApiClient client;

  const HydrationRemoteDatasourceImpl({required this.client});

  @override
  Future<void> logWater(String date, int amountMl) async {
    await client.post(ApiEndpoints.hydration, data: {
      'date': date,
      'amountMl': amountMl,
    });
  }

  @override
  Future<int> getDailyTotalMl(String date) async {
    final response = await client.get('${ApiEndpoints.hydration}?date=$date');
    final raw = response.data;
    final list = (raw is Map && raw.containsKey('data'))
        ? raw['data'] as List<dynamic>
        : raw is List
            ? raw
            : <dynamic>[];
    var total = 0;
    for (final item in list) {
      if (item is Map<String, dynamic>) {
        total += (item['amountMl'] as num?)?.toInt() ?? 0;
      }
    }
    return total;
  }
}