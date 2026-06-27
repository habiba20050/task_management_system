import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import '../../core/network/dio_factory.dart';
import '../../core/storage/local_storage.dart';
import '../../features/auth/repository/auth_repository.dart';
import '../../features/auth/repository/auth_repository_impl.dart';
import '../../features/auth/service/auth_api.dart';
import '../../features/profile/cubit/profile_cubit.dart';
import '../../features/profile/repository/profile_repository.dart';
import '../../features/profile/repository/profile_repository_impl.dart';
import '../../features/profile/service/profile_api.dart';
import '../../features/teams/cubit/teams_cubit.dart';
import '../../features/teams/repository/teams_repository.dart';
import '../../features/users/cubit/users_cubit.dart';

final getIt = GetIt.instance;

class ServiceLocator {
  ServiceLocator._();

  static Future<void> init() async {
    // Core
    await LocalStorage.init();

    // Network
    getIt.registerLazySingleton<Dio>(() => DioFactory.createDio());

    // Storage
    getIt.registerLazySingleton<FlutterSecureStorage>(
      () => const FlutterSecureStorage(),
    );

    // Auth
    getIt.registerLazySingleton<AuthApi>(
      () => AuthApi(getIt<Dio>()),
    );
    getIt.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(
        getIt<AuthApi>(),
        getIt<FlutterSecureStorage>(),
      ),
    );

    // Profile
    getIt.registerLazySingleton<ProfileApi>(
      () => ProfileApi(getIt<Dio>()),
    );
    getIt.registerLazySingleton<ProfileRepository>(
      () => ProfileRepositoryImpl(
        getIt<ProfileApi>(),
        getIt<FlutterSecureStorage>(),
      ),
    );
    getIt.registerFactory<ProfileCubit>(
      () => ProfileCubit(getIt<ProfileRepository>()),
    );

    // Teams
    getIt.registerLazySingleton<TeamsRepository>(
      () => TeamsRepository(),
    );
    getIt.registerFactory<TeamsCubit>(
      () => TeamsCubit(getIt<TeamsRepository>()),
    );

    // Users
    getIt.registerFactory<UsersCubit>(
      () => UsersCubit(),
    );
  }
}
