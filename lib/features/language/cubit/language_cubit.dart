import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/storage/local_storage.dart';

class LanguageCubit extends Cubit<String> {
  LanguageCubit() : super('EN') {
    _loadLanguage();
  }

  void _loadLanguage() {
    final savedLang = LocalStorage.getString('app_language');
    if (savedLang != null && (savedLang == 'EN' || savedLang == 'AR')) {
      emit(savedLang);
    }
  }

  void changeLanguage(String langCode) {
    emit(langCode);
    LocalStorage.setString('app_language', langCode);
  }
}
