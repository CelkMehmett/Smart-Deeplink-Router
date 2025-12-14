# 🚀 Quick Start Guide - smart_deeplink_router

Get up and running in 5 minutes!

## Step 1: Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  smart_deeplink_router: ^0.1.0
```

Run:
```bash
flutter pub get
```

## Step 2: Basic Setup (Copy & Paste)

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
      ],
    );

    return MaterialApp.router(
      title: 'My App',
      routerConfig: router.config,
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: const Center(
        child: Text('Welcome!'),
      ),
    );
  }
}

class ProductPage extends StatelessWidget {
  const ProductPage({required this.id, super.key});
  final String id;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Product #$id')),
      body: Center(
        child: Text('Product ID: $id'),
      ),
    );
  }
}
```

**That's it! ✅** Your app now handles deep links like `/product/42`

---

## Step 3: Add Authentication Guard (Optional)

Create a guard:

```dart
class RequireAuthGuard extends LinkGuard {
  RequireAuthGuard({required this.isAuthenticated});
  
  final Future<bool> Function() isAuthenticated;

  @override
  Future<bool> canActivate(Uri uri) => isAuthenticated();

  @override
  Uri? onRedirect(Uri uri) => Uri.parse('/login');
}
```

Add to router:

```dart
final router = SmartLinkRouter(
  routes: [...],
  guards: [
    RequireAuthGuard(
      isAuthenticated: () async => authService.isLoggedIn,
    ),
  ],
);
```

---

## Step 4: Handle Redirect After Login

In your login success handler:

```dart
void onLoginSuccess() {
  final originalTarget = RedirectMemory.instance.consume();
  
  if (originalTarget != null) {
    // User was redirected from somewhere, go back
    router.open(originalTarget);
  } else {
    // Direct login, go to home
    router.open(Uri.parse('/'));
  }
}
```

---

## 🎯 Common Patterns

### Path Parameters
```dart
LinkRoute(
  path: '/user/:userId/post/:postId',
  builder: (context, params) => PostPage(
    userId: params['userId']!,
    postId: params['postId']!,
  ),
)
```

### Query Parameters
```dart
// URL: /search?q=flutter&sort=recent
LinkRoute(
  path: '/search',
  builder: (context, params) => SearchPage(
    query: params['q'],
    sort: params['sort'],
  ),
)
```

### Combined Parameters
```dart
// URL: /product/42?source=email
LinkRoute(
  path: '/product/:id',
  builder: (context, params) => ProductPage(
    id: params['id']!,          // from path
    source: params['source'],   // from query
  ),
)
```

### Conditional Guards
```dart
class RequireAuthGuard extends LinkGuard {
  @override
  Future<bool> canActivate(Uri uri) async {
    // Only protect certain paths
    if (uri.path.startsWith('/admin')) {
      return authService.isAdmin;
    }
    if (uri.path.startsWith('/profile')) {
      return authService.isLoggedIn;
    }
    return true; // Allow all other routes
  }

  @override
  Uri? onRedirect(Uri uri) => Uri.parse('/login');
}
```

---

## 📚 Next Steps

- Read the [full README](README.md) for more details
- Check the [example app](example/main.dart) for complete working code
- See [ARCHITECTURE.md](ARCHITECTURE.md) to understand the internals
- Review [TEST_REPORT.md](TEST_REPORT.md) for test coverage

---

## 💡 Tips

1. **Use `const` constructors** for better performance
2. **Handle missing parameters** with null safety (`params['id']!` or `params['id'] ?? 'default'`)
3. **Keep guards simple** - do one check per guard
4. **Test deep links** with ADB commands:
   ```bash
   adb shell am start -W -a android.intent.action.VIEW -d "yourapp://product/42"
   ```

---

## 🐛 Troubleshooting

**Q: Routes not working?**  
A: Make sure you're using `MaterialApp.router()` not `MaterialApp()`

**Q: Parameters always null?**  
A: Check your path pattern matches the incoming URI exactly

**Q: Guard not triggering?**  
A: Guards run for ALL routes by default. Add conditions inside `canActivate()`

**Q: Lost state after redirect?**  
A: Use `RedirectMemory.instance.save()` before redirect, `.consume()` after login

---

**Need help?** Open an issue on GitHub!

Happy routing! 🎉
