import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart' as el;

extension TranslateExtension on String {
  String tr(BuildContext context) {
    context.locale;
    return el.tr(this, context: context);
  }
}
