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

/// Slowest trend still counted as heading towards the target, as a fraction
/// of body weight per day: 0.005 kg/day at 83 kg.
const double minSlopeToTarget = 0.00006;

/// Median gap in days between measurements from which a diary is read as
/// sparse: its rate is then the tissue trend's level change over
/// [sparseRateWindowInDays], which such a diary separates better from the
/// week-scale changes than the slope.
const int sparseGapInDays = 7;

/// Last gaps between measurements whose median decides whether a diary is
/// sparse.
const int sparseGapsCounted = 10;

/// Days over which a sparse diary's rate is read.
const int sparseRateWindowInDays = 14;

/// Tolerance of the maintain goal, relative to its target weight.
const double maintainTolerance = 0.01;

/// Days over which the tissue trend's slope fades.
///
/// Over weeks a slope is set by behaviour, not by the body: it holds, then
/// changes on a date. 30 days gave the best forecasts.
const double tissueSlopeMemoryInDays = 30;

/// Length scale in days of the week-scale changes the curve follows.
const double weekScaleLengthInDays = 7;

/// Length scale in days of water and gut content, which follow what was eaten
/// and relax within about a day (Hall et al. 2011).
const double waterLengthInDays = 1;

/// Prior centre of the week-scale and the water amplitude, as a fraction of
/// body weight: a day-to-day scatter of about 0.6 % (Khosla & Billewicz 1964;
/// Cheuvront et al. 2004), split between the two.
const double amplitudePriorCentre = 0.0042;

/// One prior standard deviation of an amplitude or of the scale error, as a
/// factor either way: the spread between people.
const double priorWidthFactor = 2;

/// Days with measurements before the first refit of the amplitudes and the
/// scale error.
const int firstRefitDays = 5;

/// Days with measurements up to which every new one refits.
const int refitEveryDayUpTo = 60;

/// New days with measurements between two refits after that.
const int refitIntervalDays = 7;
