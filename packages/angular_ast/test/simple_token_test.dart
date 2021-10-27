import 'package:test/test.dart';
import 'package:angular_ast/src/token/tokens.dart';

void main() {
  group('SimpleToken', () {
    test('bang', () {
      var token = SimpleToken.bang(0);
      expect(token.lexeme, '!');
      expect(token.end, 1);
      expect(token.length, 1);
      expect(token.offset, 0);
      expect(token.type, SimpleTokenType.bang);
    });

    test('closeBracket', () {
      var token = SimpleToken.closeBracket(0);
      expect(token.lexeme, ']');
      expect(token.end, 1);
      expect(token.length, 1);
      expect(token.offset, 0);
      expect(token.type, SimpleTokenType.closeBracket);
    });

    test('closeParen', () {
      var token = SimpleToken.closeParen(0);
      expect(token.lexeme, ')');
      expect(token.end, 1);
      expect(token.length, 1);
      expect(token.offset, 0);
      expect(token.type, SimpleTokenType.closeParen);
    });

    test('commentBegin', () {
      var token = SimpleToken.commentBegin(0);
      expect(token.lexeme, '<!--');
      expect(token.end, 4);
      expect(token.length, 4);
      expect(token.offset, 0);
      expect(token.type, SimpleTokenType.commentBegin);
    });

    test('commentEnd', () {
      var token = SimpleToken.commentEnd(0);
      expect(token.lexeme, '-->');
      expect(token.end, 3);
      expect(token.length, 3);
      expect(token.offset, 0);
      expect(token.type, SimpleTokenType.commentEnd);
    });

    test('dash', () {
      var token = SimpleToken.dash(0);
      expect(token.lexeme, '-');
      expect(token.end, 1);
      expect(token.length, 1);
      expect(token.offset, 0);
      expect(token.type, SimpleTokenType.dash);
    });

    test('dashedIdenifier', () {
      var token = SimpleToken.identifier(0, 'some_dashed-identifier');
      expect(token.lexeme, 'some_dashed-identifier');
      expect(token.end, 22);
      expect(token.length, 22);
      expect(token.offset, 0);
      expect(token.type, SimpleTokenType.identifier);
    });

    test('tagStart', () {
      var token = SimpleToken.openTagStart(0);
      expect(token.lexeme, '<');
      expect(token.end, 1);
      expect(token.length, 1);
      expect(token.offset, 0);
      expect(token.type, SimpleTokenType.openTagStart);
    });

    test('tagEnd', () {
      var token = SimpleToken.tagEnd(0);
      expect(token.lexeme, '>');
      expect(token.end, 1);
      expect(token.length, 1);
      expect(token.offset, 0);
      expect(token.type, SimpleTokenType.tagEnd);
    });

    test('equalSign', () {
      var token = SimpleToken.equalSign(0);
      expect(token.lexeme, '=');
      expect(token.end, 1);
      expect(token.length, 1);
      expect(token.offset, 0);
      expect(token.type, SimpleTokenType.equalSign);
    });

    test('forwardSlash', () {
      var token = SimpleToken.forwardSlash(0);
      expect(token.lexeme, '/');
      expect(token.end, 1);
      expect(token.length, 1);
      expect(token.offset, 0);
      expect(token.type, SimpleTokenType.forwardSlash);
    });

    test('hash', () {
      var token = SimpleToken.hash(0);
      expect(token.lexeme, '#');
      expect(token.end, 1);
      expect(token.length, 1);
      expect(token.offset, 0);
      expect(token.type, SimpleTokenType.hash);
    });

    test('identifier', () {
      var token = SimpleToken.identifier(0, 'some_tag_identifier');
      expect(token.lexeme, 'some_tag_identifier');
      expect(token.end, 19);
      expect(token.length, 19);
      expect(token.offset, 0);
      expect(token.type, SimpleTokenType.identifier);
    });

    test('mustacheBegin', () {
      var token = SimpleToken.mustacheBegin(0);
      expect(token.lexeme, '{{');
      expect(token.end, 2);
      expect(token.length, 2);
      expect(token.offset, 0);
      expect(token.type, SimpleTokenType.mustacheBegin);
    });

    test('mustacheEnd', () {
      var token = SimpleToken.mustacheEnd(0);
      expect(token.lexeme, '}}');
      expect(token.end, 2);
      expect(token.length, 2);
      expect(token.offset, 0);
      expect(token.type, SimpleTokenType.mustacheEnd);
    });

    test('openBracket', () {
      var token = SimpleToken.openBracket(0);
      expect(token.lexeme, '[');
      expect(token.end, 1);
      expect(token.length, 1);
      expect(token.offset, 0);
      expect(token.type, SimpleTokenType.openBracket);
    });

    test('openParen', () {
      var token = SimpleToken.openParen(0);
      expect(token.lexeme, '(');
      expect(token.end, 1);
      expect(token.length, 1);
      expect(token.offset, 0);
      expect(token.type, SimpleTokenType.openParen);
    });

    test('period', () {
      var token = SimpleToken.period(0);
      expect(token.lexeme, '.');
      expect(token.end, 1);
      expect(token.length, 1);
      expect(token.offset, 0);
      expect(token.type, SimpleTokenType.period);
    });

    test('star', () {
      var token = SimpleToken.star(0);
      expect(token.end, 1);
      expect(token.length, 1);
      expect(token.offset, 0);
      expect(token.type, SimpleTokenType.star);
    });

    test('atSign', () {
      var token = SimpleToken.atSign(0);
      expect(token.end, 1);
      expect(token.length, 1);
      expect(token.offset, 0);
      expect(token.type, SimpleTokenType.atSign);
    });

    test('text', () {
      var token = SimpleToken.text(0, 'some long text string');
      expect(token.lexeme, 'some long text string');
      expect(token.end, 21);
      expect(token.length, 21);
      expect(token.offset, 0);
      expect(token.type, SimpleTokenType.text);
    });

    test('decoded text', () {
      var token = SimpleToken.decodedText(0, '∑', 7);
      expect(token.lexeme, '∑');
      expect(token.end, 7);
      expect(token.length, 7);
      expect(token.offset, 0);
      expect(token.type, SimpleTokenType.text);
    });

    test('unexpectedChar', () {
      var token = SimpleToken.unexpectedChar(0, '!@#\$');
      expect(token.lexeme, '!@#\$');
      expect(token.end, 4);
      expect(token.length, 4);
      expect(token.offset, 0);
      expect(token.type, SimpleTokenType.unexpectedChar);
    });

    test('whitespace', () {
      var token = SimpleToken.whitespace(0, '     \t\t\n');
      expect(token.lexeme, '     \t\t\n');
      expect(token.end, 8);
      expect(token.length, 8);
      expect(token.offset, 0);
      expect(token.type, SimpleTokenType.whitespace);
    });

    test('doubleQuotedText - closed', () {
      var quoteToken = SimpleQuoteToken.doubleQuotedText(0, '"this is a "quoted" text"', true);
      expect(quoteToken.lexeme, '"this is a "quoted" text"');
      expect(quoteToken.contentLexeme, 'this is a "quoted" text');
      expect(quoteToken.contentEnd, 24);
      expect(quoteToken.contentLength, 23);
      expect(quoteToken.contentOffset, 1);
      expect(quoteToken.quoteEndOffset, 24);
      expect(quoteToken.end, 25);
      expect(quoteToken.offset, 0);
      expect(quoteToken.lexeme, '"this is a "quoted" text"');
      expect(quoteToken.length, 25);
      expect(quoteToken.type, SimpleTokenType.doubleQuote);
    });

    test('doubleQuotedText - open', () {
      var quoteToken = SimpleQuoteToken.doubleQuotedText(0, '"this is a "quoted" text', false);
      expect(quoteToken.contentLexeme, 'this is a "quoted" text');
      expect(quoteToken.contentEnd, 24);
      expect(quoteToken.contentLength, 23);
      expect(quoteToken.contentOffset, 1);
      expect(quoteToken.quoteEndOffset, null);
      expect(quoteToken.offset, 0);
      expect(quoteToken.lexeme, '"this is a "quoted" text');
      expect(quoteToken.length, 24);
      expect(quoteToken.type, SimpleTokenType.doubleQuote);
    });

    test('singleQuotedText - closed', () {
      var quoteToken = SimpleQuoteToken.singleQuotedText(0, "'this is a 'quoted' text'", true);
      expect(quoteToken.contentLexeme, "this is a 'quoted' text");
      expect(quoteToken.contentEnd, 24);
      expect(quoteToken.contentLength, 23);
      expect(quoteToken.contentOffset, 1);
      expect(quoteToken.quoteEndOffset, 24);
      expect(quoteToken.end, 25);
      expect(quoteToken.offset, 0);
      expect(quoteToken.lexeme, "'this is a 'quoted' text'");
      expect(quoteToken.length, 25);
      expect(quoteToken.type, SimpleTokenType.singleQuote);
    });

    test('doubleQuotedText - open', () {
      var quoteToken = SimpleQuoteToken.singleQuotedText(0, "'this is a 'quoted' text", false);
      expect(quoteToken.contentLexeme, "this is a 'quoted' text");
      expect(quoteToken.end, 24);
      expect(quoteToken.contentLength, 23);
      expect(quoteToken.contentOffset, 1);
      expect(quoteToken.quoteEndOffset, null);
      expect(quoteToken.offset, 0);
      expect(quoteToken.lexeme, "'this is a 'quoted' text");
      expect(quoteToken.length, 24);
      expect(quoteToken.type, SimpleTokenType.singleQuote);
    });
  });
}
