import '../../../../core/error/exceptions.dart';
import '../models/mood_model.dart';

abstract class MoodRemoteDatasource {
  Future<void> syncMoods(String userId, List<MoodModel> moods);
  Future<List<MoodModel>> fetchMoodHistory(String userId);
}

class MoodRemoteDatasourceImpl implements MoodRemoteDatasource {
  const MoodRemoteDatasourceImpl();

  @override
  Future<void> syncMoods(String userId, List<MoodModel> moods) async {
    try {
      // TODO: Implementar sincronización con Firestore
      // await FirebaseFirestore.instance
      //     .collection('users')
      //     .doc(userId)
      //     .collection('moods')
      //     .doc(mood.id)
      //     .set(mood.toJson());
    } catch (e) {
      throw ServerException(message: 'Error al sincronizar moods: $e');
    }
  }

  @override
  Future<List<MoodModel>> fetchMoodHistory(String userId) async {
    try {
      // TODO: Implementar obtención del historial desde Firestore
      return [];
    } catch (e) {
      throw ServerException(message: 'Error al obtener historial de moods: $e');
    }
  }
}
