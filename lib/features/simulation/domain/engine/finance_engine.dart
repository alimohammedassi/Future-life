import 'dart:math';
import '../../../../core/constants/app_constants.dart';

class FinanceEngine {
  /// Future value of recurring monthly deposits with compound interest.
  ///
  /// Formula: FV = PMT × [ (1 + r)^n − 1 ] / r
  /// where r = monthly rate, n = total months
  double calculateProjectedSavings({
    required double monthlyPayment,
    required double annualRate,
    required int years,
  }) {
    if (monthlyPayment <= 0) return 0;

    final monthlyRate = annualRate / AppConstants.compoundsPerYear;
    final totalMonths = years * AppConstants.compoundsPerYear;

    // Future Value of Ordinary Annuity
    final fv =
        monthlyPayment * (pow(1 + monthlyRate, totalMonths) - 1) / monthlyRate;
    return fv;
  }
}
