import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/history_service.dart';
import '../services/api/simulation_api_service.dart';
import '../../domain/models/simulation_input.dart';
import '../../domain/models/simulation_result.dart';
import '../../../../../core/network/base_api_service.dart';
import '../providers/simulation_providers.dart';

/// Repository that handles both local and remote simulation data
class SimulationRepository {
  final HistoryService _localService;
  final SimulationApiService _apiService;

  SimulationRepository({
    required HistoryService localService,
    required SimulationApiService apiService,
  })  : _localService = localService,
        _apiService = apiService;

  /// Run simulation - tries API first, falls back to local
  Future<SimulationResult> runSimulation(
    SimulationInput input, {
    String name = 'Current Habits',
  }) async {
    try {
      // Try backend first
      final result = await _apiService.runSimulation(input);
      // Save to local history as backup
      await _localService.saveResult(result);
      return result;
    } catch (e) {
      // Fallback to local simulation engine
      if (e is NetworkException || e is ApiException) {
        // You can implement local fallback here
        // For now, rethrow to let UI handle the error
        rethrow;
      }
      rethrow;
    }
  }

  /// Get simulation history - combines local and remote
  Future<List<SimulationResult>> getHistory() async {
    try {
      // Try to get from API first
      final remoteHistory = await _apiService.getSimulationHistory();
      return remoteHistory;
    } catch (e) {
      // Fallback to local storage
      if (e is NetworkException || e is ApiException) {
        return await _localService.loadHistory();
      }
      rethrow;
    }
  }

  /// Save simulation - saves to both local and remote
  Future<SimulationResult> saveSimulation(SimulationResult result) async {
    try {
      // Save to API
      final savedResult = await _apiService.saveSimulation(result);
      // Also save locally as backup
      await _localService.saveResult(savedResult);
      return savedResult;
    } catch (e) {
      // If API fails, save locally only
      if (e is NetworkException || e is ApiException) {
        await _localService.saveResult(result);
        return result;
      }
      rethrow;
    }
  }

  /// Run parallel futures simulation
  Future<Map<String, SimulationResult>> runParallelFutures(
    SimulationInput input,
  ) async {
    try {
      return await _apiService.runParallelFutures(input);
    } catch (e) {
      // Fallback to local implementation if needed
      if (e is NetworkException || e is ApiException) {
        rethrow;
      }
      rethrow;
    }
  }

  /// Get simulation by ID
  Future<SimulationResult?> getSimulation(String id) async {
    try {
      return await _apiService.getSimulation(id);
    } catch (e) {
      if (e is NetworkException || e is ApiException) {
        // Could implement local lookup here if needed
        return null;
      }
      rethrow;
    }
  }

  /// Delete simulation
  Future<void> deleteSimulation(String id) async {
    try {
      await _apiService.deleteSimulation(id);
      // Also try to remove from local storage
      // TODO: Implement local deletion logic if needed
      // You might want to implement a method to replace the entire history
      // or handle this differently based on your local storage implementation
    } catch (e) {
      if (e is NetworkException || e is ApiException) {
        // Handle local deletion if needed
        return;
      }
      rethrow;
    }
  }

  /// Clear all history
  Future<void> clearHistory() async {
    try {
      // Clear remote history
      await _apiService.deleteSimulation('all'); // You might need to adjust this endpoint
    } catch (e) {
      // Ignore API errors for clear operation
    }
    
    // Always clear local history
    await _localService.clearHistory();
  }

  /// Get simulation statistics
  Future<Map<String, dynamic>> getStats() async {
    try {
      return await _apiService.getSimulationStats();
    } catch (e) {
      if (e is NetworkException || e is ApiException) {
        // Return local stats or empty map
        return {};
      }
      rethrow;
    }
  }
}

/// Provider for the simulation repository
final simulationRepositoryProvider = Provider<SimulationRepository>((ref) {
  return SimulationRepository(
    localService: ref.read(historyServiceProvider),
    apiService: SimulationApiService(),
  );
});