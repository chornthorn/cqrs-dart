# cqrs_codegen

A code generator for the [`cqrs`](../cqrs) package that automatically discovers and registers CQRS command handlers, query handlers, stream query handlers, and event handlers.

## Features

- 🔍 **Auto-Discovery**: Discovers classes implementing `CommandHandler`, `QueryHandler`, `StreamQueryHandler`, or `EventHandler`.
- 🛠 **Zero-Boilerplate**: Generates type-safe `HandlerRegistry` extension methods.
- 💉 **DI Friendly**: Easily bind dependencies for handlers with parameters, while automatically generating default factories for 0-argument handlers.

## Getting Started

Add `cqrs` and `cqrs_codegen` to your `pubspec.yaml`:

```yaml
dependencies:
  cqrs: ^1.0.0
  cqrs_codegen: ^1.0.0

dev_dependencies:
  build_runner: ^2.4.0
```

## Usage

### 1. Annotate your initialization file

Create `lib/cqrs_init.dart`:

```dart
import 'package:cqrs_codegen/cqrs_codegen.dart';
import 'features/orders/orders.dart';

part 'cqrs_init.g.dart';

@cqrsInit
void configureCqrs() {}
```

### 2. Run code generation

```bash
dart run build_runner build
```

### 3. Register handlers effortlessly

```dart
final dispatcher = CqrsDispatcher();

dispatcher.registry.registerGeneratedHandlers(
  placeOrderCommandHandler: () => PlaceOrderCommandHandler(repository, dispatcher),
  getOrderQueryHandler: () => GetOrderQueryHandler(repository),
  // Handlers with zero-arg constructors are provided by default!
);

final orderId = await dispatcher.command(PlaceOrderCommand(...));
```
