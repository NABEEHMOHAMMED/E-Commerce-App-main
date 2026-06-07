import 'web_storage_stub.dart'
    if (dart.library.html) 'web_storage_web.dart' as helper;

/// Saves a value to web's localStorage if on web, otherwise does nothing.
void saveToWebStorage(String key, String value) {
  helper.saveToWebStorage(key, value);
}

/// Loads a value from web's localStorage if on web, otherwise returns null.
String? loadFromWebStorage(String key) {
  return helper.loadFromWebStorage(key);
}
