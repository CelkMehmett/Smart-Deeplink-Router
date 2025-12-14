# smart_deeplink_router

A simple, elegant Flutter package for deep link routing with guards and redirect memory.

[![pub package](https://img.shields.io/pub/v/smart_deeplink_router.svg)](https://pub.dev/packages/smart_deeplink_router)

## Why this package?

Deep linking in Flutter often requires solving this common problem:

**User clicks deep link → needs authentication → redirect to login → after login, return to original destination**

Most routing solutions make this complex. `smart_deeplink_router` solves it with a clean, minimal API.

## Features

✅ **Simple API** - Just routes and guards, nothing more  
✅ **Auth Guards** - Protect routes with async authentication checks  
✅ **Redirect Memory** - Automatically return to the original destination after login  
✅ **Path Parameters** - Support for `:id` style parameters  
✅ **Query Parameters** - Automatically parsed and passed to builders  
✅ **Deep Links** - Works out of the box with Flutter's deep linking  
✅ **Production Ready** - Null-safe, well-tested, documented

## Quick Start

### Installation

```yaml
dependencies:
  smart_deeplink_router: ^0.1.0
```

### Basic Usage

```dart
import 'package:flutter/material.dart';
import 'package:smart_deeplink_router/smart_deeplink_router.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = SmartLinkRouter(
      routes: [
        LinkRoute(
          path: '/',
          builder: (context, params) => const HomePage(),
        ),
        LinkRoute(
          path: '/product/:id',
          builder: (context, params) => ProductPage(
            id: params['id']!,
          ),
        ),
        LinkRoute(
          path: '/login',
          builder: (context, params) => const LoginPage(),
        ),
      ],
      guards: [
        RequireAuthGuard(
          isAuthenticated: () async => authService.isLoggedIn,
          redirectTo: '/login',
        ),
      ],
    );

    return MaterialApp.router(
      routerConfig: router.config,
    );
  }
}
```

### Creating a Guard

```dart
class RequireAuthGuard extends LinkGuard {
  final Future<bool> Function() isAuthenticated;
  final String redirectTo;

  RequireAuthGuard({
    required this.isAuthenticated,
    required this.redirectTo,
  });

  @override
  Future<bool> canActivate(Uri uri) => isAuthenticated();

  @override
  Uri? onRedirect(Uri uri) => Uri.parse(redirectTo);
}
```

### Handling Redirects After Login

```dart
// In your login success handler:
authService.login();

final redirectTarget = RedirectMemory.instance.consume();
if (redirectTarget != null) {
  // Navigate back to the original deep link destination
  router.open(redirectTarget);
} else {
  // No redirect, go to home
  router.open(Uri.parse('/'));
}
```

## Complete Example

See the [example](example/main.dart) directory for a complete working app demonstrating:

- Home page with navigation
- Protected product page requiring authentication
- Login page with redirect memory
- Deep link handling with path parameters

## API Reference

### SmartLinkRouter

Main router class that handles navigation and guards.

```dart
SmartLinkRouter({
  required List<LinkRoute> routes,
  List<LinkGuard> guards = const [],
  LinkRoute? notFoundRoute,
});
```

**Properties:**
- `config` - The `RouterConfig` to pass to `MaterialApp.router`

**Methods:**
- `open(Uri uri)` - Manually navigate to a URI

### LinkRoute

Defines a single route in your application.

```dart
LinkRoute({
  required String path,
  required Widget Function(BuildContext, Map<String, String>) builder,
  String? name,
});
```

**Path Syntax:**
- Static: `/home`, `/about`
- With parameters: `/product/:id`, `/user/:userId/post/:postId`

### LinkGuard

Abstract class for creating route guards.

```dart
abstract class LinkGuard {
  Future<bool> canActivate(Uri uri);
  Uri? onRedirect(Uri uri);
}
```

### RedirectMemory

Singleton for managing redirect targets.

```dart
RedirectMemory.instance.save(uri);    // Save target
RedirectMemory.instance.consume();    // Get and clear
RedirectMemory.instance.peek();       // Get without clearing
RedirectMemory.instance.clear();      // Clear without getting
```

## Compared to Other Solutions

### vs go_router

- **Simpler API**: No complex nested routes or shell routes
- **Focused**: Solves deep link + auth problem specifically
- **Lighter**: Minimal dependencies and smaller package size

### vs auto_route

- **No code generation**: Pure Dart, no build_runner needed
- **More flexible guards**: Async guards with redirect memory built-in
- **Easier to learn**: Fewer concepts to understand

## Roadmap

- [ ] Named routes support
- [ ] Transition animations
- [ ] Nested navigation
- [ ] Route history management
- [ ] Persistent redirect memory (SharedPreferences)

## Contributing

Contributions are welcome! Please read our [contributing guidelines](CONTRIBUTING.md) first.

## License

MIT License - see [LICENSE](LICENSE) file for details.

## Author

Created with ❤️ for the Flutter community

---

**⭐ If you find this package helpful, please give it a star on GitHub!**
