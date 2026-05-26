// Big-M simplex method for LP.
//
// Solves:  Minimize   c^T x
//          subject to  A_eq  x  =  b_eq    (equality constraints)
//                      A_geq x  ≥  b_geq   (≥ inequality constraints)
//                      x          ≥  0
//
// Variable layout in the tableau:
//   cols 0..n-1                 : original decision variables
//   cols n..n+mgeq-1            : surplus variables  s_i  (for ≥ constraints)
//   cols n+mgeq..n+mgeq+meq-1  : artificial vars  a_i  (for = constraints)
//   cols n+mgeq+meq..end-1     : artificial vars  a_i  (for ≥ constraints)
//   last col                    : RHS

import 'dart:math';

class LpResult {
  final bool feasible; // false → no blend can meet the target
  final List<double> x; // solution for original variables
  final double objective; // value of the minimised objective

  const LpResult({
    required this.feasible,
    required this.x,
    required this.objective,
  });

  factory LpResult.infeasible(int n) =>
      LpResult(feasible: false, x: List.filled(n, 0), objective: double.infinity);
}

/// Solve the LP by the Big-M simplex method.
///
/// Returns [LpResult.infeasible] when the constraints cannot be satisfied
/// (e.g. all cottons are weaker than the target even at 100%).
LpResult solveLp({
  required List<double> c, // objective coefficients (length n)
  List<List<double>> aeq = const [], // equality constraint matrix
  List<double> beq = const [], // equality RHS
  List<List<double>> ageq = const [], // ≥ constraint matrix
  List<double> bgeq = const [], // ≥ RHS
  double bigM = 1e8,
  double eps = 1e-9,
  int maxIter = 50000,
}) {
  final int n = c.length;
  final int meq = aeq.length;
  final int mgeq = ageq.length;
  final int m = meq + mgeq;

  if (m == 0) {
    // Unconstrained minimisation over non-negative reals: if any c_j < 0
    // the problem is unbounded; otherwise optimum is x=0.
    if (c.any((v) => v < -eps)) return LpResult.infeasible(n);
    return LpResult(feasible: true, x: List.filled(n, 0), objective: 0);
  }

  // Column index helpers
  final int surpStart = n; // surplus vars for ≥ constraints
  final int artEqStart = n + mgeq; // artificial vars for = constraints
  final int artGeqStart = n + mgeq + meq; // artificial vars for ≥ constraints
  final int totalVars = n + mgeq + meq + mgeq;
  final int rhs = totalVars; // index of RHS column

  final int cols = totalVars + 1;

  // Build tableau: row 0 = objective, rows 1..m = constraints
  final tab = List.generate(m + 1, (_) => List<double>.filled(cols, 0.0));

  // Objective row: original costs + Big-M for artificials
  for (int j = 0; j < n; j++) { tab[0][j] = c[j]; }
  for (int j = artEqStart; j < totalVars; j++) { tab[0][j] = bigM; }

  // Equality constraint rows  (rows 1..meq)
  for (int i = 0; i < meq; i++) {
    final row = i + 1;
    double rhsVal = beq[i];
    final double sign = rhsVal >= 0 ? 1.0 : -1.0;
    rhsVal = rhsVal.abs();
    for (int j = 0; j < n; j++) { tab[row][j] = sign * aeq[i][j]; }
    tab[row][artEqStart + i] = 1.0; // artificial enters with +1
    tab[row][rhs] = rhsVal;
  }

  // ≥ constraint rows  (rows meq+1..m)
  for (int i = 0; i < mgeq; i++) {
    final row = meq + i + 1;
    double rhsVal = bgeq[i];
    final double sign = rhsVal >= 0 ? 1.0 : -1.0;
    rhsVal = rhsVal.abs();
    for (int j = 0; j < n; j++) { tab[row][j] = sign * ageq[i][j]; }
    tab[row][surpStart + i] = -sign; // surplus: subtract if normal, add if negated
    tab[row][artGeqStart + i] = 1.0;
    tab[row][rhs] = rhsVal;
  }

  // Initial basis: one artificial per row
  final basis = List<int>.filled(m, 0);
  for (int i = 0; i < meq; i++) { basis[i] = artEqStart + i; }
  for (int i = 0; i < mgeq; i++) { basis[meq + i] = artGeqStart + i; }

  // Make objective row canonical: eliminate basic variables (the artificials)
  // by subtracting  tab[0][bv] * row_i  for each row i with basic var bv.
  for (int i = 0; i < m; i++) {
    final bv = basis[i];
    final coeff = tab[0][bv];
    if (coeff.abs() > eps) {
      for (int j = 0; j < cols; j++) { tab[0][j] -= coeff * tab[i + 1][j]; }
    }
  }

  // ── Simplex iterations ───────────────────────────────────────────────────
  for (int iter = 0; iter < maxIter; iter++) {
    // 1. Pivot column: most-negative reduced cost (entering variable)
    int pivCol = -1;
    double minRC = -eps;
    for (int j = 0; j < totalVars; j++) {
      if (tab[0][j] < minRC) {
        minRC = tab[0][j];
        pivCol = j;
      }
    }
    if (pivCol < 0) break; // all reduced costs ≥ 0  →  optimal

    // 2. Pivot row: minimum ratio test (Bland's tie-breaking for cycling safety)
    int pivRow = -1;
    double minRatio = double.infinity;
    for (int i = 1; i <= m; i++) {
      final aij = tab[i][pivCol];
      if (aij > eps) {
        final ratio = tab[i][rhs] / aij;
        if (ratio < minRatio - eps ||
            (ratio < minRatio + eps && pivRow >= 0 && basis[i - 1] < basis[pivRow - 1])) {
          minRatio = ratio;
          pivRow = i;
        }
      }
    }
    if (pivRow < 0) {
      // Unbounded: every valid entry has no finite ratio.
      // For a blend LP this should never happen (x_i ≤ 100 implicit).
      return LpResult.infeasible(n);
    }

    // 3. Update basis
    basis[pivRow - 1] = pivCol;

    // 4. Pivot: normalise pivot row, then eliminate from all other rows
    final pivVal = tab[pivRow][pivCol];
    for (int j = 0; j < cols; j++) { tab[pivRow][j] /= pivVal; }

    for (int i = 0; i <= m; i++) {
      if (i == pivRow) continue;
      final factor = tab[i][pivCol];
      if (factor.abs() > eps) {
        for (int j = 0; j < cols; j++) { tab[i][j] -= factor * tab[pivRow][j]; }
      }
    }
  }

  // ── Extract solution ─────────────────────────────────────────────────────
  // Check feasibility: if any artificial is still basic with value > eps the
  // LP has no feasible solution.
  for (int i = 0; i < m; i++) {
    if (basis[i] >= artEqStart && tab[i + 1][rhs] > eps) {
      return LpResult.infeasible(n);
    }
  }

  final x = List<double>.filled(n, 0.0);
  for (int i = 0; i < m; i++) {
    final bv = basis[i];
    if (bv < n) x[bv] = max(0.0, tab[i + 1][rhs]);
  }

  // Objective value = -tab[0][RHS]
  // (the objective row stores z - z̄ = reduced-cost · non-basics,
  //  so the constant term –z̄ sits in the RHS column; negating gives z̄).
  final objVal = -tab[0][rhs];

  return LpResult(feasible: true, x: x, objective: objVal);
}

// ── Convenience wrapper for the blend LP ────────────────────────────────────

/// Solves the blend optimisation LP exactly:
///
///   Minimize   Σ price_i · x_i             (total cost)
///   subject to Σ strength_i · x_i ≥ target · 100
///              Σ x_i = 100
///              x_i ≥ 0
///
/// Returns (ratios, blendStrength, costPerCandy, feasible).
/// If no feasible blend can hit [targetStrength], returns the max-strength blend
/// (best achievable) with feasible=false so the UI can warn the user.
({
  List<double> ratios,
  double blendStrength,
  double blendCostPerCandy,
  bool feasible,
}) solveBlendLP({
  required List<double> prices, // ₹/candy, one per cotton
  required List<double> strengths, // predicted yarn strength (same unit as target)
  required double targetStrength, // e.g. 20.0 RKM
}) {
  final n = prices.length;

  double blendStr(List<double> r) =>
      List.generate(n, (i) => r[i] * strengths[i]).fold(0.0, (a, b) => a + b) / 100.0;

  double blendCost(List<double> r) =>
      List.generate(n, (i) => r[i] * prices[i]).fold(0.0, (a, b) => a + b) / 100.0;

  // Attempt to solve the LP
  final result = solveLp(
    c: prices, // objective: minimise cost
    aeq: [List.filled(n, 1.0)], // Σx_i = 100
    beq: [100.0],
    ageq: [strengths], // Σstrength_i * x_i ≥ target*100
    bgeq: [targetStrength * 100],
  );

  if (result.feasible) {
    // Normalise ratios to sum exactly to 100 (floating-point clean-up)
    final sum = result.x.fold(0.0, (a, b) => a + b);
    final ratios = sum > 1e-10
        ? result.x.map((v) => v / sum * 100.0).toList()
        : result.x;

    return (
      ratios: ratios,
      blendStrength: blendStr(ratios),
      blendCostPerCandy: blendCost(ratios),
      feasible: true,
    );
  }

  // Infeasible: no blend meets the target.
  // Return the blend that maximises strength (cheapest price among the strongest).
  // Analytical: 100% of the cotton with highest strength.
  final maxStr = strengths.fold(double.negativeInfinity, max);
  final bestIdx = strengths.indexWhere((s) => (s - maxStr).abs() < 1e-9);
  final fallbackRatios = List<double>.filled(n, 0.0)..[bestIdx] = 100.0;

  return (
    ratios: fallbackRatios,
    blendStrength: blendStr(fallbackRatios),
    blendCostPerCandy: blendCost(fallbackRatios),
    feasible: false,
  );
}
