/// 24 hours expressed in milliseconds.
const int dayInMs = 24 * 3600 * 1000;

/// Approximate kcal per kg of body weight change.
const double kcalPerKg = 7700;

/// Lowest weight in kg accepted by manual keyboard entry.
///
/// This is a typo guard for the numeric input field (e.g. a stray extra
/// digit), not a health policy — the target weight dialog applies its own,
/// stricter BMI based limit.
const double minWeightKg = 1;

/// Highest weight in kg accepted by manual keyboard entry.
const double maxWeightKg = 500;
