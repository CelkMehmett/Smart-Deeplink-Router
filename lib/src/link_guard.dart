/// Abstract base class for route guards.
///
/// Guards are executed before a route is activated. They can prevent
/// navigation by returning `false` from [canActivate], and optionally
/// provide a redirect URI via [onRedirect].
///
/// Example:
/// ```dart
/// class RequireAuthGuard extends LinkGuard {
///   final Future<bool> Function() isAuthenticated;
///   final String redirectTo;
///
///   RequireAuthGuard({
///     required this.isAuthenticated,
///     required this.redirectTo,
///   });
///
///   @override
///   Future<bool> canActivate(Uri uri) => isAuthenticated();
///
///   @override
///   Uri? onRedirect(Uri uri) => Uri.parse(redirectTo);
/// }
/// ```
abstract class LinkGuard {
  /// Determines whether the route can be activated.
  ///
  /// Returns `true` if navigation should proceed, `false` if it should be blocked.
  /// When `false` is returned, [onRedirect] will be called to determine the redirect target.
  Future<bool> canActivate(Uri uri);

  /// Provides a redirect URI when [canActivate] returns `false`.
  ///
  /// Return `null` to block navigation without redirecting.
  Uri? onRedirect(Uri uri);
}
