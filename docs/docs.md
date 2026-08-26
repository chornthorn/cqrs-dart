# CQRS & Event-Driven Architecture Guide

## Architecture Overview

This project implements a clean, decoupled CQRS (Command Query Responsibility Segregation) and Event-Driven architecture in pure Dart with zero external runtime dependencies.

### Core Principles

1. **Explicit Separation of Concerns**:
   - **Write model (Commands)** is completely separated from **Read model (Queries)**.
   - Cross-cutting side effects are handled via **Events**.

2. **Dispatcher & In-Process Bus**:
   - `CqrsDispatcher` serves as the central mediator for dispatching commands, queries, and events.
   - Handlers are resolved via `HandlerRegistry` (either in-memory map or service locator / DI container).

3. **Commands (Writes)**:
   - Extend `Command<TResult>`.
   - Modifies system state.
   - Triggers domain/system events via `dispatcher.publish(...)` upon successful completion.

4. **Queries (Reads)**:
   - Extend `Query<TResult>`.
   - Read-only, idempotent, and cache-friendly.
   - Never mutate state or trigger side-effect events.

5. **Event Handlers (Side-effects & Cross-cutting Concerns)**:
   - Implement `EventHandler<TEvent>`.
   - React asynchronously to published events (e.g., analytics, notifications, push delivery, cache eviction).
   - Handlers are decoupled from the command that caused the event.

6. **Onion-Layer Pipeline Middleware**:
   - Commands, Queries, and Events can be intercepted using `CommandMiddleware`, `QueryMiddleware`, and `EventMiddleware`.
   - Used for logging, performance metrics, validation, transaction boundaries, and error tracing.
