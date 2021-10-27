import 'package:test/test.dart';
import 'package:angular_ast/src/token/tokens.dart';

void main() {
  group('Token', () {
    test('beforeElementDecorator', () {
      var token = Token.beforeElementDecorator(0, '\n  \n');
      expect(token.lexeme, '\n  \n');
      expect(token.end, 4);
      expect(token.length, 4);
      expect(token.offset, 0);
      expect(token.type, TokenType.beforeElementDecorator);
    });

    test('closeElementEnd', () {
      var token = Token.closeElementEnd(0);
      expect(token.lexeme, '>');
      expect(token.end, 1);
      expect(token.length, 1);
      expect(token.offset, 0);
      expect(token.type, TokenType.closeElementEnd);
    });

    test('closeElementStart', () {
      var token = Token.closeElementStart(0);
      expect(token.lexeme, '</');
      expect(token.end, 2);
      expect(token.length, 2);
      expect(token.offset, 0);
      expect(token.type, TokenType.closeElementStart);
    });

    test('elementDecorator', () {
      var token = Token.elementDecorator(0, 'title');
      expect(token.lexeme, 'title');
      expect(token.end, 5);
      expect(token.length, 5);
      expect(token.offset, 0);
      expect(token.type, TokenType.elementDecorator);
    });

    test('elementIdentifier', () {
      var token = Token.elementIdentifier(0, 'div');
      expect(token.lexeme, 'div');
      expect(token.end, 3);
      expect(token.length, 3);
      expect(token.offset, 0);
      expect(token.type, TokenType.elementIdentifier);
    });

    test('openElementEnd', () {
      var token = Token.openElementEnd(0);
      expect(token.lexeme, '>');
      expect(token.end, 1);
      expect(token.length, 1);
      expect(token.offset, 0);
      expect(token.type, TokenType.openElementEnd);
    });

    test('openElementStart', () {
      var token = Token.openElementStart(0);
      expect(token.lexeme, '<');
      expect(token.end, 1);
      expect(token.length, 1);
      expect(token.offset, 0);
      expect(token.type, TokenType.openElementStart);
    });

    test('text', () {
      var token = Token.text(0, 'Hello');
      expect(token.lexeme, 'Hello');
      expect(token.end, 5);
      expect(token.length, 5);
      expect(token.offset, 0);
      expect(token.type, TokenType.text);
    });
  });
}
