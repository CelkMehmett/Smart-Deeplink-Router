/// In-memory storage for redirect targets.
///
/// When a user is redirected (e.g., to login), the original destination
/// is stored here. After successful authentication, the app can retrieve
/// and navigate to the original target.
class RedirectMemory {
  RedirectMemory._();

  static final RedirectMemory _instance = RedirectMemory._();

  /// Singleton instance.
  static RedirectMemory get instance => _instance;

  Uri? _originalTarget;

  /// Stores the original navigation target before redirect.
  void save(Uri uri) {
    _originalTarget = uri;
  }

  /// Retrieves and clears the stored target.
  ///
  /// Returns `null` if no target is stored.
  Uri? consume() {
    final target = _originalTarget;
    _originalTarget = null;
    return target;
  }

  /// Retrieves the stored target without clearing it.
  Uri? peek() => _originalTarget;

  /// Clears the stored target without returning it.
  void clear() {
    _originalTarget = null;
  }

  /// Checks if there is a stored redirect target.
  bool get hasTarget => _originalTarget != null;
}
