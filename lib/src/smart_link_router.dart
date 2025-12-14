import 'package:flutter/material.dart';
import 'link_guard.dart';
import 'link_parser.dart';
import 'link_route.dart';
import 'redirect_memory.dart';

/// The main router class that handles deep links, guards, and navigation.
///
/// Create a single instance and pass it to [MaterialApp.router]:
/// ```dart
/// final router = SmartLinkRouter(
///   routes: [
///     LinkRoute(
///       path: '/home',
///       builder: (context, params) => HomePage(),
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
class SmartLinkRouter {
  /// Creates a new router instance.
  SmartLinkRouter({
    required this.routes,
    this.guards = const [],
    this.notFoundRoute,
  }) {
    _config = RouterConfig<Uri>(
      routeInformationProvider: _SmartRouteInformationProvider(),
      routeInformationParser: _SmartRouteInformationParser(),
      routerDelegate: _SmartRouterDelegate(
        routes: routes,
        guards: guards,
        notFoundRoute: notFoundRoute,
      ),
    );
  }

  /// All route definitions.
  final List<LinkRoute> routes;

  /// Guards that are applied before route activation.
  final List<LinkGuard> guards;

  /// Fallback route when no match is found.
  final LinkRoute? notFoundRoute;

  late final RouterConfig<Uri> _config;

  /// The router configuration for [MaterialApp.router].
  RouterConfig<Uri> get config => _config;

  /// Manually opens a deep link.
  ///
  /// This can be used to programmatically navigate to a URI.
  /// ```dart
  /// router.open(Uri.parse('/product/42?source=notification'));
  /// ```
  Future<void> open(Uri uri) async {
    final delegate = _config.routerDelegate as _SmartRouterDelegate;
    await delegate.setNewRoutePath(uri);
  }
}

class _SmartRouteInformationProvider extends RouteInformationProvider
    with ChangeNotifier {
  RouteInformation _current = RouteInformation(uri: Uri.parse('/'));

  @override
  RouteInformation get value => _current;

  @override
  void routerReportsNewRouteInformation(
    RouteInformation routeInformation, {
    RouteInformationReportingType type = RouteInformationReportingType.none,
  }) {
    _current = routeInformation;
    notifyListeners();
  }
}

class _SmartRouteInformationParser extends RouteInformationParser<Uri> {
  @override
  Future<Uri> parseRouteInformation(RouteInformation routeInformation) async {
    final uri = routeInformation.uri;
    return uri;
  }

  @override
  RouteInformation? restoreRouteInformation(Uri configuration) {
    return RouteInformation(uri: configuration);
  }
}

class _SmartRouterDelegate extends RouterDelegate<Uri>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<Uri> {
  _SmartRouterDelegate({
    required this.routes,
    required this.guards,
    this.notFoundRoute,
  }) : navigatorKey = GlobalKey<NavigatorState>() {
    _currentUri = Uri.parse('/');
  }

  final List<LinkRoute> routes;
  final List<LinkGuard> guards;
  final LinkRoute? notFoundRoute;

  @override
  final GlobalKey<NavigatorState> navigatorKey;

  Uri? _currentUri;
  Widget? _currentPage;

  @override
  Uri? get currentConfiguration => _currentUri;

  @override
  Future<void> setNewRoutePath(Uri configuration) async {
    // Run guards
    for (final guard in guards) {
      final canActivate = await guard.canActivate(configuration);
      if (!canActivate) {
        final redirectUri = guard.onRedirect(configuration);
        if (redirectUri != null) {
          // Save original target for later restoration
          RedirectMemory.instance.save(configuration);
          _currentUri = redirectUri;
          _buildPage(redirectUri);
          notifyListeners();
          return;
        }
      }
    }

    // Guards passed, proceed to route
    _currentUri = configuration;
    _buildPage(configuration);
    notifyListeners();
  }

  void _buildPage(Uri uri) {
    final path = uri.path;
    final queryParams = LinkParser.extractQuery(uri);

    // Find matching route
    for (final route in routes) {
      final pathParams = LinkParser.match(path, route.path);
      if (pathParams != null) {
        final allParams = LinkParser.combineParams(pathParams, queryParams);
        _currentPage = Builder(
          builder: (context) => route.builder(context, allParams),
        );
        return;
      }
    }

    // No match found, use 404 route
    if (notFoundRoute != null) {
      _currentPage = Builder(
        builder: (context) => notFoundRoute!.builder(context, {}),
      );
    } else {
      _currentPage = const _DefaultNotFoundPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      pages: [
        MaterialPage<void>(
          key: ValueKey(_currentUri.toString()),
          child: _currentPage ?? const SizedBox(),
        ),
      ],
      onDidRemovePage: (page) {
        // Handle page removal if needed
      },
    );
  }
}

class _DefaultNotFoundPage extends StatelessWidget {
  const _DefaultNotFoundPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Not Found'),
      ),
      body: const Center(
        child: Text(
          '404 - Page not found',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
