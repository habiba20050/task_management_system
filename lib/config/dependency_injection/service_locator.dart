import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import '../../core/network/dio_factory.dart';
import '../../core/storage/local_storage.dart';

final getIt = GetIt.instance;

class ServiceLocator {
  ServiceLocator._();

  static Future<void> init() async {
    // Core
    await LocalStorage.init();
    
    // Network
    getIt.registerLazySingleton<Dio>(() => DioFactory.createDio());
    
    // Features
    // Register your feature dependencies here
    // Example:
    // getIt.registerFactory<TaskCubit>(() => TaskCubit(getIt<TaskRepository>()));
    // getIt.registerLazySingleton<TaskRepository>(() => TaskRepositoryImpl(getIt<TaskRemoteDataSource>()));
    // getIt.registerLazySingleton<TaskRemoteDataSource>(() => TaskRemoteDataSourceImpl(getIt<Dio>()));
  }
}
