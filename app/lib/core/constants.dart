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

/// Body weight in kg at which the strengths' slope sd is stated.
const double strengthReferenceKg = 83;

/// Exponent of body weight that scales the slope sd (Kleiber 1932): energy use
/// grows with weight^0.75, so the same relative calorie cut moves a smaller
/// body faster in percent.
const double kleiberExponent = -0.25;

/// Last readings whose mean is the body weight the slope sd is scaled to.
const int readingsForBodyWeight = 10;

/// Two-sided z of the 95 % band.
const double z95 = 1.959963984540054;

/// Fewest days with measurements for the predictive band.
///
/// On fewer days the noise estimate is too uncertain for a band.
const int minimumDaysForBand = 7;
