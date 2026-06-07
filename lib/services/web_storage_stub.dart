/// Stub implementation of web storage helper to prevent compilation errors on mobile/desktop platforms.
void saveToWebStorage(String key, String value) {
  // No-op on mobile/desktop platforms
}

String? loadFromWebStorage(String key) {
  // Returns null on mobile/desktop platforms
  return null;
}
