# 🚀 Quick Start - 5 Minutes to Deep Link Routing

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  smart_deeplink_router: ^0.1.0
```

Run:
```bash
flutter pub get
```

## Basic Setup (3 Steps)

### Step 1: Create Router

```dart
import 'package:smart_deeplink_router/smart_deeplink_router.dart';

final router = SmartLinkRouter(
  routes: [
    LinkRoute(
      path: '/',
      builder: (context, params) => HomePage(),
    ),
    LinkRoute(
      path: '/product/:id',
      builder: (context, params) => ProductPage(
        id: params['id']!,
      ),
    ),
  ],
);
```

### Step 2: Add to MaterialApp

```dart
MaterialApp.router(
  routerConfig: router.config,
);
```

### Step 3: That's it! 🎉

Your app now handles deep links like `/product/42`

## Adding Authentication Guard

### Create a Guard

```dart
class RequireAuthGuard extends LinkGuard {
  final AuthService authService;
  
  RequireAuthGuard(this.authService);

  @override
  Future<bool> canActivate(Uri uri) async {
    return authService.isLoggedIn;
  }

  @override
  Uri? onRedirect(Uri uri) => Uri.parse('/login');
}
```

### Add to Router

```dart
final router = SmartLinkRouter(
  routes: [...],
  guards: [
    RequireAuthGuard(authService),
  ],
);
```

## Handling Login Redirect

In your login success handler:

```dart
void onLoginSuccess() {
  // Check if user was redirected here
  final originalTarget = RedirectMemory.instance.consume();
  
  if (originalTarget != null) {
    // Return to original destination
    router.open(originalTarget);
  } else {
    // No redirect, go home
    router.open(Uri.parse('/'));
  }
}
```

## Complete Example

```dart
import 'package:flutter/material.dart';
import 'package:smart_deeplink_router/smart_deeplink_router.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  final router = SmartLinkRouter(
    routes: [
      LinkRoute(
        path: '/',
        builder: (context, params) => HomePage(),
      ),
      LinkRoute(
        path: '/login',
        builder: (context, params) => LoginPage(),
      ),
      LinkRoute(
        path: '/product/:id',
        builder: (context, params) => ProductPage(
          id: params['id']!,
        ),
      ),
    ],
    guards: [
      RequireAuthGuard(authService),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router.config,
    );
  }
}
```

## What You Get

✅ **Path Parameters**: `/product/:id` → `params['id']`  
✅ **Query Parameters**: `/search?q=flutter` → `params['q']`  
✅ **Auth Guards**: Protect routes automatically  
✅ **Redirect Memory**: Return to original destination after login  
✅ **Deep Links**: Works out of the box  

## Next Steps

- Check out the [full example](example/main.dart)
- Read the [API documentation](https://pub.dev/documentation/smart_deeplink_router)
- Learn about [architecture](ARCHITECTURE.md)

**Need help?** [Open an issue](https://github.com/mehmetcelik/smart_deeplink_router/issues)
