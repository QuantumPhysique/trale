import 'dart:async';
import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_auto_size_text/flutter_auto_size_text.dart';
import 'package:intl/intl.dart';
import 'package:ml_linalg/linalg.dart' as ml;
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:quantumphysique/quantumphysique.dart';
import 'package:trale/core/l10n_extension.dart';
import 'package:trale/core/measurement_interpolation.dart';
import 'package:trale/core/preferences.dart';
import 'package:trale/core/text_size.dart';
import 'package:trale/core/theme.dart';
import 'package:trale/core/trale_notifier.dart';
import 'package:trale/core/units.dart';
import 'package:trale/core/zoom_level.dart';

part 'linechart_parts/target_weight_segments.dart';
part 'linechart_parts/custom_line_chart.dart';
