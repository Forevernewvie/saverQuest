class SavingsCalculationInput {
  const SavingsCalculationInput({
    required this.beforePrice,
    required this.afterPrice,
    required this.monthlyCount,
  });

  final int beforePrice;
  final int afterPrice;
  final int monthlyCount;
}

class SavingsCalculationResult {
  const SavingsCalculationResult({required this.monthlySavings});

  final int monthlySavings;
}

enum SavingsValidationError {
  beforePriceMustBeGreater,
  monthlyCountMustBePositive,
}

class SavingsCalculator {
  const SavingsCalculator();

  /// Validates user input before running the savings calculation.
  SavingsValidationError? validate(SavingsCalculationInput input) {
    if (input.beforePrice <= input.afterPrice) {
      return SavingsValidationError.beforePriceMustBeGreater;
    }
    if (input.monthlyCount <= 0) {
      return SavingsValidationError.monthlyCountMustBePositive;
    }
    return null;
  }

  /// Calculates monthly savings from the validated input values.
  SavingsCalculationResult calculate(SavingsCalculationInput input) {
    return SavingsCalculationResult(
      monthlySavings:
          (input.beforePrice - input.afterPrice) * input.monthlyCount,
    );
  }
}
