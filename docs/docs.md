# Architecture Guidelines: Feature-First Clean Architecture with CQRS

This document outlines the standard architecture pattern for structuring Dart and Flutter applications with CQRS (`cqrs`).

---

## 1. Feature-First Folder Structure

Each feature represents a bounded domain context divided into **4 distinct layers**:

```text
lib/
├── core/
│   ├── errors/
│   │   ├── exceptions.dart
│   │   └── failures.dart
│   └── network/
│
├── features/
│   └── order/
│       │
│       ├── application/             # 1. APPLICATION LAYER (Use Cases / CQRS)
│       │   ├── commands/            # State-mutating actions (Create, Update, Delete)
│       │   │   ├── create_order_command.dart
│       │   │   └── create_order_handler.dart
│       │   ├── queries/             # Read-only actions (Fetch, Search, Stream)
│       │   │   ├── get_order_query.dart
│       │   │   └── get_order_handler.dart
│       │   └── event_handlers/      # Subscriptions to Domain Events
│       │       └── send_confirmation_email_on_order_placed.dart
│       │
│       ├── domain/                  # 2. DOMAIN LAYER (Pure Business Logic)
│       │   ├── entities/            # Core business objects
│       │   │   └── order.dart
│       │   ├── events/              # Domain events that occurred
│       │   │   └── order_placed_event.dart
│       │   └── repositories/        # Abstract repository contracts / interfaces
│       │       └── order_repository.dart
│       │
│       ├── data/ (or infrastructure/)# 3. DATA / INFRASTRUCTURE LAYER
│       │   ├── datasources/         # Remote APIs (REST/GraphQL), Local DB (Drift/Isar)
│       │   │   ├── order_remote_datasource.dart
│       │   │   └── order_local_datasource.dart
│       │   ├── models/              # DTOs / JSON Serialization
│       │   │   └── order_model.dart
│       │   └── repositories/        # Concrete implementation of domain repository
│       │       └── order_repository_impl.dart
│       │
│       └── presentation/            # 4. PRESENTATION LAYER (UI & State Management)
│           ├── controllers/         # BLoC / Cubit / Riverpod / Notifiers
│           │   └── order_controller.dart
│           └── views/               # Widgets & Pages
│               └── order_page.dart
│
├── injection/                       # Dependency Injection setup
└── main.dart
```

---

## 2. Layer Responsibilities

| Layer | Responsibility | Allowed Dependencies | Prohibited Dependencies |
|---|---|---|---|
| **Domain** | Core enterprise business rules, entities, domain events, repository interfaces. | Pure Dart standard library only. | Flutter framework, external packages, HTTP, database packages. |
| **Application (CQRS)** | Orchestrates use cases using `Command`s, `Query`s, and `EventHandler`s. Coordinates domain entities and repository contracts. | Domain layer, `cqrs`, DI annotations (`injectable`). | Flutter UI (`BuildContext`, `Widget`), direct database/HTTP calls. |
| **Data / Infrastructure** | Concrete implementations of repositories, API clients, local persistence, JSON parsing. | Domain layer (implements repository interfaces), HTTP/DB libraries. | Presentation layer. |
| **Presentation** | UI widgets, pages, user interactions, and state management controllers (BLoC / Cubit / Riverpod). | Application layer (calls `CqrsDispatcher`), Domain entities for rendering. | Direct data source / database calls. |

---

## 3. CQRS Implementation Rules with `cqrs`

1. **Pure Dart Application Layer**:
   The `application/` layer must contain 0 Flutter UI imports (`package:flutter/...`). This guarantees 100% fast, isolated unit testability.

2. **Single Entry Point**:
   Presentation controllers communicate exclusively through `CqrsDispatcher`:
   ```dart
   // Write / Mutate:
   await dispatcher.dispatchCommand(CreateOrderCommand(items, total));

   // Read / Query:
   final order = await dispatcher.dispatchQuery(GetOrderQuery(orderId));
   ```

3. **Commands (Mutations)**:
   - Extend `Command<TResult>`.
   - Modifies system state.
   - Triggers domain events via `dispatcher.publishEvent(...)` upon successful completion.

4. **Queries (Reads)**:
   - Extend `Query<TResult>`.
   - Read-only, idempotent, and cache-friendly.
   - Never mutate state or trigger side-effect events.

5. **Event Handlers (Side-effects & Cross-cutting Concerns)**:
   - Implement `EventHandler<TDomainEvent>`.
   - React asynchronously to published events (e.g., analytics, notifications, push delivery, cache eviction).
   - Handlers are decoupled from the command that caused the event.

---

## 4. Testing Strategy (Mirroring `lib/` in `test/`)

Mirror the `lib/` directory inside `test/` for fast and maintainable unit tests:

```text
test/
└── features/
    └── order/
        ├── domain/
        │   ├── entities/order_test.dart
        │   └── events/order_placed_event_test.dart
        ├── application/
        │   ├── commands/create_order_command_test.dart
        │   ├── queries/get_order_query_test.dart
        │   └── event_handlers/send_confirmation_email_test.dart
        └── data/
            ├── datasources/order_remote_datasource_test.dart
            └── repositories/order_repository_impl_test.dart
```
