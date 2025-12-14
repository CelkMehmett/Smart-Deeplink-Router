import 'package:flutter_test/flutter_test.dart';
import 'package:smart_deeplink_router/smart_deeplink_router.dart';

class TestGuard extends LinkGuard {
  TestGuard({
    required this.shouldAllow,
    this.redirectPath,
  });

  final bool shouldAllow;
  final String? redirectPath;

  @override
  Future<bool> canActivate(Uri uri) async => shouldAllow;

  @override
  Uri? onRedirect(Uri uri) {
    if (redirectPath != null) {
      return Uri.parse(redirectPath!);
    }
    return null;
  }
}

void main() {
  group('LinkGuard', () {
    test('TestGuard allows navigation when shouldAllow is true', () async {
      final guard = TestGuard(shouldAllow: true);
      final uri = Uri.parse('/product/42');

      final canActivate = await guard.canActivate(uri);
      expect(canActivate, isTrue);
    });

    test('TestGuard blocks navigation when shouldAllow is false', () async {
      final guard = TestGuard(shouldAllow: false, redirectPath: '/login');
      final uri = Uri.parse('/product/42');

      final canActivate = await guard.canActivate(uri);
      expect(canActivate, isFalse);
    });

    test('TestGuard provides redirect URI when blocked', () {
      final guard = TestGuard(
        shouldAllow: false,
        redirectPath: '/login',
      );
      final uri = Uri.parse('/product/42');

      final redirectUri = guard.onRedirect(uri);
      expect(redirectUri, isNotNull);
      expect(redirectUri!.path, equals('/login'));
    });

    test('TestGuard can return null redirect', () {
      final guard = TestGuard(shouldAllow: false);
      final uri = Uri.parse('/product/42');

      final redirectUri = guard.onRedirect(uri);
      expect(redirectUri, isNull);
    });
  });
}
