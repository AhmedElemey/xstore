import 'package:flutter_test/flutter_test.dart';
import 'package:xstore/core/network/media_url.dart';

void main() {
  const current = 'https://xstoreegy002-001-site1.etempurl.com';

  test('rewrites a stale jtempurl avatar onto the current API origin', () {
    const stale =
        'http://xstoreegy-001-site1.jtempurl.com/uploads/avatars/67fa8938-3b1a-44b5-8a47-d6053212e225.jpg';
    expect(
      resolveBackendMediaUrl(stale, origin: current),
      '$current/uploads/avatars/67fa8938-3b1a-44b5-8a47-d6053212e225.jpg',
    );
  });

  test('resolves a relative uploads path against the current origin', () {
    expect(
      resolveBackendMediaUrl(
        '/uploads/avatars/example.jpg',
        origin: current,
      ),
      '$current/uploads/avatars/example.jpg',
    );
  });

  test('rewrites /uploads/ on a non-API host', () {
    expect(
      resolveBackendMediaUrl(
        'http://example.com/uploads/avatars/e4a956c2.jpg',
        origin: current,
      ),
      '$current/uploads/avatars/e4a956c2.jpg',
    );
  });

  test('leaves an already-current URL unchanged', () {
    const live = '$current/uploads/avatars/live.jpg';
    expect(resolveBackendMediaUrl(live, origin: current), live);
  });

  test('leaves Google / picsum URLs unchanged', () {
    const google = 'https://lh3.googleusercontent.com/a/photo';
    const picsum = 'https://picsum.photos/seed/avatar1/100/100';
    expect(resolveBackendMediaUrl(google, origin: current), google);
    expect(resolveBackendMediaUrl(picsum, origin: current), picsum);
  });

  test('blank stays blank', () {
    expect(resolveBackendMediaUrl('', origin: current), '');
    expect(resolveBackendMediaUrl('   ', origin: current), '');
  });
}
