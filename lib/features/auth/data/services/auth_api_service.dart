import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/login_model.dart';
import '../models/register_model.dart';

class AuthApiService {
  final Dio _dio;

  AuthApiService({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: ApiConstants.baseUrl,
              connectTimeout: const Duration(seconds: 30),
              receiveTimeout: const Duration(seconds: 30),
            ),
          );

  Future<LoginResponse> login(LoginRequest request) async {
    try {
      final response = await _dio.post(
        ApiConstants.login,
        data: request.toJson(),
        options: Options(headers: ApiConstants.getHeaders()),
      );

      return LoginResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Login failed');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }

  Future<RegisterResponse> register(RegisterRequest request) async {
    try {
      final response = await _dio.post(
        ApiConstants.register,
        data: request.toJson(),
        options: Options(headers: ApiConstants.getHeaders()),
      );

      return RegisterResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Registration failed');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }

  Future<void> logout(String token) async {
    try {
      await _dio.get(
        ApiConstants.logout,
        options: Options(headers: ApiConstants.getHeaders(token: token)),
      );
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Logout failed');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }
}
