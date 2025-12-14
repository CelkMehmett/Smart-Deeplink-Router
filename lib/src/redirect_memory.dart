import 'package:shared_preferences/shared_preferences.dart';

/// In-memory (or optionally persistent) storage for redirect targets.
class RedirectMemory {
  RedirectMemory._();

  static final RedirectMemory _instance = RedirectMemory._();

  /// Singleton instance.
  static RedirectMemory get instance => _instance;

  Uri? _originalTarget;
  bool _persistent = false;
  SharedPreferences? _prefs;

  /// Initializes the redirect memory. If [persistent] is true, SharedPreferences
  /// will be used to persist the redirect target across app restarts.
  Future<void> initialize({bool persistent = false}) async {
    _persistent = persistent;
    if (_persistent) {
      _prefs = await SharedPreferences.getInstance();
      final saved = _prefs?.getString(_kKey);
      if (saved != null && saved.isNotEmpty) {
        try {
          _originalTarget = Uri.parse(saved);
        } catch (_) {
          _originalTarget = null;
        }
      }
    }
  }

  static const _kKey = 'smart_deeplink_router.redirect_target';

  /// Stores the original navigation target before redirect.
  Future<void> save(Uri uri) async {
    _originalTarget = uri;
    if (_persistent && _prefs != null) {
      await _prefs!.setString(_kKey, uri.toString());
    }
  }

  /// Retrieves and clears the stored target.
  ///
  /// Returns `null` if no target is stored.
  Future<Uri?> consume() async {
    final target = _originalTarget;
    _originalTarget = null;
    if (_persistent && _prefs != null) {
      await _prefs!.remove(_kKey);
    }
    return target;
  }

  /// Retrieves the stored target without clearing it.
  Uri? peek() => _originalTarget;

  /// Clears the stored target without returning it.
  Future<void> clear() async {
    _originalTarget = null;
    if (_persistent && _prefs != null) {
      await _prefs!.remove(_kKey);
    }
  }

  /// Checks if there is a stored redirect target.
  bool get hasTarget => _originalTarget != null;
}
