import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api/simulation_api_service.dart';
import '../../domain/models/simulation_input.dart';
import '../../domain/models/simulation_result.dart';
import '../../../../../core/network/base_api_service.dart';

/// Repository that handles remote simulation data
class SimulationRepository {
  final SimulationApiService _apiService;

  SimulationRepository({
    required SimulationApiService apiService,
  }) : _apiService = apiService;

  /// Run simulation
  Future<SimulationResult> runSimulation(
    SimulationInput input, {
    String name = 'Current Habits',
  }) async {
    return await _apiService.runSimulation(input);
  }

  /// Get simulation history
  Future<List<SimulationResult>> getHistory() async {
    return await _apiService.getSimulationHistory();
  }

  /// Save simulation
  Future<SimulationResult> saveSimulation(SimulationResult result) async {
    return await _apiService.saveSimulation(result);
  }

  /// Run parallel futures simulation
  Future<Map<String, SimulationResult>> runParallelFutures(
    SimulationInput input,
  ) async {
    return await _apiService.runParallelFutures(input);
  }

  /// Get simulation by ID
  Future<SimulationResult?> getSimulation(String id) async {
    try {
      return await _apiService.getSimulation(id);
    } catch (e) {
      if (e is NetworkException || e is ApiException) {
        return null;
      }
      rethrow;
    }
  }

  /// Delete simulation
  Future<void> deleteSimulation(String id) async {
    await _apiService.deleteSimulation(id);
  }

  /// Clear all history
  Future<void> clearHistory() async {
    try {
      await _apiService.deleteSimulation('all');
    } catch (e) {
      // Ignore API errors for clear operation
    }
  }

  /// Get simulation stats
  Future<Map<String, dynamic>> getStats() async {
    try {
      return await _apiService.getSimulationStats();
    } catch (e) {
      if (e is NetworkException || e is ApiException) {
        return {};
      }
      rethrow;
    }
  }
}

/// Provider for the simulation repository
final simulationRepositoryProvider = Provider<SimulationRepository>((ref) {
  return SimulationRepository(
    apiService: SimulationApiService(),
  );
});
