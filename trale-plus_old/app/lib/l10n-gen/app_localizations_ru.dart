// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get achievements => 'Достижения';

  @override
  String get experimentalFeatures => 'Экспериментальные возможности';

  @override
  String get looseWeight => 'Показывать потерю веса';

  @override
  String get gainWeight => 'Показывать набор веса';

  @override
  String get tapDateAboveToAddEntry => 'Tap a date above to add an entry.';

  @override
  String get looseWeightSubtitle =>
      'Переключиться между показом потери или набора веса';

  @override
  String get days => 'Дни';

  @override
  String get weeks => 'Недели';

  @override
  String get week => 'Неделя';

  @override
  String get months => 'Месяцы';

  @override
  String get month => 'Месяц';

  @override
  String get years => 'Года';

  @override
  String get year => 'Год';

  @override
  String get never => 'Никогда';

  @override
  String get weekly => 'Еженедельно';

  @override
  String get biweekly => 'Раз в две недели';

  @override
  String get monthly => 'Ежемесячно';

  @override
  String get quarterly => 'Ежеквартально';

  @override
  String get backupReminder => 'Пожалуйста, делайте резервные копии часто';

  @override
  String get backupReminderButton => 'Сделать резервную копию сейчас';

  @override
  String get backupSuccess => 'Резервная копия успешно экспортирована';

  @override
  String get backupInterval => 'Частота создания резервных копий';

  @override
  String get lastBackup => 'Последняя резервная копия';

  @override
  String get nextBackup => 'Время следующей резервной копии';

  @override
  String get stats => 'Статистика';

  @override
  String get trale => 'Трал';

  @override
  String get unit => 'Единицы';

  @override
  String get date => 'Дата';

  @override
  String get weight => 'Вес';

  @override
  String get user => 'Профиль пользователя';

  @override
  String get userSettings => 'Настройки пользователя';

  @override
  String get dangerzone => 'Опасная зона';

  @override
  String get settings => 'Настройки';

  @override
  String get faq => 'ЧаВО';

  @override
  String get about => 'О программе';

  @override
  String get defaultLang => 'Системный';

  @override
  String get language => 'Язык';

  @override
  String get theme => 'Тема';

  @override
  String get darkmode => 'Тёмная';

  @override
  String get lightmode => 'Светлая';

  @override
  String get systemmode => 'Системная';

  @override
  String get export => 'Экспортировать все измерения';

  @override
  String get exportSubtitle => 'This exposes all measurements to all apps.';

  @override
  String get exportDialog =>
      'Эта функция экспортирует все измерения во внешнюю память (за приложением). Необходимы права на доступ к памяти.';

  @override
  String get open => 'Открыть файл';

  @override
  String get abort => 'Отмена';

  @override
  String get import => 'Импортировать резервную копию';

  @override
  String get importSubtitle => 'Импортировать измерения из .txt .';

  @override
  String get amoled => 'Абсолютно чёрный';

  @override
  String get amoledSubtitle => 'Изменить цвет фона на глубокий чёрный.';

  @override
  String get reset => 'Заводской сброс приложения';

  @override
  String get factoryReset => 'Заводской сброс приложения.';

  @override
  String get factoryResetSubtitle => 'Сбросить все настройки и измерения.';

  @override
  String get factoryResetDialog =>
      'Сбросить все настройки до заводских? Это сбросит все измерения в том числе. Эта операция неизбежна.';

  @override
  String get delete => 'Удалить';

  @override
  String get importingAbort => 'Импорт данных отменён.';

  @override
  String get importDialog =>
      'Включить все измерения в текущую базу данных. Эта операция не отменяема!';

  @override
  String get home => 'Домашний экран';

  @override
  String get yes => 'Да';

  @override
  String get ok => 'ОК';

  @override
  String get save => 'Сохранить';

  @override
  String get edit => 'Редактировать';

  @override
  String get backup => 'Резервная копия';

  @override
  String get time => 'Время';

  @override
  String get assets => 'Ресурсы';

  @override
  String get packages => 'Пакеты';

  @override
  String get loading => 'Загрузка';

  @override
  String get measurements => 'Измерения';

  @override
  String get version => 'Версия';

  @override
  String get tpl => 'Лицензии 3 сторон';

  @override
  String get licence => 'Лицензия';

  @override
  String get sourcecode => 'Исходный код';

  @override
  String get openIssue => 'Открыть запрос на GitHub';

  @override
  String undertpl(String years, String author, String licence) {
    return '© $years сделано $author под лицензией $licence';
  }

  @override
  String get addWeight => 'Введите свой вес';

  @override
  String get addHeight => 'Enter your height';

  @override
  String get interpolation => 'Интерполяция';

  @override
  String get strength => 'Сила интерполяции';

  @override
  String get none => 'Нету';

  @override
  String get soft => 'Мягкая';

  @override
  String get medium => 'Средняя';

  @override
  String get strong => 'Сильная';

  @override
  String get welcome => 'Добро пожаловать';

  @override
  String get onBoarding1 =>
      'Это просто приложение в стиле Material You поможет вам достичь веса, о котором вы мечтали! Если Вы бы хотели сбросить вес, набрать его, или же просто держать планку, это приложение для вас! Достоверное предсказание веса и точная статистика поможет вам держать строй.\n\nПрисоединяйтесь к нашему сообществу и совершенствуйте себя.\n🐺🤸‍♀️🏋‍♀️🧘‍♂️🏆🥇';

  @override
  String get onBoarding2 =>
      'Выберите одну из шести тем для персонализации приложения. Какая бы вам подошла?';

  @override
  String get onBoarding3 =>
      'Спасибо за то, что попробовали наше приложение. 🙂\n\nЕсли вам оно понравилось, мы были бы очень рады вашему отзыву или же помощи проекту на Github. Взамен мы предостерегаем вас от назойливых реклам.';

  @override
  String get onBoarding2Title => 'Стиль';

  @override
  String get onBoarding3Title => 'Приватность';

  @override
  String get skip => 'Пропустить';

  @override
  String get startApp => 'Начать';

  @override
  String get targetWeight => 'Целевой вес';

  @override
  String get targetWeightMotivation =>
      'Ставить цель для веса - очень важный этап для правильного пути. Если у вас есть цель, у вас есть больше мотивации для ее достижения.';

  @override
  String get targetWeightShort => 'Цель';

  @override
  String get addUserName => 'Как мы должны Вас называть?';

  @override
  String get addTargetWeight => 'Добавить целевой вес';

  @override
  String get intro1 => 'Нажмите';

  @override
  String get intro2 => 'чтобы начать';

  @override
  String get intro3 =>
      'Сегодня очень хороший день чтобы начать ваше первое измерение веса!';

  @override
  String get faqtext =>
      'Здесь вы найдете ответы на самые часто задаваемые вопросы. Если у вас есть другие вопросы, не стесняйтесь спрашивать их на нашем Github.';

  @override
  String get faq_q1 =>
      'Этой возможности пока что нет. Когда её наконец уже доделают?';

  @override
  String get faq_a1 =>
      'Это приложение создаётся в наше свободное время и мы пытаемся сохранять приложение стильным и простым. Мы верим, что добавлять больше функций ≠ больше удобства. Если Вам кажется, что мы что-то упустили, можете написать нам в Github.';

  @override
  String get faq_q2 => 'Могу ли я ещё раз увидеть вступительный экран?';

  @override
  String get faq_a2 => 'Конечно же! Просто нажмите иконку ниже.';

  @override
  String get faq_a2_widget => 'Вернуться на главный экран';

  @override
  String get faq_q3 => 'Что показывает иконка приложения?';

  @override
  String get faq_a3 =>
      'На иконке изображён воющий волк, его хвост частично перекрывает букву \'t\' и \'r\'.';

  @override
  String get faq_q4 =>
      'Can I enter a target weight below 50kg / 110 lb / 7.9 st?';

  @override
  String get faq_a4 =>
      'Yes, by providing your height.\n\nAnorexia is a serious disease that is increasingly becoming a problem for society as a whole, partly due to the many negative examples on social media. To support prevention efforts, we do not allow target weights below 50 kg / 110 lb / 7.9 st. Entering your height allows us to calculate a minimum target weight corresponding to a BMI of 18.5.';

  @override
  String get target_weight_warning =>
      'Анорексия - очень серьезное заболевание, которое из-за негативного влияния социальных сетей (и общества в целом) становится все более распространенной проблемой. И как наш вклад в уменьшение её влияния, в приложении невозможно будет установить вес меньше 50 кг.';

  @override
  String get max => 'Макс';

  @override
  String get min => 'Мин';

  @override
  String get change => 'Разница';

  @override
  String get totalChange => 'Целевая разница';

  @override
  String get schemeVariant => 'scheme variant';

  @override
  String get mean => 'Среднее значение';

  @override
  String get measurementFrequency => 'Частота измерения';

  @override
  String get targetWeightReached =>
      'Поздравляем, вы достигли своего целевого веса!';

  @override
  String get targetWeightReachedIn => 'осталось до достижения цели';

  @override
  String get maxStreak => 'длиннейшая серия';

  @override
  String get currentStreak => 'current streak';

  @override
  String get timeSinceFirstMeasurement => 'время с первого измерения';

  @override
  String get firstDay => 'Первый день';

  @override
  String get highContrast => 'High contrast';

  @override
  String get bmi => 'BMI';
}
