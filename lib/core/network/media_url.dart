import 'api_endpoints.dart';

/// Rewrites a backend-hosted media URL so it loads from the current API origin.
///
/// The hosted backend stores absolute URLs using whatever trial host was live
/// at upload time (`*.jtempurl.com`, `*.etempurl.com`, …). Those hosts rotate
/// when the free trial is replaced, so a stored avatar like
/// `http://xstoreegy-001-site1.jtempurl.com/uploads/avatars/<id>.jpg` 404s
/// even though the same path is 200 on [ApiEndpoints.baseUrl]. Relative
/// `/uploads/…` paths and any `/uploads/` URL on a stale origin are resolved
/// against the current origin. External URLs (Google/Facebook photos, picsum
/// mocks) are left unchanged.
String resolveBackendMediaUrl(String url, {String? origin}) {
  final trimmed = url.trim();
  if (trimmed.isEmpty) return trimmed;

  final originUri = Uri.parse(
    (origin ?? ApiEndpoints.baseUrl).replaceAll(RegExp(r'/+$'), ''),
  );
  final uri = Uri.tryParse(trimmed);
  if (uri == null) return trimmed;

  if (uri.host.isEmpty) {
    return originUri.resolve(trimmed).toString();
  }

  final sameOrigin = uri.host.toLowerCase() == originUri.host.toLowerCase() &&
      uri.scheme.toLowerCase() == originUri.scheme.toLowerCase();
  if (sameOrigin) return trimmed;

  if (!_shouldRewriteToApiOrigin(uri)) return trimmed;

  return Uri(
    scheme: originUri.scheme,
    host: originUri.host,
    port: originUri.hasPort ? originUri.port : null,
    path: uri.path,
    query: uri.query.isEmpty ? null : uri.query,
    fragment: uri.fragment.isEmpty ? null : uri.fragment,
  ).toString();
}

bool _shouldRewriteToApiOrigin(Uri uri) {
  final host = uri.host.toLowerCase();
  if (host.endsWith('.tempurl.com') ||
      host.endsWith('.jtempurl.com') ||
      host.endsWith('.etempurl.com')) {
    return true;
  }
  return uri.path == '/uploads' || uri.path.startsWith('/uploads/');
}
