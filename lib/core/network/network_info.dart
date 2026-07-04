import 'package:connectivity_plus/connectivity_plus.dart';

/// Contrato — el repositorio pregunta esto antes de decidir
/// si va a la red o se queda en local.
abstract class NetworkInfo {
  Future<bool> get isConnected;
}

class NetworkInfoImpl implements NetworkInfo {
  final Connectivity connectivity;

  const NetworkInfoImpl(this.connectivity);

  /// Retorna true si hay WiFi o datos móviles.
  /// Retorna false en cualquier otro caso (sin red, bluetooth solo, etc).
  @override
  Future<bool> get isConnected async {
    final result = await connectivity.checkConnectivity();
    return result.any(
      (value) => value == ConnectivityResult.wifi || value == ConnectivityResult.mobile,
    );
  }
}
