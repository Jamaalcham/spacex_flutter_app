/// Base exception class for all application-specific exceptions
/// 
/// This abstract class provides a common interface for all custom exceptions
/// in the application, making error handling more consistent and maintainable.
abstract class AppException implements Exception {
  /// Human-readable error message
  final String message;
  
  /// Optional error code for programmatic handling
  final String? code;
  
  /// Optional additional details about the error
  final Map<String, dynamic>? details;

  const AppException(
    this.message, {
    this.code,
    this.details,
  });

  @override
  String toString() => 'AppException: $message';
}

/// Exception thrown when network connectivity issues occur
/// 
/// This includes scenarios like no internet connection, DNS resolution failures,
/// connection timeouts, and other network-related problems.
class NetworkException extends AppException {
  const NetworkException(
    String message, {
    String? code,
    Map<String, dynamic>? details,
  }) : super(message, code: code, details: details);

  @override
  String toString() => 'NetworkException: $message';
}

/// Exception thrown when server returns an error response
/// 
/// This includes HTTP error status codes, GraphQL errors,
/// and other server-side issues.
class ServerException extends AppException {
  /// HTTP status code (if applicable)
  final int? statusCode;

  const ServerException(
    String message, {
    this.statusCode,
    String? code,
    Map<String, dynamic>? details,
  }) : super(message, code: code, details: details);

  @override
  String toString() => 'ServerException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
}

/// Exception thrown when a requested resource is not found
/// 
/// This typically occurs when trying to fetch a specific item by ID
/// that doesn't exist in the data source.
class NotFoundException extends AppException {
  const NotFoundException(
    String message, {
    String? code,
    Map<String, dynamic>? details,
  }) : super(message, code: code, details: details);

  @override
  String toString() => 'NotFoundException: $message';
}

/// Exception thrown when local cache operations fail
/// 
/// This includes scenarios like storage full, permission denied,
/// data corruption, and other local storage issues.
class CacheException extends AppException {
  const CacheException(
    String message, {
    String? code,
    Map<String, dynamic>? details,
  }) : super(message, code: code, details: details);

  @override
  String toString() => 'CacheException: $message';
}

/// Exception thrown when data parsing or validation fails
/// 
/// This occurs when received data doesn't match expected format
/// or fails validation rules.
class DataException extends AppException {
  const DataException(
    String message, {
    String? code,
    Map<String, dynamic>? details,
  }) : super(message, code: code, details: details);

  @override
  String toString() => 'DataException: $message';
}

/// Exception thrown when user authentication fails
/// 
/// This includes invalid credentials, expired tokens,
/// and other authentication-related issues.
class AuthException extends AppException {
  const AuthException(
    String message, {
    String? code,
    Map<String, dynamic>? details,
  }) : super(message, code: code, details: details);

  @override
  String toString() => 'AuthException: $message';
}

/// Exception thrown when user lacks permission for an operation
/// 
/// This occurs when authenticated users try to access resources
/// they don't have permission to view or modify.
class PermissionException extends AppException {
  const PermissionException(
    String message, {
    String? code,
    Map<String, dynamic>? details,
  }) : super(message, code: code, details: details);

  @override
  String toString() => 'PermissionException: $message';
}

/// Exception thrown when an operation times out
/// 
/// This includes network request timeouts, operation timeouts,
/// and other time-based failures.
class TimeoutException extends AppException {
  /// Timeout duration that was exceeded
  final Duration? timeout;

  const TimeoutException(
    String message, {
    this.timeout,
    String? code,
    Map<String, dynamic>? details,
  }) : super(message, code: code, details: details);

  @override
  String toString() => 'TimeoutException: $message${timeout != null ? ' (Timeout: ${timeout!.inSeconds}s)' : ''}';
}
