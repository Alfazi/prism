import 'package:get_it/get_it.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import '../../features/auth/data/services/auth_api_service.dart';
import '../../features/auth/data/services/auth_local_service.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

final getIt = GetIt.instance;

Future<void> setupDependencyInjection() async {
  // External dependencies
  const secureStorage = FlutterSecureStorage();
  getIt.registerSingleton<FlutterSecureStorage>(secureStorage);

  final dio = Dio();
  getIt.registerSingleton<Dio>(dio);

  // Services
  getIt.registerLazySingleton<AuthLocalService>(
    () => AuthLocalService(getIt<FlutterSecureStorage>()),
  );

  getIt.registerLazySingleton<AuthApiService>(
    () => AuthApiService(dio: getIt<Dio>()),
  );

  // BLoCs
  getIt.registerFactory<AuthBloc>(
    () => AuthBloc(
      apiService: getIt<AuthApiService>(),
      localService: getIt<AuthLocalService>(),
    ),
  );
}
