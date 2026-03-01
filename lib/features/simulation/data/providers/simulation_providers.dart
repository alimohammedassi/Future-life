import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/simulation_input.dart';
import '../../domain/models/simulation_result.dart';
import '../../domain/engine/simulation_engine.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Input State Notifier
// Manages the live form input and the real-time preview.
// ─────────────────────────────────────────────────────────────────────────────

/// Notifier that holds and mutates the current [SimulationInput].
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

/// Provider for the live input state.
final simulationInputProvider =
    StateNotifierProvider<SimulationInputNotifier, SimulationInput>(
  (ref) => SimulationInputNotifier(),
);

// ─────────────────────────────────────────────────────────────────────────────
// Live Preview Provider
// Computes a quick 10-year projection from the current input in real-time.
// ─────────────────────────────────────────────────────────────────────────────

/// Derived provider that auto-recomputes the 10-year preview when input changes.
final livePreviewProvider = Provider<double>((ref) {
  final input = ref.watch(simulationInputProvider);
  final result = SimulationEngine.run(input, name: 'Preview');
  return result.savings10Y;
});

// ─────────────────────────────────────────────────────────────────────────────
// Simulation Result State
// Holds saved results for Scenario A and B, enables comparison.
// ─────────────────────────────────────────────────────────────────────────────

/// State object containing up to two saved scenario results.
class ScenariosState {
  final SimulationResult? scenarioA;
  final SimulationResult? scenarioB;
  final bool isRunning;
  final String? error;

  const ScenariosState({
    this.scenarioA,
    this.scenarioB,
    this.isRunning = false,
    this.error,
  });

  ScenariosState copyWith({
    SimulationResult? scenarioA,
    SimulationResult? scenarioB,
    bool? isRunning,
    String? error,
    bool clearError = false,
    bool clearScenarioB = false,
  }) {
    return ScenariosState(
      scenarioA: scenarioA ?? this.scenarioA,
      scenarioB: clearScenarioB ? null : (scenarioB ?? this.scenarioB),
      isRunning: isRunning ?? this.isRunning,
      error: clearError ? null : (error ?? this.error),
    );
  }

  /// Whether comparison mode is available (both scenarios saved).
  bool get canCompare => scenarioA != null && scenarioB != null;
}

/// Notifier that runs the simulation and manages scenario results.
class ScenariosNotifier extends StateNotifier<ScenariosState> {
  ScenariosNotifier() : super(const ScenariosState());

  /// Runs the engine with [input] and stores as Scenario A.
  Future<SimulationResult> runScenarioA(
    SimulationInput input, {
    String name = 'Current Habits',
  }) async {
    state = state.copyWith(isRunning: true, clearError: true);

    try {
      // Slight delay for UX — shows loading state smoothly
      await Future.delayed(const Duration(milliseconds: 400));
      final result = SimulationEngine.run(input, name: name);
      state = state.copyWith(scenarioA: result, isRunning: false);
      return result;
    } catch (e) {
      state = state.copyWith(
        isRunning: false,
        error: 'Simulation failed: $e',
      );
      rethrow;
    }
  }

  /// Saves the current [input] as Scenario B for comparison.
  Future<SimulationResult> runScenarioB(
    SimulationInput input, {
    String name = 'Optimized Path',
  }) async {
    state = state.copyWith(isRunning: true, clearError: true);
    try {
      await Future.delayed(const Duration(milliseconds: 400));
      final result = SimulationEngine.run(input, name: name);
      state = state.copyWith(scenarioB: result, isRunning: false);
      return result;
    } catch (e) {
      state = state.copyWith(
        isRunning: false,
        error: 'Simulation failed: $e',
      );
      rethrow;
    }
  }

  void clearComparison() {
    state = state.copyWith(clearScenarioB: true);
  }

  void clearAll() {
    state = const ScenariosState();
  }
}

/// Provider for all scenario results and comparison state.
final scenariosProvider =
    StateNotifierProvider<ScenariosNotifier, ScenariosState>(
  (ref) => ScenariosNotifier(),
);

// ─────────────────────────────────────────────────────────────────────────────
// Convenience Derived Providers
// ─────────────────────────────────────────────────────────────────────────────

/// Provider: active (primary) simulation result.
final activeResultProvider = Provider<SimulationResult?>((ref) {
  return ref.watch(scenariosProvider).scenarioA;
});

/// Provider: whether a result is currently being computed.
final isSimulatingProvider = Provider<bool>((ref) {
  return ref.watch(scenariosProvider).isRunning;
});
