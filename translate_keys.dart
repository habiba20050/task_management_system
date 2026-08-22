import 'dart:io';
import 'dart:convert';

void main() async {
  File arFile = File('assets/lang/ar.json');
  Map<String, dynamic> arJson = jsonDecode(await arFile.readAsString());

  final translations = {
    "Password updated successfully!": "تم تحديث كلمة المرور بنجاح!",
    "Personal information updated successfully!": "تم تحديث المعلومات الشخصية بنجاح!",
    "Retry": "إعادة المحاولة",
    "Update your personal profile, email, and security settings": "تحديث ملفك الشخصي وبريدك الإلكتروني وإعدادات الأمان",
    "Active account": "حساب نشط",
    "Personal Information": "المعلومات الشخصية",
    "Security Settings": "إعدادات الأمان",
    "Password must be at least 8 characters, include at least one uppercase letter, one number, and one special character (@, #, !, etc.).": "يجب أن تتكون كلمة المرور من 8 أحرف على الأقل، وتحتوي على حرف كبير واحد على الأقل، ورقم واحد، وحرف خاص واحد (@، #، !، إلخ).",
    "Please fill all password fields.": "يرجى تعبئة جميع حقول كلمة المرور.",
    "Passwords do not match.": "كلمات المرور غير متطابقة.",
    "Update Password": "تحديث كلمة المرور"
  };

  translations.forEach((key, value) {
    if (arJson.containsKey(key)) {
      arJson[key] = value;
    }
  });

  await arFile.writeAsString(jsonEncode(arJson));
  print('Updated ar.json with Arabic translations.');
}
