import 'package:flutter_test/flutter_test.dart';
import 'package:trale/core/stringExtension.dart';

void main() {
  group('CapExtension', () {
    group('inCaps', () {
      test('capitalizes first character', () {
        expect('hello'.inCaps, 'Hello');
        expect('world'.inCaps, 'World');
        expect('test'.inCaps, 'Test');
      });

      test('handles already capitalized strings', () {
        expect('Hello'.inCaps, 'Hello');
        expect('WORLD'.inCaps, 'WORLD');
      });

      test('handles empty string', () {
        expect(''.inCaps, '');
      });

      test('handles single character', () {
        expect('a'.inCaps, 'A');
        expect('A'.inCaps, 'A');
      });

      test('preserves rest of string', () {
        expect('hELLO'.inCaps, 'HELLO');
        expect('hello world'.inCaps, 'Hello world');
      });
    });

    group('allInCaps', () {
      test('capitalizes first character of each word', () {
        expect('hello world'.allInCaps, 'Hello World');
        expect('the quick brown fox'.allInCaps, 'The Quick Brown Fox');
      });

      test('handles already capitalized words', () {
        expect('Hello World'.allInCaps, 'Hello World');
      });

      test('handles empty string', () {
        expect(''.allInCaps, '');
      });

      test('handles single word', () {
        expect('hello'.allInCaps, 'Hello');
      });

      test('handles multiple spaces', () {
        expect('hello  world'.allInCaps, 'Hello World');
        expect('hello   world'.allInCaps, 'Hello World');
      });

      test('handles leading and trailing spaces', () {
        expect(' hello world '.allInCaps, ' Hello World ');
      });

      test('handles mixed case', () {
        expect('hELLO wORLD'.allInCaps, 'HELLO WORLD');
      });
    });
  });
}
