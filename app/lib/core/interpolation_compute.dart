part of 'measurement_interpolation.dart';

// ---------------------------------------------------------------------------
// Isolate payload & top-level function
// ---------------------------------------------------------------------------

/// Data payload sent to a background isolate for the full interpolation
/// pipeline (linear interpolation, linear extrapolation with Gaussian
/// regression, Gaussian smoothing – two passes – and weightsDisplay).
class _InterpolationPayload {
  _InterpolationPayload({
    required this.timesData,
    required this.weightsData,
    required this.isMeasurementData,
    required this.isNoMeasurementData,
    required this.idxsMeasurements,
    required this.n,
    required this.offsetInDays,
    required this.offsetInDaysShown,
    required this.strengthMeasurement,
    required this.strengthInterpol,
    required this.interpolWeight,
    required this.interpolStrengthIsNone,
  });

  final List<double> timesData;
  final List<double> weightsData;
  final List<double> isMeasurementData;
  final List<double> isNoMeasurementData;
  final List<int> idxsMeasurements;
  final int n;
  final int offsetInDays;
  final int offsetInDaysShown;
  final double strengthMeasurement;
  final double strengthInterpol;
  final double interpolWeight;
  final bool interpolStrengthIsNone;
}

/// Result returned from the isolate containing all computed vectors.
class _InterpolationResult {
  _InterpolationResult({
    required this.weightsSmoothed,
    required this.weightsLinExtrapol,
    required this.weightsGaussianExtrapol,
    required this.weightsDisplay,
  });

  final List<double> weightsSmoothed;
  final List<double> weightsLinExtrapol;
  final List<double> weightsGaussianExtrapol;
  final List<double> weightsDisplay;
}

/// Top-level function that runs the full interpolation pipeline in a
/// background isolate.  Must be top-level (not a closure) for [compute].
_InterpolationResult _computeFullInterpolation(_InterpolationPayload p) {
  // Derived constants
  const int dayInMs = 24 * 3600 * 1000;

  // Build sigma list (same logic as the getter on the base class).
  final List<double> sigma = List<double>.generate(p.n, (int i) {
    final double s =
        p.isMeasurementData[i] * p.strengthMeasurement +
        p.isNoMeasurementData[i] * p.strengthInterpol;
    return s * dayInMs;
  });

  // ---- helpers (plain-list implementations) ----

  double slope(int from, int to, List<double> w) =>
      w.isNotEmpty ? (w[to] - w[from]) / (to - from) : 0;

  List<double> linearInterpolation(List<double> w) {
    final List<double> out = List<double>.of(w);
    if (p.idxsMeasurements.length <= 1) {
      if (p.idxsMeasurements.length == 1) {
        return List<double>.filled(p.n, w[p.idxsMeasurements[0]]);
      }
      return out;
    }
    for (int i = 0; i < p.idxsMeasurements.length - 1; i++) {
      final int from = p.idxsMeasurements[i];
      final int to = p.idxsMeasurements[i + 1];
      if (from + 1 < to) {
        final double rate = slope(from, to, w);
        for (int j = from + 1; j < to; j++) {
          out[j] = out[from] + rate * (j - from);
        }
      }
    }
    return out;
  }

  /// Compute Gaussian weights at reference point [tRef] and return them
  /// normalised so they sum to 1.
  List<double> gaussianWeights(double tRef, List<double> w) {
    final List<double> gw = List<double>.filled(p.n, 0);
    double total = 0;
    for (int j = 0; j < p.n; j++) {
      if (w[j] <= 0) {
        continue;
      }
      final double s = sigma[j];
      final double diff = p.timesData[j] - tRef;
      final double gaussVal =
          math.exp(-diff * diff / (2 * s * s)) /
          (s * math.sqrt(2 * math.pi));
      final double val =
          gaussVal *
          (p.isMeasurementData[j] * p.interpolWeight +
              p.isNoMeasurementData[j]);
      gw[j] = val;
      total += val;
    }
    if (total > 0) {
      for (int j = 0; j < p.n; j++) {
        gw[j] /= total;
      }
    }
    return gw;
  }

  /// Linear regression extrapolation using Gaussian-weighted moments.
  List<double> linearRegression(
    List<double> w,
    double tRef,
    int startIdx,
    int endIdx,
  ) {
    final List<double> gw = gaussianWeights(tRef, w);
    double meanW = 0, meanT = 0;
    for (int j = 0; j < p.n; j++) {
      meanW += gw[j] * w[j];
      meanT += gw[j] * p.timesData[j];
    }
    double numChange = 0, denChange = 0;
    for (int j = 0; j < p.n; j++) {
      numChange += gw[j] * (w[j] - meanW) * p.timesData[j];
      denChange +=
          gw[j] * (p.timesData[j] - meanT) * p.timesData[j];
    }
    final double meanChange =
        denChange != 0 ? numChange / denChange : 0;
    final double intercept = meanW - meanChange * meanT;
    final int count = endIdx - startIdx;
    return List<double>.generate(count, (int i) {
      final double t = p.timesData[startIdx + i];
      final double v = meanChange * t + intercept;
      return v < 0 ? 0 : v;
    });
  }

  List<double> linearExtrapolation(List<double> w) {
    final List<double> out = List<double>.of(w);
    if (p.idxsMeasurements.length <= 1) {
      if (p.idxsMeasurements.length == 1) {
        return List<double>.filled(p.n, w[p.idxsMeasurements[0]]);
      }
      return out;
    }
    final List<double> initExtrapol = linearRegression(
      w,
      p.timesData[p.offsetInDays],
      0,
      p.offsetInDays,
    );
    final List<double> finalExtrapol = linearRegression(
      w,
      p.timesData[p.n - p.offsetInDays],
      p.n - p.offsetInDays,
      p.n,
    );
    for (int i = 0; i < p.offsetInDays; i++) {
      out[i] = initExtrapol[i];
      out[p.n - p.offsetInDays + i] = finalExtrapol[i];
    }
    return out;
  }

  List<double> gaussianInterpolation(List<double> w) {
    final List<double> result = List<double>.filled(p.n, 0);
    for (int idx = 0; idx < p.n; idx++) {
      if (w[idx] == 0) {
        continue;
      }
      final double t = p.timesData[idx];
      double weightedSum = 0, normSum = 0;
      for (int j = 0; j < p.n; j++) {
        if (w[j] <= 0) {
          continue;
        }
        final double s = sigma[j];
        final double diff = p.timesData[j] - t;
        final double gaussVal =
            math.exp(-diff * diff / (2 * s * s)) /
            (s * math.sqrt(2 * math.pi));
        final double val =
            gaussVal *
            (p.isMeasurementData[j] * p.interpolWeight +
                p.isNoMeasurementData[j]);
        weightedSum += val * w[j];
        normSum += val;
      }
      result[idx] = normSum > 0 ? weightedSum / normSum : 0;
    }
    return result;
  }

  // ---- Pass 1: weightsSmoothed ----
  final List<double> linInterp =
      linearInterpolation(p.weightsData);
  final List<double> linExtrapol = linearExtrapolation(linInterp);
  final List<double> smoothedRaw =
      gaussianInterpolation(linExtrapol);
  // Zero out non-measurements
  final List<double> weightsSmoothed = List<double>.generate(
    p.n,
    (int i) => smoothedRaw[i] * p.isMeasurementData[i],
  );

  // ---- Pass 2: weightsGaussianExtrapol ----
  final List<double> linInterp2 =
      linearInterpolation(weightsSmoothed);
  final List<double> weightsLinExtrapol =
      linearExtrapolation(linInterp2);
  final List<double> weightsGaussianExtrapol =
      gaussianInterpolation(weightsLinExtrapol);

  // ---- weightsDisplay ----
  List<double> weightsDisplay;
  if (p.interpolStrengthIsNone) {
    final List<double> wLinear = linearInterpolation(
      p.weightsData,
    ).sublist(p.offsetInDays, p.n - p.offsetInDays);
    // finalSlope for extrapolation
    final int idxLast = p.n - 1 - p.offsetInDays;
    final double fSlope = slope(
      idxLast,
      idxLast + p.offsetInDaysShown,
      weightsGaussianExtrapol,
    );
    weightsDisplay = List<double>.from(wLinear);
    for (int i = 1; i <= p.offsetInDaysShown; i++) {
      weightsDisplay.add(wLinear.last + fSlope * i);
    }
  } else {
    weightsDisplay = weightsGaussianExtrapol.sublist(
      p.offsetInDays - p.offsetInDaysShown,
      p.n - p.offsetInDays + p.offsetInDaysShown,
    );
  }

  return _InterpolationResult(
    weightsSmoothed: weightsSmoothed,
    weightsLinExtrapol: weightsLinExtrapol,
    weightsGaussianExtrapol: weightsGaussianExtrapol,
    weightsDisplay: weightsDisplay,
  );
}
