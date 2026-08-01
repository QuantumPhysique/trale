// Deterministic demo content for the screenshot tour.
//
// Each theme is fronted by its own [DemoPersona] — two losing weight, one
// keeping it, one gaining — so the marketing shots do not all show the same
// curve.  Everything is seeded from a fixed [Random] seed so two runs on the
// same day produce identical curves.  Dates are anchored to "today" on
// purpose: several stats cards (current streak, measurement frequency, time
// since first measurement) read [DateTime.now] and would render as `--` or
// `0` on a frozen historical dataset.

import 'dart:math';

import 'package:trale/core/measurement.dart';
import 'package:trale/core/zoom_level.dart';

/// Number of days of history the demo dataset spans.
///
/// Six months is a deliberate trade-off.  It keeps the chart legible — over a
/// much longer span the daily points compress into a featureless band — at the
/// cost of the "change / year" figure on the stats page, which renders `--`
/// because [MeasurementStats.deltaWeightLastYear] needs an interpolated value
/// a full 365 days back and the interpolation only reaches 21 days beyond the
/// oldest measurement.
const int demoHistoryDays = 186;

/// Number of most recent days that always carry a measurement.
///
/// Guarantees a non-zero current streak and a measurement dated today, which
/// the "current streak" and "days since last measurement" cards require.
const int demoStreakDays = 12;

/// Half-width in days of the moving average that rounds off the trend anchors.
const int _trendSmoothing = 12;

/// Weekday offset in kg, at the reference weight of [_referenceWeight].
///
/// The weekend shows on the scale on Sunday and Monday and has washed out
/// again by Friday.  A lookup rather than a sine wave on purpose: a perfectly
/// sinusoidal weekly rhythm is the most obvious tell of generated data.
const Map<int, double> _weekdayOffset = <int, double>{
  DateTime.monday: 0.32,
  DateTime.tuesday: 0.12,
  DateTime.wednesday: -0.02,
  DateTime.thursday: -0.10,
  DateTime.friday: -0.14,
  DateTime.saturday: 0.02,
  DateTime.sunday: 0.26,
};

/// Body weight in kg at which the noise amplitudes below were tuned.
///
/// Water retention, weekend swings and holiday gain all scale roughly with
/// body weight, so each persona scales them by `weight / _referenceWeight` —
/// a 63 kg maintainer does not swing as much as a 90 kg dieter.
const double _referenceWeight = 81;

/// First day (counted back from today) of the demo holiday.
const int _holidayFromDaysAgo = 108;

/// Last day (counted back from today) of the demo holiday.
///
/// No measurements are recorded from [_holidayFromDaysAgo] through here, and
/// the day after always carries one — the gap plus the rebound is what a real
/// diary looks like around a trip.
const int _holidayToDaysAgo = 100;

/// Weight in kg brought home from the holiday, at [_referenceWeight].
const double _holidayGain = 1.3;

/// Decay constant in days with which [_holidayGain] comes back off.
const double _holidayDecay = 5;

/// Probability of weighing in again the day after a day that was measured.
const double _keepGoing = 0.92;

/// Probability of picking the habit back up after a day that was missed.
///
/// Together with [_keepGoing] this is a two-state Markov chain, which produces
/// both isolated misses and the occasional two- or three-day lapse — unlike
/// independent per-day sampling, which only ever drops single days.
const double _pickUpAgain = 0.5;

/// How much of yesterday's water-retention swing carries into today.
const double _waterPersistence = 0.75;

/// Standard deviation in kg of the daily water-retention innovation, at
/// [_referenceWeight].
///
/// With [_waterPersistence] this settles at about 0.26 kg of swing, the low
/// end of what a real scale shows — which is what someone weighing in fasted
/// every morning, like this dataset does, actually sees.
///
/// Staying at the low end is also what keeps the screenshots coherent.  The
/// "change / month", "calorie deficit" and "weeks left to reach target weight"
/// cards are all driven by [MeasurementInterpolation.slopeAtDay], a five-point
/// derivative of a curve smoothed with a 4-day Gaussian — an estimator that
/// only sees about a week either side of today.  At twice this amplitude a
/// single ordinary swing in the final days swings that slope by a factor of
/// three, and the cards start contradicting the curve above them.
const double _waterKick = 0.17;

/// Standard deviation in kg of the scale's own reading error, at
/// [_referenceWeight].
const double _readingError = 0.08;

/// Standard normal sample drawn from [rng] (Box–Muller transform).
///
/// `1 - nextDouble()` lands in `(0, 1]`, keeping `log` away from zero.
double _gauss(Random rng) =>
    sqrt(-2 * log(1 - rng.nextDouble())) * cos(2 * pi * rng.nextDouble());

/// One demo user: name, body, goal and the weight course that goes with it.
///
/// The tour assigns one persona per captured theme, cycling through
/// [demoPersonas] when more themes than personas are requested.
class DemoPersona {
  /// Creates a persona; all values describe one coherent story.
  const DemoPersona({
    required this.name,
    required this.height,
    required this.seed,
    required this.anchors,
    required this.targetWeight,
    required this.targetSetDaysAgo,
    required this.targetDaysAhead,
  });

  /// User name shown in the user dialog.
  final String name;

  /// Body height in cm — without it the BMI card is not rendered.
  final double height;

  /// Seed of the persona's [Random].
  ///
  /// Not arbitrary: the last week or two of the series is what the
  /// slope-driven cards read, so each seed is chosen to leave the tail close
  /// to the persona's designed closing rate and those cards agreeing with the
  /// curve above them.
  final int seed;

  /// Corner points of the underlying weight trend, oldest first, in kg.
  ///
  /// Reads as a realistic six-month course rather than a straight line — the
  /// piecewise-linear corners are rounded off by [_trendAt] below.
  final List<({int day, double weight})> anchors;

  /// Target weight in kg.
  ///
  /// Below the current weight for the losers, above it for the gainer, and
  /// right at the maintained weight for the keeper.
  final double targetWeight;

  /// Days ago at which the target weight was "set".
  ///
  /// Snapped to the nearest actual measurement by [targetSetDate].
  final int targetSetDaysAgo;

  /// Days from today at which the target weight should be reached.
  ///
  /// Roughly consistent with each persona's closing trend, so the target date
  /// does not contradict the "months left to reach target weight" card next
  /// to it.
  final int targetDaysAhead;

  /// Whether this persona is working the scale downwards.
  ///
  /// Drives the `looseWeight` preference, which
  /// [MeasurementStats.timeOfTargetWeight] uses to decide on which side of the
  /// current weight the target counts as reached — left at the shipped
  /// default (losing), a gainer's target reads as already completed and the
  /// "time to target" card renders 🥳 instead of a forecast.
  bool get losesWeight => targetWeight < anchors.last.weight;

  /// Noise amplitude relative to the [_referenceWeight] the constants were
  /// tuned at.
  double get _noiseScale => anchors.last.weight / _referenceWeight;

  /// Weight in kg of the raw, unsmoothed trend on [day] (day 0 = oldest).
  ///
  /// Days outside the history are extrapolated along the first and last
  /// segment rather than clamped: [_trendAt] averages past both ends, and
  /// clamping there would flatten the start and — worse — the closing slope
  /// that the "months left to reach target weight" forecast is read from.
  double _anchorAt(int day) {
    for (int i = 1; i < anchors.length; i++) {
      final ({int day, double weight}) a = anchors[i - 1];
      final ({int day, double weight}) b = anchors[i];
      if (day < b.day || i == anchors.length - 1) {
        return a.weight +
            (b.weight - a.weight) * (day - a.day) / (b.day - a.day);
      }
    }
    return anchors.last.weight;
  }

  /// Weight in kg of the smoothed trend on [day] (day 0 = oldest).
  ///
  /// The piecewise-linear anchors show their corners as visible kinks in the
  /// chart; a centred moving average turns them into the gradual changes of
  /// pace a real course has.
  double _trendAt(int day) {
    double sum = 0;
    for (int d = day - _trendSmoothing; d <= day + _trendSmoothing; d++) {
      sum += _anchorAt(d);
    }
    return sum / (2 * _trendSmoothing + 1);
  }

  /// Builds the persona's weight history, newest entry dated today.
  ///
  /// Weights are in kg — the database always stores kg and unit conversion is
  /// display-only.
  List<Measurement> measurements() {
    final Random rng = Random(seed);
    final DateTime now = DateTime.now();
    final List<Measurement> result = <Measurement>[];
    final double scale = _noiseScale;

    double water = 0;
    bool measuredYesterday = true;

    for (int daysAgo = demoHistoryDays; daysAgo >= 0; daysAgo--) {
      // Advanced every day, including the ones that go unrecorded, so the
      // swing stays continuous across gaps.  Mean-reverting rather than
      // independent: water retention persists for days, which is what makes a
      // real series wander in clumps instead of scattering evenly around the
      // trend.
      water = _waterPersistence * water + _waterKick * scale * _gauss(rng);

      final bool onHoliday =
          daysAgo <= _holidayFromDaysAgo && daysAgo >= _holidayToDaysAgo;
      final bool firstDayBack = daysAgo == _holidayToDaysAgo - 1;
      final bool measured =
          daysAgo < demoStreakDays ||
          firstDayBack ||
          (!onHoliday &&
              rng.nextDouble() <
                  (measuredYesterday ? _keepGoing : _pickUpAgain));
      measuredYesterday = measured;
      if (!measured) {
        continue;
      }

      // Build the date from calendar components rather than subtracting a
      // Duration: Duration arithmetic shifts the wall-clock hour across DST
      // and could move an entry into the neighbouring day.
      final DateTime day = DateTime(now.year, now.month, now.day - daysAgo);
      final bool weekend =
          day.weekday == DateTime.saturday || day.weekday == DateTime.sunday;
      final DateTime date = DateTime(
        day.year,
        day.month,
        day.day,
        weekend ? 8 : 6,
        (weekend ? 10 : 35) + rng.nextInt(weekend ? 70 : 45),
      );

      double weight =
          _trendAt(demoHistoryDays - daysAgo) +
          _weekdayOffset[day.weekday]! * scale +
          water +
          _readingError * scale * _gauss(rng);

      final int sinceReturn = _holidayToDaysAgo - 1 - daysAgo;
      if (sinceReturn >= 0) {
        weight += _holidayGain * scale * exp(-sinceReturn / _holidayDecay);
      }

      result.add(
        Measurement(
          weight: double.parse(weight.toStringAsFixed(1)),
          date: date,
        ),
      );
    }

    return result;
  }

  /// Date on which the target weight was "set".
  ///
  /// [TraleNotifier.userTargetWeightSetDate] returns `null` unless the stored
  /// date falls on a day that actually has a measurement, and the chart only
  /// draws its three-segment target ramp when it resolves — so snap to the
  /// measurement nearest to [targetSetDaysAgo] days ago.
  DateTime targetSetDate(List<Measurement> measurements) {
    final DateTime now = DateTime.now();
    final DateTime wanted = DateTime(
      now.year,
      now.month,
      now.day - targetSetDaysAgo,
    );

    Measurement nearest = measurements.first;
    for (final Measurement m in measurements) {
      final int delta = m.date.difference(wanted).inHours.abs();
      if (delta < nearest.date.difference(wanted).inHours.abs()) {
        nearest = m;
      }
    }
    return nearest.date;
  }

  /// Date at which the target weight should be reached.
  DateTime targetDate() {
    final DateTime now = DateTime.now();
    return DateTime(now.year, now.month, now.day + targetDaysAhead);
  }
}

/// The demo cast, one persona per theme: two men and two women, of whom two
/// are losing weight, one is holding it and one is building up.
const List<DemoPersona> demoPersonas = <DemoPersona>[
  // Losing: BMI 28.8 at the start, 25.5 today, 24.6 once the target is
  // reached.  A fast first fortnight that is mostly water, a steady stretch,
  // a plateau across the holiday, then renewed progress at ~0.34 kg/week over
  // the remaining 2.8 kg.
  DemoPersona(
    name: 'Liam',
    height: 178,
    seed: 29,
    anchors: <({int day, double weight})>[
      (day: 0, weight: 91.2),
      (day: 17, weight: 89.2),
      (day: 70, weight: 85.6),
      (day: 100, weight: 85.0),
      (day: 186, weight: 80.8),
    ],
    targetWeight: 78,
    targetSetDaysAgo: 120,
    targetDaysAhead: 60,
  ),
  // Losing: BMI 29.9 at the start, 26.8 today, 25.8 at the target — the same
  // story at a smaller scale, closing at ~0.28 kg/week over the remaining
  // 2.9 kg.
  DemoPersona(
    name: 'Emma',
    height: 166,
    seed: 9,
    anchors: <({int day, double weight})>[
      (day: 0, weight: 82.4),
      (day: 17, weight: 80.9),
      (day: 70, weight: 77.8),
      (day: 100, weight: 77.3),
      (day: 186, weight: 73.9),
    ],
    targetWeight: 71,
    targetSetDaysAgo: 110,
    targetDaysAhead: 75,
  ),
  // Keeping: BMI steady around 21.7, wobbling within less than a kilo of the
  // target the whole six months — maintenance, not a diet.
  DemoPersona(
    name: 'Mia',
    height: 171,
    seed: 7,
    anchors: <({int day, double weight})>[
      (day: 0, weight: 63.9),
      (day: 45, weight: 63.2),
      (day: 95, weight: 63.7),
      (day: 140, weight: 63.1),
      (day: 186, weight: 63.4),
    ],
    targetWeight: 63,
    targetSetDaysAgo: 150,
    targetDaysAhead: 45,
  ),
  // Gaining: BMI 18.5 at the start, 19.7 today, 20.3 at the target — a lean
  // bulk at ~0.15 kg/week with 1.9 kg left to go.
  DemoPersona(
    name: 'Noah',
    height: 183,
    seed: 11,
    anchors: <({int day, double weight})>[
      (day: 0, weight: 61.8),
      (day: 20, weight: 62.4),
      (day: 70, weight: 63.8),
      (day: 100, weight: 64.1),
      (day: 186, weight: 66.1),
    ],
    targetWeight: 68,
    targetSetDaysAgo: 130,
    targetDaysAhead: 90,
  ),
];

/// SharedPreferences values applied before the app boots.
///
/// Only keys that need to differ from the shipped defaults are listed —
/// `Preferences.loadDefaultSettings()` fills in everything else on first read.
/// Suppresses every first-launch interruption that would otherwise land in a
/// screenshot and pins the locale so labels are reproducible.  [persona] only
/// seeds the initial profile; the tour re-applies each theme's persona through
/// [TraleNotifier] as it goes.
Map<String, Object> demoPrefs({
  required DemoPersona persona,
  required String themeName,
  required String nightMode,
}) {
  return <String, Object>{
    // First-launch changelog sheet.  Both keys are needed: QPApp re-arms
    // showChangelog whenever the APK build number exceeds the stored one.
    'qp_showChangelog': false,
    'qp_lastBuildNumber': 999999,
    // Hint banners that slide in on a 3 s timer.
    'showStatsHintBanner': false,
    'showMeasurementHintBanner': false,
    // Backup reminder snackbar — fires for any dataset larger than 5 entries.
    'backupInterval': 'never',
    // Deterministic locale, units and palette.
    'qp_language': 'en',
    'unit': 'kg',
    // The chart defaults to showing the whole history at once, which for this
    // dataset is all six months.  Two months gives the home screenshot enough
    // room to show individual measurements instead of a dense band.
    'zoomLevel': ZoomLevel.two.index,
    'qp_theme': themeName,
    'qp_nightMode': nightMode,
    // User profile: height drives the BMI card, name the user dialog.
    'userHeight': persona.height,
    'userName': persona.name,
    // A configured reminder so the reminder page is not in its empty state.
    'qp_reminderEnabled': true,
    'qp_reminderDays': '1,3,5',
    'qp_reminderHour': 8,
    'qp_reminderMinute': 0,
  };
}
