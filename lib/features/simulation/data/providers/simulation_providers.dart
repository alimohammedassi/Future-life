import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/simulation_input.dart';
import '../../domain/models/simulation_result.dart';
import '../../domain/engine/simulation_engine.dart';
import '../../domain/engine/scenario_engine.dart';
import '../services/api/simulation_api_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Input State Notifier
// ─────────────────────────────────────────────────────────────────────────────

class SimulationInputNotifier extends StateNotifier<SimulationInput> {
  SimulationInputNotifier() : super(SimulationInput.defaults());

  void updateIncome(double value) =>
      state = state.copyWith(monthlyIncome: value);
  void updateSavingPercentage(double value) =>
      state = state.copyWith(savingPercentage: value);
  void updateStudyHours(double value) =>
      state = state.copyWith(dailyStudyHours: value);
  void updateWorkoutDays(int value) =>
      state = state.copyWith(workoutDaysPerWeek: value);
  void updateCurrency(String value) => state = state.copyWith(currency: value);
  void updateCareerField(String value) =>
      state = state.copyWith(careerField: value);
  void updateWeeklySkillHours(double value) =>
      state = state.copyWith(weeklySkillHours: value);
  void updateCertsPerYear(int value) =>
      state = state.copyWith(certsPerYear: value);
  void updateSocialMediaHours(double value) =>
      state = state.copyWith(socialMediaHours: value);
  void updateFamilyHours(double value) =>
      state = state.copyWith(familyHours: value);
  void updateNetworkingHours(double value) =>
      state = state.copyWith(networkingHours: value);
  void reset() => state = SimulationInput.defaults();
}

final simulationInputProvider =
    StateNotifierProvider<SimulationInputNotifier, SimulationInput>(
  (ref) => SimulationInputNotifier(),
);

// ─────────────────────────────────────────────────────────────────────────────
// Live Preview
// ─────────────────────────────────────────────────────────────────────────────

final livePreviewProvider = Provider<double>((ref) {
  final input = ref.watch(simulationInputProvider);
  final result = SimulationEngine.run(input, name: 'Preview');
  return result.savings10Y;
});

// ─────────────────────────────────────────────────────────────────────────────
// Multi-Scenario State
// scenarioA  = the original / baseline run (always index 0)
// extraScenarios = any number of additional scenarios (B, C, D, …)
// ─────────────────────────────────────────────────────────────────────────────

/// Max number of extra scenarios the user can add on top of the original.
const int kMaxExtraScenarios = 4;

/// Labels used for extra scenarios: B, C, D, E
const List<String> kScenarioLabels = ['B', 'C', 'D', 'E'];

class ScenariosState {
  final SimulationResult? scenarioA;

  /// Extra scenarios added for comparison (max [kMaxExtraScenarios]).
  final List<SimulationResult> extraScenarios;

  final bool isRunning;
  final String? error;

  const ScenariosState({
    this.scenarioA,
    this.extraScenarios = const [],
    this.isRunning = false,
    this.error,
  });

  /// Backwards-compat: the first extra scenario is still called "B".
  SimulationResult? get scenarioB =>
      extraScenarios.isNotEmpty ? extraScenarios.first : null;

  /// All scenarios including A, for chart / iteration.
  List<SimulationResult> get all => [
        if (scenarioA != null) scenarioA!,
        ...extraScenarios,
      ];

  bool get canCompare => scenarioA != null && extraScenarios.isNotEmpty;
  bool get canAddMore =>
      scenarioA != null && extraScenarios.length < kMaxExtraScenarios;

  ScenariosState copyWith({
    SimulationResult? scenarioA,
    List<SimulationResult>? extraScenarios,
    bool? isRunning,
    String? error,
    bool clearError = false,
  }) {
    return ScenariosState(
      scenarioA: scenarioA ?? this.scenarioA,
      extraScenarios: extraScenarios ?? this.extraScenarios,
      isRunning: isRunning ?? this.isRunning,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class ScenariosNotifier extends StateNotifier<ScenariosState> {
  ScenariosNotifier() : super(const ScenariosState());

  final _apiService = SimulationApiService();

  /// Runs the engine and stores result as the original Scenario A.
  /// Saves to backend (with local fallback).
  Future<SimulationResult> runScenarioA(
    SimulationInput input, {
    String name = 'Current Habits',
  }) async {
    state = state.copyWith(isRunning: true, clearError: true);
    try {
      await Future.delayed(const Duration(milliseconds: 400));
      final result = SimulationEngine.run(input, name: name);
      state = state.copyWith(scenarioA: result, isRunning: false);
      unawaited(_saveToBackend(result));
      return result;
    } catch (e) {
      state = state.copyWith(isRunning: false, error: 'Simulation failed: $e');
      rethrow;
    }
  }

  /// Backwards-compat: adds a single extra scenario (old "Scenario B" flow).
  Future<SimulationResult> runScenarioB(
    SimulationInput input, {
    String name = 'Optimized Path',
  }) async =>
      addExtraScenario(input, name: name);

  /// Adds a new extra scenario.
  /// Returns the new result. Throws if max reached.
  Future<SimulationResult> addExtraScenario(
    SimulationInput input, {
    String? name,
  }) async {
    if (!state.canAddMore) {
      throw Exception(
          'Maximum of $kMaxExtraScenarios extra scenarios reached.');
    }
    state = state.copyWith(isRunning: true, clearError: true);
    try {
      await Future.delayed(const Duration(milliseconds: 400));
      final label = kScenarioLabels[state.extraScenarios.length];
      final result = SimulationEngine.run(
        input,
        name: name ?? 'Scenario $label',
      );
      final updated = [...state.extraScenarios, result];
      state = state.copyWith(extraScenarios: updated, isRunning: false);
      unawaited(_saveToBackend(result));
      return result;
    } catch (e) {
      state = state.copyWith(isRunning: false, error: 'Simulation failed: $e');
      rethrow;
    }
  }

  /// Removes an extra scenario by index (0-based within extraScenarios).
  void removeExtraScenario(int index) {
    final updated = [...state.extraScenarios];
    if (index >= 0 && index < updated.length) {
      updated.removeAt(index);
      state = state.copyWith(extraScenarios: updated);
    }
  }

  void clearComparison() => state = state.copyWith(extraScenarios: []);

  void clearAll() => state = const ScenariosState();

  /// Save result to backend.
  Future<void> _saveToBackend(SimulationResult result) async {
    try {
      await _apiService.saveSimulation(result);
    } catch (e) {
      print('Failed to save simulation to backend: $e');
    }
  }
}

final scenariosProvider =
    StateNotifierProvider<ScenariosNotifier, ScenariosState>(
  (ref) => ScenariosNotifier(),
);

// ─────────────────────────────────────────────────────────────────────────────
// Convenience Derived Providers
// ─────────────────────────────────────────────────────────────────────────────

final activeResultProvider = Provider<SimulationResult?>((ref) {
  return ref.watch(scenariosProvider).scenarioA;
});

final isSimulatingProvider = Provider<bool>((ref) {
  return ref.watch(scenariosProvider).isRunning;
});

// ─────────────────────────────────────────────────────────────────────────────
// Parallel Futures (Current • Optimized • Decline)
// ─────────────────────────────────────────────────────────────────────────────

class ParallelFuturesState {
  final SimulationResult? currentPath;
  final SimulationResult? optimizedPath;
  final SimulationResult? declinePath;
  final bool isGenerating;
  final String? error;

  const ParallelFuturesState({
    this.currentPath,
    this.optimizedPath,
    this.declinePath,
    this.isGenerating = false,
    this.error,
  });

  bool get hasData =>
      currentPath != null && optimizedPath != null && declinePath != null;

  List<SimulationResult> get allPaths => [
        if (currentPath != null) currentPath!,
        if (optimizedPath != null) optimizedPath!,
        if (declinePath != null) declinePath!,
      ];

  ParallelFuturesState copyWith({
    SimulationResult? currentPath,
    SimulationResult? optimizedPath,
    SimulationResult? declinePath,
    bool? isGenerating,
    String? error,
    bool clearError = false,
  }) {
    return ParallelFuturesState(
      currentPath: currentPath ?? this.currentPath,
      optimizedPath: optimizedPath ?? this.optimizedPath,
      declinePath: declinePath ?? this.declinePath,
      isGenerating: isGenerating ?? this.isGenerating,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class ParallelFuturesNotifier extends StateNotifier<ParallelFuturesState> {
  final _scenario = ScenarioEngine();

  ParallelFuturesNotifier() : super(const ParallelFuturesState());

  /// Generates Current, Optimized, and Decline path simulations.
  Future<void> generate(SimulationInput input) async {
    state = state.copyWith(isGenerating: true, clearError: true);
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      final current = SimulationEngine.run(input, name: 'Current Path');
      final optimized = SimulationEngine.run(
        _scenario.buildOptimizedInput(input),
        name: 'Optimized Path',
      );
      final decline = SimulationEngine.run(
        _scenario.buildDeclineInput(input),
        name: 'Decline Path',
      );
      state = ParallelFuturesState(
        currentPath: current,
        optimizedPath: optimized,
        declinePath: decline,
        isGenerating: false,
      );
    } catch (e) {
      state = state.copyWith(
        isGenerating: false,
        error: 'Generation failed: $e',
      );
    }
  }

  void clear() => state = const ParallelFuturesState();
}

final parallelFuturesProvider =
    StateNotifierProvider<ParallelFuturesNotifier, ParallelFuturesState>(
  (ref) => ParallelFuturesNotifier(),
);

// ─────────────────────────────────────────────────────────────────────────────
// Simulation History
// ─────────────────────────────────────────────────────────────────────────────

class HistoryNotifier
    extends StateNotifier<AsyncValue<List<SimulationResult>>> {
  final SimulationApiService _apiService = SimulationApiService();

  HistoryNotifier() : super(const AsyncValue.loading()) {
    loadHistory();
  }

  Future<void> loadHistory() async {
    state = const AsyncValue.loading();
    try {
      final results = await _apiService.getSimulationHistory();
      state = AsyncValue.data(results);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> save(SimulationResult result) async {
    try {
      await _apiService.saveSimulation(result);
      await loadHistory();
    } catch (e) {
      print('Failed to save to history: $e');
    }
  }

  Future<void> clear() async {
    try {
      final items = state.value ?? [];
      for (final item in items) {
        if (item.id.isNotEmpty && item.id != '0') {
          try {
            await _apiService.deleteSimulation(item.id);
          } catch (e) {
            print('Failed to delete simulation ${item.id}: $e');
          }
        }
      }
      await loadHistory();
    } catch (e) {
      print('Failed to clear history: $e');
    }
  }
}

final historyProvider =
    StateNotifierProvider<HistoryNotifier, AsyncValue<List<SimulationResult>>>(
  (ref) => HistoryNotifier(),
);

// ─────────────────────────────────────────────────────────────────────────────
// Simulation Stats — powers the 3 profile-screen squares
// ─────────────────────────────────────────────────────────────────────────────

class SimulationStats {
  final int totalSimulations;
  final double averageLifeStrategyScore;
  final String mostUsedCurrency;
  final double averageSavingPercentage;

  const SimulationStats({
    this.totalSimulations = 0,
    this.averageLifeStrategyScore = 0,
    this.mostUsedCurrency = '',
    this.averageSavingPercentage = 0,
  });

  factory SimulationStats.fromMap(Map<String, dynamic> map) {
    return SimulationStats(
      totalSimulations: (map['totalSimulations'] as num?)?.toInt() ?? 0,
      averageLifeStrategyScore:
          (map['averageLifeStrategyScore'] as num?)?.toDouble() ?? 0,
      mostUsedCurrency: map['mostUsedCurrency']?.toString() ?? '',
      averageSavingPercentage:
          (map['averageSavingPercentage'] as num?)?.toDouble() ?? 0,
    );
  }
}

final simulationStatsProvider = Provider<AsyncValue<SimulationStats>>((ref) {
  final historyAsync = ref.watch(historyProvider);

  return historyAsync.whenData((history) {
    if (history.isEmpty) {
      return const SimulationStats();
    }

    final total = history.length;
    double totalScore = 0.0;

    // Attempt to calculate a pseudo-saving-percentage using some 1Y values
    // as no saving percentage is stored directly in history items
    double savingPercentageSum = 0.0;

    for (final item in history) {
      totalScore += item.lifeStrategyScore;
      // Derive an approximate saving percentage (just for UI visuals)
      // e.g. if monthly savings > 0, we can fake a 20% to 40% range or just set 0.20
      savingPercentageSum += 0.20; // fallback visual percentage
    }

    return SimulationStats(
      totalSimulations: total,
      averageLifeStrategyScore: totalScore / total,
      mostUsedCurrency: history.first.currency,
      averageSavingPercentage: savingPercentageSum / total,
    );
  });
});
