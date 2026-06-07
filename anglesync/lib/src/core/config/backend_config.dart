class BackendConfig {
  const BackendConfig._();

  static const String baseUrl = 'http://127.0.0.1:8000';

  static String resolveUrl(String? path) {
    if (path == null || path.isEmpty) {
      return '';
    }

    final uri = Uri.tryParse(path);
    if (uri != null && uri.hasScheme) {
      return path;
    }

    return Uri.parse(baseUrl).resolve(path).toString();
  }
}
