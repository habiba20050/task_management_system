import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/theme/app_theme.dart';
import 'config/dependency_injection/service_locator.dart';
import 'config/routes/app_router.dart';
import 'user/shared/features/auth/cubit/auth_cubit.dart';
import 'user/shared/features/language/cubit/language_cubit.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ServiceLocator.init();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    getIt<AuthCubit>().checkAuthStatus();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        final isTablet = constraints.maxWidth >= 600 && constraints.maxWidth < 1024;
        
        Size designSize;
        if (isMobile) {
          designSize = const Size(375, 812);
        } else if (isTablet) {
          designSize = const Size(768, 1024);
        } else {
          designSize = const Size(1440, 900);
        }

        return ScreenUtilInit(
          designSize: designSize,
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (context, child) {
            return MultiBlocProvider(
              providers: [
                BlocProvider.value(value: getIt<AuthCubit>()),
                BlocProvider.value(value: getIt<LanguageCubit>()),
              ],
              child: BlocBuilder<LanguageCubit, String>(
                builder: (context, lang) {
                  return MaterialApp.router(
                    title: 'AITU Task Management',
                    debugShowCheckedModeBanner: false,
                    locale: Locale(lang.toLowerCase()),
                    supportedLocales: const [
                      Locale('en'),
                      Locale('ar'),
                    ],
                    localizationsDelegates: const [
                      AppLocalizations.delegate,
                      GlobalMaterialLocalizations.delegate,
                      GlobalWidgetsLocalizations.delegate,
                      GlobalCupertinoLocalizations.delegate,
                    ],
                    theme: AppTheme.getTheme(langCode: lang, isDark: false),
                    darkTheme: AppTheme.getTheme(langCode: lang, isDark: true),
                    themeMode: ThemeMode.light,
                    routerConfig: AppRouter.router,
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
