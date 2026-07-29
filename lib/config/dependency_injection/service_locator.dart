import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import '../../core/network/dio_factory.dart';
import '../../core/storage/local_storage.dart';
import '../../user/shared/features/auth/repository/auth_repository.dart';
import '../../user/shared/features/auth/repository/auth_repository_impl.dart';
import '../../user/shared/features/auth/service/auth_api.dart';
import '../../user/shared/features/profile/cubit/profile_cubit.dart';
import '../../user/shared/features/profile/repository/profile_repository.dart';
import '../../user/shared/features/profile/repository/profile_repository_impl.dart';
import '../../user/shared/features/profile/service/profile_api.dart';
import '../../user/shared/features/teams/cubit/teams_cubit.dart';
import '../../user/shared/features/teams/repository/teams_repository.dart';
import '../../user/shared/features/users/cubit/users_cubit.dart';
import '../../user/shared/features/language/cubit/language_cubit.dart';

import '../../user/shared/features/auth/cubit/auth_cubit.dart';
import '../../core/network/mock_database.dart';

final getIt = GetIt.instance;

class ServiceLocator {
  ServiceLocator._();

  static Future<void> init() async {
    if (getIt.isRegistered<AuthCubit>()) {
      return;
    }

    // Core
    await LocalStorage.init();
    await MockDatabase.instance.init();

    // Network
    if (!getIt.isRegistered<Dio>()) {
      getIt.registerLazySingleton<Dio>(() => DioFactory.createDio());
    }

    // Storage
    if (!getIt.isRegistered<FlutterSecureStorage>()) {
      getIt.registerLazySingleton<FlutterSecureStorage>(
        () => const FlutterSecureStorage(),
      );
    }

    // Auth
    if (!getIt.isRegistered<AuthApi>()) {
      getIt.registerLazySingleton<AuthApi>(
        () => AuthApi(getIt<Dio>()),
      );
    }
    if (!getIt.isRegistered<AuthRepository>()) {
      getIt.registerLazySingleton<AuthRepository>(
        () => AuthRepositoryImpl(
          getIt<AuthApi>(),
          getIt<FlutterSecureStorage>(),
        ),
      );
    }
    if (!getIt.isRegistered<AuthCubit>()) {
      getIt.registerSingleton<AuthCubit>(
        AuthCubit(getIt<AuthRepository>()),
      );
    }

    // Profile
    if (!getIt.isRegistered<ProfileApi>()) {
      getIt.registerLazySingleton<ProfileApi>(
        () => ProfileApi(getIt<Dio>()),
      );
    }
    if (!getIt.isRegistered<ProfileRepository>()) {
      getIt.registerLazySingleton<ProfileRepository>(
        () => ProfileRepositoryImpl(),
      );
    }
    if (!getIt.isRegistered<ProfileCubit>()) {
      getIt.registerFactory<ProfileCubit>(
        () => ProfileCubit(getIt<ProfileRepository>()),
      );
    }

    // Teams
    if (!getIt.isRegistered<TeamsRepository>()) {
      getIt.registerLazySingleton<TeamsRepository>(
        () => TeamsRepository(),
      );
    }
    if (!getIt.isRegistered<TeamsCubit>()) {
      getIt.registerFactory<TeamsCubit>(
        () => TeamsCubit(getIt<TeamsRepository>()),
      );
    }

    // Users
    if (!getIt.isRegistered<UsersCubit>()) {
      getIt.registerFactory<UsersCubit>(
        () => UsersCubit(),
      );
    }

    // Language
    if (!getIt.isRegistered<LanguageCubit>()) {
      getIt.registerSingleton<LanguageCubit>(
        LanguageCubit(),
      );
    }
  }
}
