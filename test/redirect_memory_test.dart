import 'package:flutter_test/flutter_test.dart';
import 'package:smart_deeplink_router/smart_deeplink_router.dart';

void main() {
  group('RedirectMemory', () {
    late RedirectMemory memory;

    setUp(() {
      memory = RedirectMemory.instance;
      memory.clear(); // Clear before each test
    });

    test('save stores a URI', () {
      final uri = Uri.parse('/product/42');
      memory.save(uri);
      expect(memory.hasTarget, isTrue);
    });

    test('peek returns stored URI without clearing', () {
      final uri = Uri.parse('/product/42');
      memory.save(uri);

      final peeked = memory.peek();
      expect(peeked, equals(uri));
      expect(memory.hasTarget, isTrue);
    });

    test('consume returns and clears stored URI', () {
      final uri = Uri.parse('/product/42');
      memory.save(uri);

      final consumed = memory.consume();
      expect(consumed, equals(uri));
      expect(memory.hasTarget, isFalse);
    });

    test('consume returns null when no target is stored', () {
      final consumed = memory.consume();
      expect(consumed, isNull);
    });

    test('clear removes stored URI', () {
      final uri = Uri.parse('/product/42');
      memory.save(uri);
      memory.clear();
      expect(memory.hasTarget, isFalse);
    });

    test('hasTarget returns false initially', () {
      expect(memory.hasTarget, isFalse);
    });

    test('saves and retrieves different URIs', () {
      final uri1 = Uri.parse('/product/42');
      memory.save(uri1);
      expect(memory.peek(), equals(uri1));

      final uri2 = Uri.parse('/category/electronics');
      memory.save(uri2);
      expect(memory.peek(), equals(uri2));
    });
  });
}
