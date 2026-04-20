part of '../stats_widgets.dart';

/// Transparent card: app icon hero, placed on a given M3 shape.
QPBentoCard iconHeroCard({
  required BuildContext context,
  required Shapes shape,
  VoidCallback? onTap,
  int delayInMilliseconds = 0,
}) {
  return QPBentoCard.shaped(
    span: 4,
    backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
    delayInMilliseconds: delayInMilliseconds,
    m3eShape: shape,
    rotateDuration: const Duration(seconds: 60),
    onTap: onTap,
    child: LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) => Padding(
        padding: EdgeInsets.only(bottom: constraints.maxHeight * 0.1),
        child: const IconHeroStatScreen(),
      ),
    ),
  );
}

/// Returns the BMI range string and category label for a given [bmi] value.
({String range, String category}) _bmiCategory(
  double bmi,
  AppLocalizations l10n,
) {
  if (bmi < 17) {
    return (range: '< 17', category: l10n.bmiSevereUnderweight);
  } else if (bmi < 18.5) {
    return (range: '17 – 18.5', category: l10n.bmiUnderweight);
  } else if (bmi < 25) {
    return (range: '18.5 – 25', category: l10n.bmiNormal);
  } else if (bmi < 30) {
    return (range: '25 – 30', category: l10n.bmiOverweight);
  } else {
    return (range: '> 30', category: l10n.bmiObese);
  }
}

/// Card: current BMI with value, range, and category.
QPBentoCard bmiCard({
  required BuildContext context,
  required MeasurementStats stats,
  int delayInMilliseconds = 0,
}) {
  final AppLocalizations l10n = context.l10n;
  final double? bmi = stats.currentBMI(context);
  final String bmiStr = doubleToString(bmi);
  final ({String range, String category}) info = bmi != null
      ? _bmiCategory(bmi, l10n)
      : (range: '--', category: '--');
  return QPBentoCard(
    columnSpan: 12,
    rowSpan: 3,
    delayInMilliseconds: delayInMilliseconds,
    child: Padding(
      padding: EdgeInsets.symmetric(
        horizontal: TraleTheme.of(context)!.padding,
        vertical: TraleTheme.of(context)!.padding / 2,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: Align(
              alignment: Alignment.center,
              child: AutoSizeText(
                l10n.bmi,
                style: Theme.of(context).textTheme.emphasized.bodyLarge!
                    .onSurface(context)
                    .copyWith(fontWeight: FontWeight.w900),
                maxLines: 1,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.center,
              child: AutoSizeText(
                bmiStr,
                style: Theme.of(context).textTheme.emphasized.bodyMedium!
                    .onSurface(context)
                    .copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 200,
                      height: 0.7,
                    ),
                maxLines: 1,
              ),
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.center,
              child: AutoSizeText(
                '${info.range}\n${info.category}',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall!.onSurface(context),
                maxLines: 3,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

/// Text card: estimated daily calorie deficit.
QPBentoCard calorieDeficitCard({
  required BuildContext context,
  required MeasurementStats stats,
  int delayInMilliseconds = 0,
}) => QPBentoCard.textInline(
  columnSpan: 8,
  rowSpan: 2,
  label: '${context.l10n.calorieDeficit}\n(kcal/day)',
  value: '${stats.dailyDeficit}',
  delayInMilliseconds: delayInMilliseconds,
);

/// Text card: difference from target weight.
QPBentoCard diffFromTargetCard({
  required BuildContext context,
  required MeasurementStats stats,
  int delayInMilliseconds = 0,
}) {
  final String unit = Provider.of<TraleNotifier>(
    context,
    listen: false,
  ).unit.name;
  return QPBentoCard.textEmphasized(
    columnSpan: 4,
    rowSpan: 5,
    label: '${context.l10n.diffFromTarget} ($unit)',
    value: weightToString(context, stats.currentDifference),
    textColor: Theme.of(context).colorScheme.onTertiaryContainer,
    backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
    delayInMilliseconds: delayInMilliseconds,
  );
}
