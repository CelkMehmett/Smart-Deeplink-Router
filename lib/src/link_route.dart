import 'package:flutter/widgets.dart';

/// A single route definition in the router.
///
/// Each route consists of a path pattern (with optional parameters)
/// and a builder function that creates the corresponding widget.
///
/// Example:
/// ```dart
/// LinkRoute(
///   path: '/product/:id',
///   builder: (context, params) => ProductPage(
///     id: params['id']!,
///   ),
/// )
/// ```
class LinkRoute {
  /// Creates a new route definition.
  const LinkRoute({
    required this.path,
    required this.builder,
    this.name,
  });

  /// The path pattern for this route.
  ///
  /// Supports path parameters using `:paramName` syntax.
  /// Examples:
  /// - `/home`
  /// - `/product/:id`
  /// - `/category/:category/item/:itemId`
  final String path;

  /// Builder function that creates the widget for this route.
  ///
  /// Receives the build context and a map of all parameters
  /// (both path parameters and query parameters).
  final Widget Function(BuildContext context, Map<String, String> params)
      builder;

  /// Optional name for this route.
  ///
  /// Can be used for programmatic navigation.
  final String? name;
}
