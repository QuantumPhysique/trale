/// 24 hours expressed in milliseconds.
const int dayInMs = 24 * 3600 * 1000;

/// Approximate kcal per kg of body weight change.
const double kcalPerKg = 7700;

/// Lowest weight in kg accepted by manual keyboard entry.
///
/// Manual entry is an alternative to scrolling the ruler, so it spans the
/// same range: the ruler starts at zero, and so does typing.
const double minWeightKg = 0;

/// Widest weight in kg the manual entry field reserves room for.
///
/// The ruler has no upper end, so neither has typing: this is not a limit on
/// the value but the digit budget of the input field, which needs a fixed
/// width so it does not resize with every keystroke. It caps typed input
/// only in the sense that no more digits than these fit.
const double maxWeightKg = 500;

/// Slowest trend in kg/day still counted as heading towards the target.
const double minSlopeToTarget = 0.005;

/// Tolerance of the maintain goal, relative to its target weight.
const double maintainTolerance = 0.01;

/// Time scale over which the trend's rate of change fades, in smoothing
/// bandwidths.
///
/// Long enough that a steady rate still shows at 92 % at the last reading,
/// short enough that projections level off.
const double trendTimeScaleInBandwidths = 15;

/// Lowest day-to-day noise variance in kg² the smoothing assumes, (0.1 kg)².
///
/// On a short history the noise is estimated from a handful of readings and
/// would otherwise come out far too small, making the band falsely narrow.
const double minimumNoiseVariance = 0.01;

/// Fewest days with measurements for the predictive band.
///
/// On fewer days the noise estimate is too uncertain for a band.
const int minimumDaysForBand = 7;

/// Smoothing bandwidth in days the automatic strength starts from.
///
/// Where the out-of-sample error had flattened on all five test diaries while
/// the 30-day band still covered 89 to 97 % of the readings.
const double autoStrengthStartInDays = 5.5;

/// Days of history before the automatic strength fits its first value.
///
/// Shorter histories gave fits up to twenty times too small, often without a
/// warning: the two-day water wobble in the readings passes for trend.
const int autoStrengthMinHistoryInDays = 90;

/// New days with measurements between two fits of the automatic strength.
const int autoStrengthTryEveryDays = 30;

/// Widest plateau, in decades of the variance ratio, of a fit the automatic
/// strength accepts; 0.5 decades pin the bandwidth to ±15 %.
const double autoStrengthMaxPlateauDecades = 0.5;

/// Log-likelihood in nats by which a fit has to beat the strength in use to
/// replace it, so that noise in the fit does not move the curve.
const double autoStrengthMinGainInNats = 0.5;

/// Average length of a month in days.
const double daysPerMonth = 365.25 / 12;

/// GitHub Discussion where people share the summary of their automatic
/// strength.
// TODO(pb): a placeholder until braniii agrees to open the discussion.
const String autoStrengthDiscussionUrl =
    'https://github.com/QuantumPhysique/trale/discussions';
