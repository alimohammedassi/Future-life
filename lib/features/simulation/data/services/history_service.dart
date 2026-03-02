import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/simulation_result.dart';

/// Persists simulation history to local SharedPreferences storage.
class HistoryService {
  static const String _historyKey = 'simulation_history_v2';
  static const int _maxEntries = 30;

  /// Loads all stored simulation results, newest first.
  Future<List<SimulationResult>> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_historyKey) ?? [];
    final results = <SimulationResult>[];
    for (final json in jsonList) {
      try {
        results.add(SimulationResult.fromJson(json));
      } catch (_) {
        // skip corrupted entries
      }
    }
    return results;
  }

  /// Prepends [result] to history, capped at [_maxEntries].
  Future<void> saveResult(SimulationResult result) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_historyKey) ?? [];
    jsonList.insert(0, result.toJson());
    if (jsonList.length > _maxEntries) {
      jsonList.removeRange(_maxEntries, jsonList.length);
    }
    await prefs.setStringList(_historyKey, jsonList);
  }

  /// Deletes all stored history.
  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }
}
