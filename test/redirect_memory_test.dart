import 'package:flutter_test/flutter_test.dart';
import 'package:smart_deeplink_router/smart_deeplink_router.dart';

void main() {
  group('RedirectMemory', () {
    late RedirectMemory memory;

    setUp(() async {
      memory = RedirectMemory.instance;
      await memory.clear();
    });

    setUpAll(() async {
      // Initialize without persistence for unit tests
      await RedirectMemory.instance.initialize(persistent: false);
    });

    test('save stores a URI', () async {
      final uri = Uri.parse('/product/42');
      await memory.save(uri);
      expect(memory.hasTarget, isTrue);
    });

    test('peek returns stored URI without clearing', () async {
      final uri = Uri.parse('/product/42');
      await memory.save(uri);

      final peeked = memory.peek();
      expect(peeked, equals(uri));
      expect(memory.hasTarget, isTrue);
    });

    test('consume returns and clears stored URI', () async {
      final uri = Uri.parse('/product/42');
      await memory.save(uri);

      final consumed = await memory.consume();
      expect(consumed, equals(uri));
      expect(memory.hasTarget, isFalse);
    });

    test('consume returns null when no target is stored', () async {
      final consumed = await memory.consume();
      expect(consumed, isNull);
    });

    test('clear removes stored URI', () async {
      final uri = Uri.parse('/product/42');
      await memory.save(uri);
      await memory.clear();
      expect(memory.hasTarget, isFalse);
    });

    test('hasTarget returns false initially', () {
      expect(memory.hasTarget, isFalse);
    });

    test('saves and retrieves different URIs', () async {
      final uri1 = Uri.parse('/product/42');
      await memory.save(uri1);
      expect(memory.peek(), equals(uri1));

      final uri2 = Uri.parse('/category/electronics');
      await memory.save(uri2);
      expect(memory.peek(), equals(uri2));
    });
  });
}
