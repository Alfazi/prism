import 'package:get_it/get_it.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../../features/auth/data/services/auth_api_service.dart';
import '../../features/auth/data/services/auth_local_service.dart';
import '../../features/auth/data/services/upload_service.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/feed/data/services/feed_api_service.dart';
import '../../features/feed/presentation/bloc/feed_bloc.dart';
import '../../features/feed/presentation/bloc/explore_bloc.dart';

final getIt = GetIt.instance;

Future<void> setupDependencyInjection() async {
  // External dependencies
  const secureStorage = FlutterSecureStorage();
  getIt.registerSingleton<FlutterSecureStorage>(secureStorage);

  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );
  getIt.registerSingleton<Dio>(dio);

  // Services
  getIt.registerLazySingleton<AuthLocalService>(
    () => AuthLocalService(getIt<FlutterSecureStorage>()),
  );

  getIt.registerLazySingleton<AuthApiService>(
    () => AuthApiService(dio: getIt<Dio>()),
  );

  getIt.registerLazySingleton<FeedApiService>(
    () => FeedApiService(dio: getIt<Dio>()),
  );

  getIt.registerLazySingleton<UploadService>(
    () => UploadService(dio: getIt<Dio>()),
  );

  // BLoCs
  getIt.registerFactory<AuthBloc>(
    () => AuthBloc(
      apiService: getIt<AuthApiService>(),
      localService: getIt<AuthLocalService>(),
    ),
  );

  getIt.registerFactory<FeedBloc>(
    () => FeedBloc(
      feedApiService: getIt<FeedApiService>(),
      authLocalService: getIt<AuthLocalService>(),
    ),
  );

  getIt.registerFactory<ExploreBloc>(
    () => ExploreBloc(
      feedApiService: getIt<FeedApiService>(),
      authLocalService: getIt<AuthLocalService>(),
    ),
  );
}
