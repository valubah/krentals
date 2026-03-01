// lib/core/services/connectivity_service.dart

import 'package:connectivity_plus/connectivity_plus.dart';

abstract class ConnectivityService {
  Future<bool> get isConnected;
}

class ConnectivityServiceImpl implements ConnectivityService {
  final Connectivity _connectivity;

  ConnectivityServiceImpl({Connectivity? connectivity})
    : _connectivity = connectivity ?? Connectivity();

  @override
  Future<bool> get isConnected async {
    try {
      final results = await _connectivity.checkConnectivity();
      return results.any((element) => element != ConnectivityResult.none);
    } catch (_) {
      // Typically fallback to true or handle specifically if plugin fails
      return true;
    }
  }
}
