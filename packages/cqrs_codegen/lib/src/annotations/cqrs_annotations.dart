/// Annotation to mark an initialization point for CQRS handler code generation.
///
/// Example:
/// ```dart
/// @CqrsInit()
/// void configureHandlers(HandlerRegistry registry) => registry.registerGeneratedHandlers();
/// ```
class CqrsInit {
  /// Creates a [CqrsInit] annotation.
  const CqrsInit({this.includeDefaultFactories = true});

  /// Whether handlers with 0-argument constructors should have default factory values.
  final bool includeDefaultFactories;
}

/// Constant instance for `@cqrsInit` annotation.
const cqrsInit = CqrsInit();

/// Optional annotation to explicitly mark a class as a CQRS handler.
class CqrsHandler {
  /// Creates a [CqrsHandler] annotation.
  const CqrsHandler();
}

/// Constant instance for `@cqrsHandler` annotation.
const cqrsHandler = CqrsHandler();
