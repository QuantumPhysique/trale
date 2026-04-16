part of '../stats_widgets.dart';

/// Full-width change-rates card (week / month / year columns).
BentoCard changeRatesCard({
  required BuildContext context,
  required MeasurementStats stats,
  int delayInMilliseconds = 0,
}) {
  final String unit = Provider.of<TraleNotifier>(
    context,
    listen: false,
  ).unit.name;
  final AppLocalizations l10n = context.l10n;
  return BentoCard(
    columnSpan: 12,
    rowSpan: 2,
    delayInMilliseconds: delayInMilliseconds,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Expanded(
          flex: 2,
          child: Align(
            alignment: Alignment.center,
            child: AutoSizeText(
              '${l10n.change} ($unit)',
              style: Theme.of(context).textTheme.emphasized.bodyLarge!
                  .onSurface(context)
                  .copyWith(fontWeight: FontWeight.w900),
              maxLines: 2,
              textAlign: TextAlign.center,
            ),
          ),
        ),
        Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: AutoSizeText(
              '/ ${l10n.week}\n${weightToString(context, stats.deltaWeightLastWeek)}',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium!.onSurface(context).copyWith(height: 1.0),
              maxLines: 2,
              textAlign: TextAlign.center,
            ),
          ),
        ),
        Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: AutoSizeText(
              '/ ${l10n.month}\n${weightToString(context, stats.deltaWeightLastMonth)}',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium!.onSurface(context).copyWith(height: 1.0),
              maxLines: 2,
              textAlign: TextAlign.center,
            ),
          ),
        ),
        Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: AutoSizeText(
              '/ ${l10n.year}\n${weightToString(context, stats.deltaWeightLastYear)}',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium!.onSurface(context).copyWith(height: 1.0),
              maxLines: 2,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    ),
  );
}

/// Full-width weight forecast card (today / +1 week / +1 month).
BentoCard weightForecastCard({
  required BuildContext context,
  required MeasurementStats stats,
  int delayInMilliseconds = 0,
}) {
  final String unit = Provider.of<TraleNotifier>(
    context,
    listen: false,
  ).unit.name;
  final AppLocalizations l10n = context.l10n;
  return BentoCard(
    columnSpan: 12,
    rowSpan: 2,
    delayInMilliseconds: delayInMilliseconds,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Expanded(
          flex: 2,
          child: Align(
            alignment: Alignment.center,
            child: AutoSizeText(
              '${l10n.weightForecast} ($unit)',
              style: Theme.of(context).textTheme.emphasized.bodyLarge!
                  .onSurface(context)
                  .copyWith(fontWeight: FontWeight.w900),
              maxLines: 2,
              textAlign: TextAlign.center,
            ),
          ),
        ),
        Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: AutoSizeText(
              '/ ${l10n.today}\n${weightToString(context, stats.weightToday)}',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium!.onSurface(context).copyWith(height: 1.0),
              maxLines: 2,
              textAlign: TextAlign.center,
            ),
          ),
        ),
        Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: AutoSizeText(
              '/ ${l10n.week}\n${weightToString(context, stats.weightInOneWeek)}',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium!.onSurface(context).copyWith(height: 1.0),
              maxLines: 2,
              textAlign: TextAlign.center,
            ),
          ),
        ),
        Expanded(
          child: Align(
            alignment: Alignment.centerLeft,
            child: AutoSizeText(
              '/ ${l10n.month}\n${weightToString(context, stats.weightInOneMonth)}',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium!.onSurface(context).copyWith(height: 1.0),
              maxLines: 2,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    ),
  );
}

