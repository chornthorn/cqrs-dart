# dart_cqrs

CQRS and event-driven architecture for Dart. This package is shared infrastructure only: contracts, a dispatcher, and GetIt registration. Application features (commands, queries, events, handlers) live in the host app, not in this library.

## Purpose

Give application code one entry point (`CqrsDispatcher`) for writes, reads, and in-process events. UI and BLoC layers dispatch data objects; they never look up handlers.

## Package layout

| Location | Owns |
|---|---|
| `lib/src/core` | `Query`, `Command`, `DomainEvent`, handlers, `CqrsDispatcher` |
| Host app / `example` | Feature commands, queries, events, and handlers |

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
    ExternalModule(DartCqrsPackageModule),
  ],
)
Future<void> configureDependencies() => getIt.init();
```

Regenerate DI in the host app after adding or changing `@Injectable` handlers.

## Usage

```dart
await dispatcher.dispatchCommand(CreateUserCommand('test@example.com'));
final user = await dispatcher.dispatchQuery(GetUserQuery('USER-123'));
```

Run the sample host app:

```bash
cd example
dart pub get
dart run build_runner build
dart run
```

Expected output:

```text
--- App Started ---
Database: Creating user test@example.com
📊 Tracking analytics for new user USER-123
📨 Sending welcome email to USER-123
Queried user: test@example.com
```

## Running Tests

Library (dispatcher contracts):

```bash
dart test
```

Sample app (user feature):

```bash
cd example && dart test
```

## Environment Variables

None.

## Deployment

Depend on this library from an application package. Call the host app's `configureDependencies()` once at startup, then dispatch through `CqrsDispatcher`.
