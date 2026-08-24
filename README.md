# dart_cqrs

Monorepo for CQRS and event-driven architecture in Dart using `get_it` and `injectable`.

## Repository Structure

```
├── packages/
│   └── dart_cqrs/               # Core CQRS library package
└── examples/
    └── hello_world/             # Example host application
```

## Workspace Management

This repository uses [Dart Pub Workspaces](https://dart.dev/tools/pub/workspaces) and [Melos](https://pub.dev/packages/melos).

### Setup

```bash
dart pub get
dart run melos run build
```

### Melos Scripts

| Command | Description |
|---|---|
| `dart run melos run test` | Run tests across all packages |
| `dart run melos run analyze` | Run `dart analyze` across all packages |
| `dart run melos run build` | Run `build_runner` code generation |
| `dart run melos run format` | Verify code formatting |

### Running the Example

```bash
cd examples/hello_world
dart run bin/hello_world.dart
```
