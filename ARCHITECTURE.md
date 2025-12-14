# smart_deeplink_router - Architecture & Design

## Overview

This document explains the internal architecture of the smart_deeplink_router package.

## Core Components

### 1. LinkRoute
- Represents a single route definition
- Contains path pattern and builder function
- Supports path parameters (`:id` syntax)

### 2. LinkParser
- Utility class for URI parsing
- Matches paths against patterns
- Extracts path and query parameters
- Combines parameters into single map

### 3. LinkGuard
- Abstract interface for route protection
- Async `canActivate()` for auth checks
- `onRedirect()` provides redirect target
- Guards run before route activation

### 4. RedirectMemory
- Singleton for storing redirect targets
- In-memory storage (no persistence yet)
- `save()` - stores original destination
- `consume()` - retrieves and clears
- `peek()` - retrieves without clearing

### 5. SmartLinkRouter
- Main orchestrator class
- Creates Flutter `RouterConfig`
- Manages guards and routes
- Provides `open()` for manual navigation

## Navigation Flow

```
Deep Link Received
       ↓
Parse URI (LinkParser)
       ↓
Run Guards (LinkGuard)
       ↓
Guard Passed? ─── No ──→ Save to RedirectMemory ──→ Navigate to redirect
       ↓
      Yes
       ↓
Match Route (LinkParser)
       ↓
Extract Parameters
       ↓
Build Widget (LinkRoute.builder)
       ↓
Display Page
```

## Guard Execution

Guards execute in order before route activation:

```dart
for (final guard in guards) {
  final canActivate = await guard.canActivate(uri);
  if (!canActivate) {
    final redirectUri = guard.onRedirect(uri);
    if (redirectUri != null) {
      RedirectMemory.instance.save(uri); // Save original
      navigate(redirectUri);             // Go to redirect
      return;
    }
  }
}
// All guards passed, proceed to route
```

## Parameter Resolution

Path and query parameters are combined:

```
URI: /product/42?source=email

Path pattern: /product/:id
Path params: {id: '42'}
Query params: {source: 'email'}

Combined: {id: '42', source: 'email'}
```

## Design Decisions

### Why no nested routes?
- Keeps API simple
- Most deep link scenarios don't need nesting
- Can be added later without breaking changes

### Why in-memory redirect storage?
- Simple for most use cases
- No dependencies on persistence libraries
- Can be upgraded to persistent storage in future

### Why abstract LinkGuard?
- Maximum flexibility for users
- Can implement any auth logic
- Easy to test in isolation

### Why single Map<String, String> for params?
- Unified interface for builder
- No distinction needed between path/query
- Simple type, easy to use

## Future Enhancements

1. **Named Routes**: Reference routes by name instead of path
2. **Route History**: Track navigation history
3. **Persistent Redirect**: Save to SharedPreferences
4. **Nested Navigation**: Support for tab/drawer navigation
5. **Transition Animations**: Custom page transitions

## Testing Strategy

- Unit tests for LinkParser logic
- Integration tests for guard execution
- Widget tests for example app
- Mock guards for testing scenarios

## Performance Considerations

- Guards run serially (not parallel) to ensure order
- Route matching is O(n) where n is number of routes
- RedirectMemory is singleton (no instantiation overhead)
- No unnecessary rebuilds (ChangeNotifier used correctly)

---

For questions or suggestions about the architecture, please open an issue on GitHub.
