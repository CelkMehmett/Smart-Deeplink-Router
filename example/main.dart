import 'package:flutter/material.dart';
import 'package:smart_deeplink_router/smart_deeplink_router.dart';

Future<void> main() async {
  // Initialize redirect memory (non-persistent by default in example).
  await RedirectMemory.instance.initialize(persistent: false);
  runApp(const MyApp());
}

/// Example authentication service (in-memory for demo purposes)
class AuthService {
  bool _isAuthenticated = false;

  bool get isLoggedIn => _isAuthenticated;

  void login() {
    _isAuthenticated = true;
  }

  void logout() {
    _isAuthenticated = false;
  }
}

final authService = AuthService();

/// Custom auth guard implementation
class RequireAuthGuard extends LinkGuard {
  RequireAuthGuard({
    required this.isAuthenticated,
    required this.redirectTo,
  });

  final Future<bool> Function() isAuthenticated;
  final String redirectTo;

  @override
  Future<bool> canActivate(Uri uri) => isAuthenticated();

  @override
  Uri? onRedirect(Uri uri) => Uri.parse(redirectTo);
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final SmartLinkRouter router;

  @override
  void initState() {
    super.initState();
    router = SmartLinkRouter(
      routes: [
        LinkRoute(
          path: '/',
          builder: (context, params) => const HomePage(),
        ),
        LinkRoute(
          path: '/login',
          builder: (context, params) => const LoginPage(),
        ),
        LinkRoute(
          path: '/product/:id',
          builder: (context, params) => ProductPage(
            productId: params['id'] ?? 'unknown',
          ),
        ),
      ],
      guards: [
        RequireAuthGuard(
          isAuthenticated: () async {
            // Only protect product pages
            final uri = router.config.routerDelegate.currentConfiguration;
            if (uri != null && uri.path.startsWith('/product')) {
              return authService.isLoggedIn;
            }
            return true;
          },
          redirectTo: '/login',
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Smart DeepLink Router Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routerConfig: router.config,
    );
  }
}

/// Home page
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome to Smart DeepLink Router Demo!',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                // This will trigger auth guard and redirect to login
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const ProductPage(productId: '42'),
                  ),
                );
              },
              icon: const Icon(Icons.shopping_bag),
              label: const Text('View Product #42'),
            ),
            const SizedBox(height: 16),
            Text(
              'Auth Status: ${authService.isLoggedIn ? "Logged In ✓" : "Not Logged In ✗"}',
              style: TextStyle(
                color: authService.isLoggedIn ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (authService.isLoggedIn) ...[
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  authService.logout();
                  // Trigger rebuild
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => const HomePage(),
                    ),
                  );
                },
                child: const Text('Logout'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Login page
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.lock_outline,
              size: 80,
              color: Colors.blue,
            ),
            const SizedBox(height: 24),
            const Text(
              'You need to login to access this page',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () async {
                // Simulate login
                authService.login();

                // Capture navigator before awaiting to avoid using BuildContext
                // across an async gap (fixes analyzer warning).
                final navigator = Navigator.of(context);

                // Check if there's a redirect target
                final redirectTarget = await RedirectMemory.instance.consume();
                if (redirectTarget != null) {
                  // Navigate to the original target
                  navigator.pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => ProductPage(
                        productId: redirectTarget.pathSegments.last,
                      ),
                    ),
                  );
                } else {
                  // No redirect target, go to home
                  navigator.pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => const HomePage(),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.login),
              label: const Text('Login with Demo Account'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => const HomePage(),
                  ),
                );
              },
              child: const Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Product page
class ProductPage extends StatelessWidget {
  const ProductPage({
    required this.productId,
    super.key,
  });

  final String productId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Product #$productId'),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.shopping_bag,
              size: 80,
              color: Colors.green,
            ),
            const SizedBox(height: 24),
            Text(
              'Product Details',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            Text(
              'Product ID: $productId',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 32),
            const Text(
              '✓ You successfully accessed a protected route!',
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => const HomePage(),
                  ),
                );
              },
              child: const Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }
}
