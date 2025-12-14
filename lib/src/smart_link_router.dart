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
    final delegate = _SmartRouterDelegate(
      routes: routes,
      guards: guards,
      notFoundRoute: notFoundRoute,
    );

    _config = RouterConfig<Uri>(
      routeInformationProvider: _SmartRouteInformationProvider(),
      routeInformationParser: _SmartRouteInformationParser(),
      routerDelegate: delegate,
    );

    // keep a typed reference to delegate for convenience API
    _delegate = delegate;
  }

  late final _SmartRouterDelegate _delegate;

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
    await _delegate.setNewRoutePath(uri);
  }

  /// Opens a route by name with optional path and query parameters.
  ///
  /// Example:
  /// ```dart
  /// router.openNamed('product', params: {'id': '42'}, query: {'ref': 'email'});
  /// ```
  Future<void> openNamed(
    String name, {
    Map<String, String>? params,
    Map<String, String>? query,
  }) async {
    final route = routes.firstWhere(
      (r) => r.name == name,
      orElse: () => throw ArgumentError('No route named "$name"'),
    );

    // Build path by replacing `:param` segments
    String built = route.path;
    params = params ?? <String, String>{};
    for (final entry in params.entries) {
      built = built.replaceAll(':${entry.key}', entry.value);
    }

    Uri uri;
    if (query != null && query.isNotEmpty) {
      uri = Uri(path: built, queryParameters: query);
    } else {
      uri = Uri(path: built);
    }

    await open(uri);
  }

  /// Navigate back in the router's history if possible.
  Future<bool> back() async => _delegate.goBack();

  /// Read-only access to the router's navigation history.
  List<Uri> get history => _delegate.history;
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
  final List<Uri> _history = [];

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
          await RedirectMemory.instance.save(configuration);
          _currentUri = redirectUri;
          _buildPage(redirectUri);
          _history.add(redirectUri);
          notifyListeners();
          return;
        }
      }
    }

    // Guards passed, proceed to route
    _currentUri = configuration;
    _buildPage(configuration);
    _history.add(configuration);
    notifyListeners();
  }

  /// Returns a copy of the navigation history.
  List<Uri> get history => List.unmodifiable(_history);

  /// Attempts to go back in navigation stack.
  Future<bool> goBack() async {
    if (_history.length <= 1) {
      return false;
    }
    // remove current
    _history.removeLast();
    final previous = _history.last;
    await setNewRoutePath(previous);
    return true;
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
          builder: (context) => route.transitionBuilder != null
              ? _RouteWrapper(
                  transitionBuilder: route.transitionBuilder!,
                  child: route.builder(context, allParams),
                )
              : route.builder(context, allParams),
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

/// Internal widget used to apply a per-route transition when the router
/// builds the route's page content.
class _RouteWrapper extends StatelessWidget {
  const _RouteWrapper({
    required this.child,
    required this.transitionBuilder,
  });

  final Widget child;
  final Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)
      transitionBuilder;

  @override
  Widget build(BuildContext context) {
    // Use an AnimatedBuilder driven by a dummy AnimationController via
    // ModalRoute.of(context) when available. For simplicity we wrap with
    // a static FadeTransition driven by an always-completed animation when
    // no route animation is available.
    final animation = ModalRoute.of(context)?.animation;
    final secondary = ModalRoute.of(context)?.secondaryAnimation;

    if (animation != null && secondary != null) {
      return transitionBuilder(context, animation, secondary, child);
    }

    // Fallback: no route animations available, just return child.
    return child;
  }
}
