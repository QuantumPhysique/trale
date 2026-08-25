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
