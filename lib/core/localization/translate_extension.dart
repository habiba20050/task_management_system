import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/language/cubit/language_cubit.dart';
import 'app_translation.dart';

extension TranslateExtension on String {
  String tr(BuildContext context) {
    try {
      final lang = context.watch<LanguageCubit>().state;
      return AppTranslation.translate(this, lang);
    } catch (_) {
      return this;
    }
  }
}
