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

/// Lowest day-to-day noise variance in kg² the smoothing assumes, (0.1 kg)².
///
/// On a short history the noise is estimated from a handful of readings and
/// would otherwise come out far too small, making the band falsely narrow.
const double minimumNoiseVariance = 0.01;
