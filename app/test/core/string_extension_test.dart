import 'package:flutter_test/flutter_test.dart';
import 'package:quantumphysique/quantumphysique.dart';

void main() {
  group('CapExtension', () {
    test('inCaps capitalizes first character', () {
      expect('hello'.inCaps, 'Hello');
      expect('world'.inCaps, 'World');
    });

    test('inCaps handles single character', () {
      expect('a'.inCaps, 'A');
    });

    test('inCaps handles empty string', () {
      expect(''.inCaps, '');
    });

    test('inCaps handles already capitalized', () {
      expect('Hello'.inCaps, 'Hello');
    });

    test('allInCaps capitalizes each word', () {
      expect('hello world'.allInCaps, 'Hello World');
      expect('foo bar baz'.allInCaps, 'Foo Bar Baz');
    });

    test('allInCaps handles extra spaces', () {
      expect('hello  world'.allInCaps, 'Hello World');
      expect('a   b'.allInCaps, 'A B');
    });

    test('allInCaps handles single word', () {
      expect('hello'.allInCaps, 'Hello');
    });
  });
}
