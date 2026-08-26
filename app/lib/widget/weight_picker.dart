import 'dart:math';

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:quantumphysique/quantumphysique.dart';
import 'package:trale/core/constants.dart';
import 'package:trale/core/l10n_extension.dart';
import 'package:trale/core/text_size.dart';
import 'package:trale/core/trale_notifier.dart';
import 'package:trale/core/unit_precision.dart';
import 'package:trale/core/units.dart';

part 'weight_picker_parts/ruler_picker.dart';

/// Custom scroll physics that snaps to multiples of [snapSize].

part 'weight_picker_parts/scroll_physics.dart';
part 'weight_picker_parts/weight_slider.dart';
part 'weight_picker_parts/weight_value_field.dart';
