import 'package:dio/dio.dart';

// Custom network exceptions for better error handling
class NetworkException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  const NetworkException({
    required this.message,
    this.statusCode,
    this.data,
  });

  @override
  String toString() => 'NetworkException: $message';
}

// Network exception handler
class NetworkExceptionHandler {
  static NetworkException handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return const NetworkException(
          message: 'Connection timeout. Please check your internet connection.',
        );
      
      case DioExceptionType.sendTimeout:
        return const NetworkException(
          message: 'Send timeout. Please try again.',
        );
      
      case DioExceptionType.receiveTimeout:
        return const NetworkException(
          message: 'Receive timeout. Please try again.',
        );
      
      case DioExceptionType.badResponse:
        return NetworkException(
          message: _getErrorMessage(error.response?.statusCode),
          statusCode: error.response?.statusCode,
          data: error.response?.data,
        );
      
      case DioExceptionType.cancel:
        return const NetworkException(
          message: 'Request was cancelled.',
        );
      
      case DioExceptionType.connectionError:
        return const NetworkException(
          message: 'No internet connection. Please check your network.',
        );
      
      case DioExceptionType.badCertificate:
        return const NetworkException(
          message: 'Certificate error. Please try again.',
        );
      
      case DioExceptionType.unknown:
      return NetworkException(
          message: error.message ?? 'An unexpected error occurred.',
        );
    }
  }

  static String _getErrorMessage(int? statusCode) {
    switch (statusCode) {
      case 400:
        return 'Bad request. Please check your input.';
      case 401:
        return 'Unauthorized. Please check your credentials.';
      case 403:
        return 'Forbidden. You don\'t have permission to access this resource.';
      case 404:
        return 'Resource not found.';
      case 429:
        return 'Too many requests. Please try again later.';
      case 500:
        return 'Internal server error. Please try again later.';
      case 502:
        return 'Bad gateway. Please try again later.';
      case 503:
        return 'Service unavailable. Please try again later.';
      default:
        return 'An error occurred. Please try again.';
    }
  }
}
