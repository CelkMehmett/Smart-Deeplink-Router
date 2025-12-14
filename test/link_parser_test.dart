import 'package:flutter_test/flutter_test.dart';
import 'package:smart_deeplink_router/src/link_parser.dart';

void main() {
  group('LinkParser', () {
    group('match', () {
      test('matches exact path', () {
        final params = LinkParser.match('/home', '/home');
        expect(params, isNotNull);
        expect(params, isEmpty);
      });

      test('matches path with single parameter', () {
        final params = LinkParser.match('/product/42', '/product/:id');
        expect(params, isNotNull);
        expect(params!['id'], equals('42'));
      });

      test('matches path with multiple parameters', () {
        final params = LinkParser.match(
          '/category/electronics/item/123',
          '/category/:category/item/:itemId',
        );
        expect(params, isNotNull);
        expect(params!['category'], equals('electronics'));
        expect(params['itemId'], equals('123'));
      });

      test('returns null for non-matching path', () {
        final params = LinkParser.match('/about', '/home');
        expect(params, isNull);
      });

      test('returns null for different segment count', () {
        final params = LinkParser.match('/product/42/extra', '/product/:id');
        expect(params, isNull);
      });

      test('handles leading/trailing slashes', () {
        final params1 = LinkParser.match('product/42/', '/product/:id');
        final params2 = LinkParser.match('/product/42', 'product/:id/');
        expect(params1, isNotNull);
        expect(params2, isNotNull);
        expect(params1!['id'], equals('42'));
        expect(params2!['id'], equals('42'));
      });
    });

    group('extractQuery', () {
      test('extracts query parameters', () {
        final uri = Uri.parse('/search?q=flutter&category=mobile');
        final query = LinkParser.extractQuery(uri);
        expect(query['q'], equals('flutter'));
        expect(query['category'], equals('mobile'));
      });

      test('returns empty map for no query params', () {
        final uri = Uri.parse('/home');
        final query = LinkParser.extractQuery(uri);
        expect(query, isEmpty);
      });
    });

    group('combineParams', () {
      test('combines path and query parameters', () {
        final pathParams = {'id': '42'};
        final queryParams = {'source': 'email'};
        final combined = LinkParser.combineParams(pathParams, queryParams);
        expect(combined['id'], equals('42'));
        expect(combined['source'], equals('email'));
      });

      test('handles null path params', () {
        final queryParams = {'source': 'email'};
        final combined = LinkParser.combineParams(null, queryParams);
        expect(combined['source'], equals('email'));
        expect(combined.length, equals(1));
      });

      test('query params override path params with same key', () {
        final pathParams = {'id': '42'};
        final queryParams = {'id': '100'};
        final combined = LinkParser.combineParams(pathParams, queryParams);
        expect(combined['id'], equals('100'));
      });
    });
  });
}
