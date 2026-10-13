// Replaces the browser's address without reloading (web only; no-op elsewhere).
export 'browser_url_stub.dart' if (dart.library.js_interop) 'browser_url_web.dart';
