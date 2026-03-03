import '../../../../../core/network/base_api_service.dart';
import '../../../domain/models/simulation_input.dart';
import '../../../domain/models/simulation_result.dart';

/// API service for simulation-related endpoints
class SimulationApiService extends BaseApiService {
  
  /// Run simulation on backend
  Future<SimulationResult> runSimulation(SimulationInput input) async {
    try {
      final response = await post<Map<String, dynamic>>(
        '/api/simulation/run',
        data: input.toMap(),
      );
      
      if (response.data != null) {
        return SimulationResult.fromMap(response.data!);
      } else {
        throw ApiException(
          message: 'Empty response from server',
          statusCode: 500,
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Get simulation by ID
  Future<SimulationResult> getSimulation(String id) async {
    try {
      final response = await get<Map<String, dynamic>>(
        '/api/simulation/$id',
      );
      
      if (response.data != null) {
        return SimulationResult.fromMap(response.data!);
      } else {
        throw ApiException(
          message: 'Simulation not found',
          statusCode: 404,
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Get user's simulation history
  Future<List<SimulationResult>> getSimulationHistory() async {
    try {
      final response = await get<List<dynamic>>(
        '/api/simulation/history',
      );
      
      if (response.data != null) {
        return response.data!
            .map((item) => SimulationResult.fromMap(item as Map<String, dynamic>))
            .toList();
      } else {
        return [];
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Save simulation result
  Future<SimulationResult> saveSimulation(SimulationResult result) async {
    try {
      final response = await post<Map<String, dynamic>>(
        '/api/simulation',
        data: result.toMap(),
      );
      
      if (response.data != null) {
        return SimulationResult.fromMap(response.data!);
      } else {
        throw ApiException(
          message: 'Failed to save simulation',
          statusCode: 500,
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Delete simulation by ID
  Future<void> deleteSimulation(String id) async {
    try {
      await delete<void>('/api/simulation/$id');
    } catch (e) {
      rethrow;
    }
  }

  /// Get simulation statistics
  Future<Map<String, dynamic>> getSimulationStats() async {
    try {
      final response = await get<Map<String, dynamic>>(
        '/api/simulation/stats',
      );
      
      return response.data ?? {};
    } catch (e) {
      rethrow;
    }
  }

  /// Run parallel futures simulation
  Future<Map<String, SimulationResult>> runParallelFutures(SimulationInput input) async {
    try {
      final response = await post<Map<String, dynamic>>(
        '/api/simulation/parallel-futures',
        data: input.toMap(),
      );
      
      if (response.data != null) {
        final data = response.data!;
        return {
          'current': SimulationResult.fromMap(data['current'] as Map<String, dynamic>),
          'optimized': SimulationResult.fromMap(data['optimized'] as Map<String, dynamic>),
          'decline': SimulationResult.fromMap(data['decline'] as Map<String, dynamic>),
        };
      } else {
        throw ApiException(
          message: 'Empty response from parallel futures simulation',
          statusCode: 500,
        );
      }
    } catch (e) {
      rethrow;
    }
  }
}