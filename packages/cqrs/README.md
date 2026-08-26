# cqrs

Lightweight, **pure Dart** CQRS (Command Query Responsibility Segregation) and event-driven architecture library with **zero third-party dependencies**.

## Features

- **Pure Dart**: Zero runtime dependencies. Compatible with Flutter, pure Dart, server-side Dart, and CLI apps.
- **Strongly Typed**: Clean generic contracts for `Command<TResult>`, `Query<TResult>`, and `Event`.
- **Pluggable & Container Agnostic**: Built-in default in-process registry via `CqrsDispatcher()`, or connect to any DI framework (`GetIt`, `Riverpod`, etc.) via `HandlerRegistry.resolver`.
- **Pipeline & Middlewares**: Built-in support for interceptors/middleware (logging, tracing, metrics, validation, retries).

## Getting Started

Add `cqrs` to your `pubspec.yaml`:

```yaml
dependencies:
  cqrs: ^1.0.0
```

## Quick Start

### 1. Define Commands, Queries, and Events

```dart
import 'package:cqrs/cqrs.dart';

// Command
class CreateUserCommand extends Command<String> {
  CreateUserCommand(this.email);
  final String email;
}

class CreateUserCommandHandler implements CommandHandler<CreateUserCommand, String> {
  @override
  Future<String> execute(CreateUserCommand command) async {
    // perform mutation
    return 'USER-123';
  }
}

// Query
class GetUserQuery extends Query<User?> {
  GetUserQuery(this.id);
  final String id;
}

class GetUserQueryHandler implements QueryHandler<GetUserQuery, User?> {
  @override
  Future<User?> execute(GetUserQuery query) async {
    return User(id: query.id, email: 'user@example.com');
  }
}

// Event
class UserCreatedEvent extends Event {
  UserCreatedEvent(this.userId);
  final String userId;
}

class WelcomeEmailHandler implements EventHandler<UserCreatedEvent> {
  @override
  Future<void> handle(UserCreatedEvent event) async {
    print('Sending welcome email to ${event.userId}');
  }
}
```

### 2. Configure Dispatcher & Handlers

```dart
void main() async {
  // 1. Create dispatcher (internal registry is created automatically)
  final dispatcher = CqrsDispatcher();

  // 2. Register handlers directly via dispatcher.registry
  dispatcher.registry
    ..registerCommand<CreateUserCommand, String>(CreateUserCommandHandler.new)
    ..registerQuery<GetUserQuery, User?>(GetUserQueryHandler.new)
    ..registerEvent<UserCreatedEvent>(WelcomeEmailHandler.new);

  // 3. Dispatch command
  final userId = await dispatcher.command(CreateUserCommand('hello@example.com'));

  // 4. Dispatch query
  final user = await dispatcher.query(GetUserQuery(userId));

  // 5. Publish event
  await dispatcher.publish(UserCreatedEvent(userId));
}
```

### 3. Add Middleware / Pipelines

```dart
class LoggingCommandMiddleware implements CommandMiddleware {
  @override
  Future<TResult> handle<TCommand extends Command<TResult>, TResult>(
    TCommand command,
    NextHandler<TResult> next,
  ) async {
    print('[CQRS] Executing ${command.runtimeType}...');
    final result = await next();
    print('[CQRS] Completed ${command.runtimeType}');
    return result;
  }
}

final dispatcher = CqrsDispatcher(
  commandMiddlewares: [LoggingCommandMiddleware()],
);
```

## Codegen Support

For automatic discovery and registration of handlers using `build_runner`, check out [`cqrs_codegen`](../cqrs_codegen).
