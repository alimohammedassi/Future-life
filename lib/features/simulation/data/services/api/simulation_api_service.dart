import 'package:dio/dio.dart';
import '../../../../../core/network/base_api_service.dart';
import '../../../domain/models/simulation_input.dart';
import '../../../domain/models/simulation_result.dart';

/// API service for simulation-related endpoints
class SimulationApiService extends BaseApiService {
  /// Helper: unwrap the standard {success, data, message} envelope
  dynamic _unwrap(Response response) {
    final body = response.data;
    if (body == null) {
      throw ApiException(
          message: 'Empty response from server', statusCode: 500);
    }

    if (body is Map && body.containsKey('success')) {
      if (body['success'] == true) {
        return body['data'];
      } else {
        throw ApiException(
          message: body['message']?.toString() ?? 'Request failed',
          statusCode: response.statusCode ?? 500,
        );
      }
    }

    return body;
  }

  /// Run simulation on backend
  Future<SimulationResult> runSimulation(SimulationInput input) async {
    try {
      final response = await post<dynamic>(
        '/api/simulation/run',
        data: input.toMap(),
      );

      final data = _unwrap(response);
      if (data != null && data is Map<String, dynamic>) {
        return SimulationResult.fromMap(data);
      } else {
        throw ApiException(
          message: 'Invalid response from server',
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
      final response = await get<dynamic>(
        '/api/simulation/$id',
      );

      final data = _unwrap(response);
      if (data != null && data is Map<String, dynamic>) {
        return SimulationResult.fromMap(data);
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
      final response = await get<dynamic>(
        '/api/simulation/history',
      );

      final data = _unwrap(response);
      if (data != null && data is List) {
        return data
            .map((item) =>
                SimulationResult.fromMap(item as Map<String, dynamic>))
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
      final response = await post<dynamic>(
        '/api/simulation',
        data: {"name": result.name, "result": result.toMap()},
      );

      final data = _unwrap(response);
      if (data != null && data is Map<String, dynamic>) {
        return SimulationResult.fromMap(data);
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
      final response = await delete<dynamic>('/api/simulation/$id');
      _unwrap(response); // Unwrap to check for success: false
    } catch (e) {
      // Endpoint may return a successful response with no data
    }
  }

  /// Get simulation statistics
  Future<Map<String, dynamic>> getSimulationStats() async {
    try {
      final response = await get<dynamic>(
        '/api/simulation/stats',
      );

      final data = _unwrap(response);
      if (data != null && data is Map<String, dynamic>) {
        return data;
      }
      return {};
    } catch (e) {
      rethrow;
    }
  }

  /// Run parallel futures simulation
  Future<Map<String, SimulationResult>> runParallelFutures(
      SimulationInput input) async {
    try {
      final response = await post<dynamic>(
        '/api/simulation/parallel-futures',
        data: input.toMap(),
      );

      final data = _unwrap(response);
      if (data != null && data is Map<String, dynamic>) {
        return {
          'current':
              SimulationResult.fromMap(data['current'] as Map<String, dynamic>),
          'optimized': SimulationResult.fromMap(
              data['optimized'] as Map<String, dynamic>),
          'decline':
              SimulationResult.fromMap(data['decline'] as Map<String, dynamic>),
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
