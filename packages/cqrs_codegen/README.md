# cqrs_codegen

A code generator for the [`cqrs`](../cqrs) package that automatically discovers and registers CQRS command handlers, query handlers, and event handlers.

## Features

- **Auto-Discovery**: Recursively scans directory subtrees for classes implementing `CommandHandler`, `QueryHandler`, or `EventHandler`.
- **Micro-Packages & Modules**: Supports `@CqrsMicroPackage` for modular features and sub-packages with boundary detection.
- **Zero-Boilerplate**: Generates standalone `.cqrs.dart` files with Injectable-style auto-resolved imports.
- **DI Friendly**: Easily bind dependencies for handlers with parameters, while automatically generating default factories for 0-argument handlers.

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

### 1. Feature Micro-Package

In `lib/features/orders/orders_handler.dart`:

```dart
import 'package:cqrs_codegen/cqrs_codegen.dart';

export 'orders_handler.cqrs.dart';

@CqrsMicroPackage(moduleName: 'Orders')
void configureOrdersHandlers() {}
```

### 2. Root Application Initializer

In `lib/cqrs_init.dart`:

```dart
import 'package:cqrs_codegen/cqrs_codegen.dart';

import 'features/orders/orders_handler.dart';

export 'cqrs_init.cqrs.dart';
export 'features/orders/orders_handler.dart';

@CqrsInit(
  moduleName: 'App',
  useMicroPackage: true,
  modules: [OrdersCqrsModule],
)
void configureCqrs() {}
```

### 3. Run code generation

```bash
dart run build_runner build
```

### 4. Register handlers effortlessly

```dart
import 'package:cqrs/cqrs.dart';
import 'package:my_app/cqrs_init.dart';

final dispatcher = CqrsDispatcher();

dispatcher.registry.registerModule(
  AppCqrsModule(
    ordersCqrsModule: OrdersCqrsModule(
      placeOrderCommandHandler: () => PlaceOrderCommandHandler(repository: repository, publisher: dispatcher),
      getOrderQueryHandler: () => GetOrderQueryHandler(repository: repository),
    ),
  ),
);

final orderId = await dispatcher.command(PlaceOrderCommand(...));
```
