import 'dart:io';

String readFileAsString(String name) {
  final file = new File(name);
  return file.readAsStringSync();
}