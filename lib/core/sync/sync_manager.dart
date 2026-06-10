import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../database/app_database.dart';
import '../database/daos/sync_queue_dao.dart';

/// SyncManager escucha la conectividad y procesa la cola de operaciones
/// pendientes cuando vuelve internet.
///
/// Flujo offline-first:
/// 1. Usuario hace acción sin internet
/// 2. Repositorio guarda en Drift con isSynced = false
/// 3. Repositorio encola operación en SyncQueueTable via SyncManager.enqueue()
/// 4. SyncManager detecta que vuelve internet
/// 5. SyncManager procesa la cola en orden FIFO
/// 6. Marca cada registro como isSynced = true al confirmar con Firestore
class SyncManager {
  final SyncQueueDao _syncQueueDao;
  final FirebaseFirestore _firestore;
  final Connectivity _connectivity;

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _isSyncing = false;

  SyncManager({
    required SyncQueueDao syncQueueDao,
    required FirebaseFirestore firestore,
    required Connectivity connectivity,
  })  : _syncQueueDao = syncQueueDao,
        _firestore = firestore,
        _connectivity = connectivity;

  /// Inicia el listener de conectividad.
  /// Llamar esto en bootstrap.dart una sola vez al arrancar la app.
  void init() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (results) {
        final hasInternet = results.any(
          (result) => result == ConnectivityResult.wifi ||
              result == ConnectivityResult.mobile,
        );
        if (hasInternet) {
          processPendingQueue();
        }
      },
    );
  }

  /// Encola una operación para sincronizar cuando haya internet.
  ///
  /// [entity]    — nombre de la colección en Firestore: 'hydration', 'meals', etc.
  /// [operation] — 'create' | 'update' | 'delete'
  /// [localId]   — ID local del registro en Drift
  /// [payload]   — datos a sincronizar como Map
  Future<void> enqueue({
    required String entity,
    required String operation,
    required String localId,
    required Map<String, dynamic> payload,
  }) async {
    await _syncQueueDao.enqueue(
      SyncQueueTableCompanion.insert(
        entity: entity,
        operation: operation,
        localId: localId,
        payload: jsonEncode(payload),
      ),
    );
  }

  /// Procesa toda la cola pendiente.
  /// Se llama automáticamente cuando vuelve internet,
  /// pero también se puede llamar manualmente (ej. pull-to-refresh).
  Future<void> processPendingQueue() async {
    // Evita procesar en paralelo si ya está corriendo
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      final pending = await _syncQueueDao.getPendingOperations();

      for (final operation in pending) {
        try {
          await _processOperation(operation);
          await _syncQueueDao.dequeue(operation.id);
        } catch (e) {
          await _syncQueueDao.incrementRetry(operation.id);
          // Si falló 3 veces, lo descartamos para no bloquear la cola
          await _syncQueueDao.clearFailedOperations(maxRetries: 3);
        }
      }
    } finally {
      _isSyncing = false;
    }
  }

  /// Ejecuta una operación individual contra Firestore.
  Future<void> _processOperation(SyncQueueTableData op) async {
    final payload = jsonDecode(op.payload) as Map<String, dynamic>;
    final collection = _firestore.collection(op.entity);

    switch (op.operation) {
      case 'create':
        await collection.doc(op.localId).set(payload);
        break;
      case 'update':
        await collection.doc(op.localId).update(payload);
        break;
      case 'delete':
        await collection.doc(op.localId).delete();
        break;
    }
  }

  /// Limpia el listener cuando ya no se necesita.
  void dispose() {
    _connectivitySubscription?.cancel();
  }
}