// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;

/// Web implementation of web storage helper utilizing local storage.
void saveToWebStorage(String key, String value) {
  html.window.localStorage[key] = value;
}

String? loadFromWebStorage(String key) {
  return html.window.localStorage[key];
}
