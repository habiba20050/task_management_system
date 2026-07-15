import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/theme/app_theme.dart';
import 'config/dependency_injection/service_locator.dart';
import 'config/routes/app_router.dart';
import 'features/auth/cubit/auth_cubit.dart';
import 'features/language/cubit/language_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ServiceLocator.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
                BlocProvider.value(value: getIt<AuthCubit>()..checkAuthStatus()),
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
                      GlobalMaterialLocalizations.delegate,
                      GlobalWidgetsLocalizations.delegate,
                      GlobalCupertinoLocalizations.delegate,
                    ],
                    theme: AppTheme.lightTheme,
                    darkTheme: AppTheme.darkTheme,
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
