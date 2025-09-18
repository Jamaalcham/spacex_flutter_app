/// Base use case class for common functionality
/// 
/// This abstract class provides a common structure for all use cases
/// following Clean Architecture principles. Each use case should handle
/// a single business operation with proper error handling and validation.
abstract class BaseUseCase<Type, Params> {
  /// Execute the use case with given parameters
  /// 
  /// Returns the result of type [Type] or throws an exception
  Future<Type> execute(Params params);
}

/// Use case that doesn't require parameters
abstract class BaseUseCaseNoParams<Type> {
  /// Execute the use case without parameters
  /// 
  /// Returns the result of type [Type] or throws an exception
  Future<Type> execute();
}

/// Parameters class for use cases that don't need parameters
class NoParams {
  const NoParams();
}
