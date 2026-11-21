part of 'measurement_interpolation.dart';

/// Days the Gaussian interpolation extrapolates before the first and after
/// the last measurement.
const int _gaussianOffsetInDays = 21;

/// The Gaussian interpolation: linear interpolation, linear extrapolation by
/// a Gaussian-weighted regression, and Gaussian smoothing in two passes, on a
/// grid padded by [_gaussianOffsetInDays] days. The rate is the five-point
/// derivative of the smoothed curve.
_InterpolationResult _computeGaussian(_InterpolationPayload p) {
  const int dayInMs = 24 * 3600 * 1000;
  const int offsetInDays = _gaussianOffsetInDays;
  const int offsetInDaysShown =
      MeasurementInterpolationBaseclass._offsetInDaysShown;
  const int pad = offsetInDays - offsetInDaysShown;
  final int n = p.gridLength + 2 * pad;

  final List<double> timesData = <double>[
    for (int idx = 0; idx < n; idx++)
      DateTime(
        p.firstDay.year,
        p.firstDay.month,
        p.firstDay.day + idx - offsetInDays,
      ).millisecondsSinceEpoch.toDouble(),
  ];
  final List<int> idxsMeasurements = <int>[
    for (final int idx in p.idxsMeasurements) idx + pad,
  ];
  final List<double> weightsData = List<double>.filled(n, 0);
  final List<double> isMeasurementData = List<double>.filled(n, 0);
  for (int k = 0; k < idxsMeasurements.length; k++) {
    weightsData[idxsMeasurements[k]] = p.weightsMeasured[k];
    isMeasurementData[idxsMeasurements[k]] = 1;
  }
  final List<double> isNoMeasurementData = <double>[
    for (final double isMeasured in isMeasurementData) 1 - isMeasured,
  ];
  final List<double> sigma = List<double>.generate(n, (int i) {
    final double s =
        isMeasurementData[i] * p.strengthMeasurement +
        isNoMeasurementData[i] * p.strengthInterpol;
    return s * dayInMs;
  });
  // Beyond ten widths a Gaussian adds less than 1e-21 of its peak, below
  // double precision, so the sums stop there instead of spanning all days.
  final int window = (10 * p.strengthMeasurement).ceil();
  int lower(int idx) => math.max(0, idx - window);
  int upper(int idx) => math.min(n, idx + window + 1);

  double gaussian(int j, double t) {
    final double s = sigma[j];
    final double diff = timesData[j] - t;
    return math.exp(-diff * diff / (2 * s * s)) /
        (s * math.sqrt(2 * math.pi)) *
        (isMeasurementData[j] * p.interpolWeight + isNoMeasurementData[j]);
  }

  double slope(int from, int to, List<double> w) =>
      w.isNotEmpty ? (w[to] - w[from]) / (to - from) : 0;

  List<double> linearInterpolation(List<double> w) {
    final List<double> out = List<double>.of(w);
    if (idxsMeasurements.length <= 1) {
      if (idxsMeasurements.length == 1) {
        return List<double>.filled(n, w[idxsMeasurements[0]]);
      }
      return out;
    }
    for (int i = 0; i < idxsMeasurements.length - 1; i++) {
      final int from = idxsMeasurements[i];
      final int to = idxsMeasurements[i + 1];
      if (from + 1 < to) {
        final double rate = slope(from, to, w);
        for (int j = from + 1; j < to; j++) {
          out[j] = out[from] + rate * (j - from);
        }
      }
    }
    return out;
  }

  /// Linear regression around [ref] with Gaussian weights, evaluated on the
  /// days from [startIdx] to [endIdx].
  List<double> linearRegression(
    List<double> w,
    int ref,
    int startIdx,
    int endIdx,
  ) {
    final double tRef = timesData[ref];
    final List<double> gw = List<double>.filled(n, 0);
    double total = 0;
    for (int j = lower(ref); j < upper(ref); j++) {
      if (w[j] > 0) {
        gw[j] = gaussian(j, tRef);
        total += gw[j];
      }
    }
    double meanW = 0, meanT = 0;
    for (int j = lower(ref); j < upper(ref); j++) {
      gw[j] /= total;
      meanW += gw[j] * w[j];
      meanT += gw[j] * timesData[j];
    }
    double numChange = 0, denChange = 0;
    for (int j = lower(ref); j < upper(ref); j++) {
      numChange += gw[j] * (w[j] - meanW) * timesData[j];
      denChange += gw[j] * (timesData[j] - meanT) * timesData[j];
    }
    final double meanChange = denChange != 0 ? numChange / denChange : 0;
    final double intercept = meanW - meanChange * meanT;
    return List<double>.generate(endIdx - startIdx, (int i) {
      final double v = meanChange * timesData[startIdx + i] + intercept;
      return v < 0 ? 0 : v;
    });
  }

  List<double> linearExtrapolation(List<double> w) {
    final List<double> out = List<double>.of(w);
    if (idxsMeasurements.length <= 1) {
      if (idxsMeasurements.length == 1) {
        return List<double>.filled(n, w[idxsMeasurements[0]]);
      }
      return out;
    }
    final List<double> initExtrapol = linearRegression(
      w,
      offsetInDays,
      0,
      offsetInDays,
    );
    final List<double> finalExtrapol = linearRegression(
      w,
      n - offsetInDays,
      n - offsetInDays,
      n,
    );
    for (int i = 0; i < offsetInDays; i++) {
      out[i] = initExtrapol[i];
      out[n - offsetInDays + i] = finalExtrapol[i];
    }
    return out;
  }

  List<double> gaussianInterpolation(List<double> w) {
    final List<double> result = List<double>.filled(n, 0);
    for (int idx = 0; idx < n; idx++) {
      if (w[idx] == 0) {
        continue;
      }
      double weightedSum = 0, normSum = 0;
      for (int j = lower(idx); j < upper(idx); j++) {
        if (w[j] <= 0) {
          continue;
        }
        final double val = gaussian(j, timesData[idx]);
        weightedSum += val * w[j];
        normSum += val;
      }
      result[idx] = normSum > 0 ? weightedSum / normSum : 0;
    }
    return result;
  }

  // ---- Pass 1: smoothed measurements ----
  final List<double> smoothedRaw = gaussianInterpolation(
    linearExtrapolation(linearInterpolation(weightsData)),
  );
  final List<double> weightsSmoothed = List<double>.generate(
    n,
    (int i) => smoothedRaw[i] * isMeasurementData[i],
  );

  // ---- Pass 2: the curve ----
  final List<double> curve = gaussianInterpolation(
    linearExtrapolation(linearInterpolation(weightsSmoothed)),
  );

  double derivative(int idx) {
    if (idx - 2 >= 0 && idx + 2 < n) {
      return (curve[idx - 2] -
              8 * curve[idx - 1] +
              8 * curve[idx + 1] -
              curve[idx + 2]) /
          12;
    } else if (idx - 1 >= 0 && idx + 1 < n) {
      return (curve[idx - 1] - curve[idx + 1]) / 2;
    }
    return 0;
  }

  final List<double> weights;
  if (p.isNone) {
    final List<double> wLinear = linearInterpolation(
      weightsData,
    ).sublist(offsetInDays, n - offsetInDays);
    final int idxLast = n - 1 - offsetInDays;
    final double finalSlope = slope(
      idxLast,
      idxLast + offsetInDaysShown,
      curve,
    );
    weights = <double>[
      ...wLinear,
      for (int i = 1; i <= offsetInDaysShown; i++)
        wLinear.last + finalSlope * i,
    ];
  } else {
    weights = curve.sublist(
      offsetInDays - offsetInDaysShown,
      n - offsetInDays + offsetInDaysShown,
    );
  }

  return _InterpolationResult(
    weights: weights,
    // Display indices map to the curve as they did before the physiological
    // model, 'none' included, so that the rates stay the same.
    slopes: <double>[
      for (int i = 0; i < weights.length; i++) derivative(i + pad),
    ],
    refitted: null,
  );
}
