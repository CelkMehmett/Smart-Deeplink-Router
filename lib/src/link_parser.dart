/// Utilities for parsing URIs and extracting route parameters.
class LinkParser {
  LinkParser._();

  /// Matches a URI path against a route pattern and extracts parameters.
  ///
  /// Returns a map of parameter names to values if the path matches the pattern,
  /// or `null` if there's no match.
  ///
  /// Example:
  /// ```dart
  /// final params = LinkParser.match('/product/42', '/product/:id');
  /// // params = {'id': '42'}
  /// ```
  static Map<String, String>? match(String path, String pattern) {
    final pathSegments = _normalize(path).split('/');
    final patternSegments = _normalize(pattern).split('/');

    if (pathSegments.length != patternSegments.length) {
      return null;
    }

    final params = <String, String>{};

    for (int i = 0; i < pathSegments.length; i++) {
      final pathSeg = pathSegments[i];
      final patternSeg = patternSegments[i];

      if (patternSeg.startsWith(':')) {
        // Parameter segment
        final paramName = patternSeg.substring(1);
        params[paramName] = pathSeg;
      } else if (pathSeg != patternSeg) {
        // Literal segment doesn't match
        return null;
      }
    }

    return params;
  }

  /// Extracts query parameters from a URI.
  ///
  /// Example:
  /// ```dart
  /// final uri = Uri.parse('/search?q=flutter&category=mobile');
  /// final query = LinkParser.extractQuery(uri);
  /// // query = {'q': 'flutter', 'category': 'mobile'}
  /// ```
  static Map<String, String> extractQuery(Uri uri) {
    return uri.queryParameters;
  }

  /// Combines path parameters and query parameters into a single map.
  static Map<String, String> combineParams(
    Map<String, String>? pathParams,
    Map<String, String> queryParams,
  ) {
    final combined = <String, String>{};
    if (pathParams != null) {
      combined.addAll(pathParams);
    }
    combined.addAll(queryParams);
    return combined;
  }

  /// Normalizes a path by removing leading/trailing slashes.
  static String _normalize(String path) {
    String normalized = path.trim();
    if (normalized.startsWith('/')) {
      normalized = normalized.substring(1);
    }
    if (normalized.endsWith('/')) {
      normalized = normalized.substring(0, normalized.length - 1);
    }
    return normalized;
  }
}
