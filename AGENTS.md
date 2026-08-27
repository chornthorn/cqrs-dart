# Agent Rules & Guidelines

## 1. No Backward Compatibility Needed

- **Never maintain backward compatibility**: When refactoring, renaming, or modifying APIs, classes, annotations, or parameters, completely remove the old symbols and replace them directly.
- **Do not introduce deprecated aliases or typedefs**: Do not leave legacy aliases, fallback typedefs, or deprecated shims (e.g., no `typedef Singleton = Injectable;`, no legacy `@module`, no `@Named`, no `@thirdParty`).
- **Clean and breaking changes are preferred**: Keep the codebase modern, clean, and free of redundant compatibility wrappers.

## 2. Architecture & Design Principles

- **Dart Idiomatic & Minimalist**: Avoid unnecessary boilerplates and maintain clean, self-documenting code.
- **Injectable Micro-Packages**:
  - `@InjectableMicroPackage(moduleName: 'Feature')` defines a folder-scoped micro-package.
  - Root `@InjectableInit(useMicroPackage: true)` discovers and registers all micro-packages flatly at the root container.
  - No `useMicroPackage` parameter on `@InjectableMicroPackage`.
  - Use unified `@Injectable(scope: Scope.singleton | Scope.lazySingleton | Scope.factory)`.
  - Use `@externalModule` for external provider modules and `@Inject('tag')` for qualifiers.
- **CQRS Micro-Packages**:
  - `@CqrsMicroPackage(moduleName: 'Feature')` defines isolated CQRS boundaries.
  - Handlers and commands are organized cleanly with zero runtime overhead.
