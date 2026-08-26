The `application/` layer must contain 0 Flutter UI imports (`package:flutter/...`). This guarantees 100% fast, isolated unit testability.

2. **Single Entry Point**:
   Presentation controllers communicate exclusively through `CqrsDispatcher`:

   ```dart
   // Write / Mutate:
   await dispatcher.command(CreateOrderCommand(items, total));

   // Read / Query:
   final order = await dispatcher.query(GetOrderQuery(orderId));
   ```

3. **Commands (Mutations)**:
   - Extend `Command<TResult>`.
   - Modifies system state.
   - Triggers domain events via `dispatcher.publish(...)` upon successful completion.

4. **Queries (Reads)**:
   - Extend `Query<TResult>`.
   - Read-only, idempotent, and cache-friendly.
   - Never mutate state or trigger side-effect events.

5. **Event Handlers (Side-effects & Cross-cutting Concerns)**:
   - Implement `EventHandler<TDomainEvent>`.
   - React asynchronously to published events (e.g., analytics, notifications, push delivery, cache eviction).
   - Handlers are decoupled from the command that caused the event.
