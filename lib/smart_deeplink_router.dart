/// A simple, elegant Flutter package for deep link routing with guards and redirect memory.
///
/// This package solves the common problem of:
/// - Deep link → auth guard → redirect → state restore
///
/// With a minimal, clean API that's production-ready.
///
/// ## Quick Start
///
/// ```dart
/// final router = SmartLinkRouter(
///   routes: [
///     LinkRoute(
///       path: '/home',
///       builder: (context, params) => HomePage(),
///     ),
///     LinkRoute(
///       path: '/product/:id',
///       builder: (context, params) => ProductPage(id: params['id']!),
///     ),
///   ],
///   guards: [
///     RequireAuthGuard(
///       isAuthenticated: () async => authService.isLoggedIn,
///       redirectTo: '/login',
///     ),
///   ],
/// );
///
/// MaterialApp.router(
///   routerConfig: router.config,
/// );
/// ```
///
/// ## Features
///
/// - 🎯 Simple API - just routes and guards
/// - 🔒 Auth guards with automatic redirect
/// - 💾 Redirect memory - return to original destination after login
/// - 🎨 Path parameters (`:id`) and query parameters
/// - 📱 Deep link support out of the box
/// - 🚀 Production-ready, null-safe
library smart_deeplink_router;

export 'src/link_guard.dart';
export 'src/link_route.dart';
export 'src/redirect_memory.dart';
export 'src/smart_link_router.dart';
