# cqrs

CQRS and event-driven architecture for Dart. This package is shared infrastructure only: contracts, a dispatcher, and GetIt registration. Application features (commands, queries, events, handlers) live in the host app, not in this library.

## Purpose

Give application code one entry point (`CqrsDispatcher`) for writes, reads, and in-process events. UI and BLoC layers dispatch data objects; they never look up handlers.

## Prerequisites

- Dart SDK `^3.12.0`

## Local Setup

```bash
dart pub get
dart run build_runner build
```

Host apps that use injectable include this package as an external module, then register their own feature handlers:

```dart
@InjectableInit(
  allowMultipleRegistrations: true,
  externalPackageModulesBefore: [
    ExternalModule(CqrsPackageModule),
  ],
)
Future<void> configureDependencies() => getIt.init();
```

## Usage

```dart
await dispatcher.dispatchCommand(CreateUserCommand('test@example.com'));
final user = await dispatcher.dispatchQuery(GetUserQuery('USER-123'));
```
