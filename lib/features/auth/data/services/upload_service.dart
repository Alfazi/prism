import 'dart:io';
import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';

class UploadService {
  final Dio _dio;

  UploadService({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: ApiConstants.baseUrl,
              connectTimeout: const Duration(seconds: 30),
              receiveTimeout: const Duration(seconds: 30),
            ),
          );

  Future<String> uploadImage(File imageFile) async {
    try {
      // Create multipart form data
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
      });

      final response = await _dio.post(
        ApiConstants.uploadImage,
        data: formData,
        options: Options(headers: ApiConstants.getMultipartHeaders()),
      );

      // Extract URL from response
      final url = response.data['url'] as String;
      return url;
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Upload failed');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }
}
