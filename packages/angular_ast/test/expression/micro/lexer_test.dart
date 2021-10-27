import 'package:test/test.dart';
import 'package:angular_ast/src/expression/micro/lexer.dart';
import 'package:angular_ast/src/expression/micro/token.dart';

Iterable<MicroToken> tokenize(String html) {
  return const MicroLexer().tokenize(html);
}

// Returns the html parsed as a series of tokens, then back to html.
String untokenize(Iterable<MicroToken> tokens) {
  return tokens.fold(StringBuffer(), (buffer, token) => (buffer as StringBuffer)..write(token.lexeme)).toString();
}

void main() {
  group('MicroLexer', () {
    test('should tokenize a single let', () {
      expect(tokenize('let foo'), <MicroToken>[
        MicroToken.letKeyword(0, 'let'),
        MicroToken.letKeywordAfter(3, ' '),
        MicroToken.letIdentifier(4, 'foo')
      ]);
    });

    test('should tokenize multiple lets', () {
      expect(tokenize('let foo; let bar;let baz'), <MicroToken>[
        MicroToken.letKeyword(0, 'let'),
        MicroToken.letKeywordAfter(3, ' '),
        MicroToken.letIdentifier(4, 'foo'),
        MicroToken.endExpression(7, '; '),
        MicroToken.letKeyword(9, 'let'),
        MicroToken.letKeywordAfter(12, ' '),
        MicroToken.letIdentifier(13, 'bar'),
        MicroToken.endExpression(16, ';'),
        MicroToken.letKeyword(17, 'let'),
        MicroToken.letKeywordAfter(20, ' '),
        MicroToken.letIdentifier(21, 'baz')
      ]);
    });

    test('should tokenize a let assignment', () {
      expect(tokenize('let foo = bar'), <MicroToken>[
        MicroToken.letKeyword(0, 'let'),
        MicroToken.letKeywordAfter(3, ' '),
        MicroToken.letIdentifier(4, 'foo'),
        MicroToken.letAssignmentBefore(7, ' = '),
        MicroToken.letAssignment(10, 'bar')
      ]);
    });

    test('should tokenize multiple let assignments', () {
      expect(tokenize('let aaa = bbb; let ccc = ddd'), <MicroToken>[
        MicroToken.letKeyword(0, 'let'),
        MicroToken.letKeywordAfter(3, ' '),
        MicroToken.letIdentifier(4, 'aaa'),
        MicroToken.letAssignmentBefore(7, ' = '),
        MicroToken.letAssignment(10, 'bbb'),
        MicroToken.endExpression(13, '; '),
        MicroToken.letKeyword(15, 'let'),
        MicroToken.letKeywordAfter(18, ' '),
        MicroToken.letIdentifier(19, 'ccc'),
        MicroToken.letAssignmentBefore(22, ' = '),
        MicroToken.letAssignment(25, 'ddd')
      ]);
    });

    test('should tokenize a let with an implicit bind', () {
      expect(tokenize('let item of items'), <MicroToken>[
        MicroToken.letKeyword(0, 'let'),
        MicroToken.letKeywordAfter(3, ' '),
        MicroToken.letIdentifier(4, 'item'),
        MicroToken.endExpression(8, ' '),
        MicroToken.bindIdentifier(9, 'of'),
        MicroToken.bindExpressionBefore(11, ' '),
        MicroToken.bindExpression(12, 'items')
      ]);
    });

    test('should tokenize a let with multiple implicit binds', () {
      expect(tokenize('let item of items; trackBy: byID'), <MicroToken>[
        MicroToken.letKeyword(0, 'let'),
        MicroToken.letKeywordAfter(3, ' '),
        MicroToken.letIdentifier(4, 'item'),
        MicroToken.endExpression(8, ' '),
        MicroToken.bindIdentifier(9, 'of'),
        MicroToken.bindExpressionBefore(11, ' '),
        MicroToken.bindExpression(12, 'items'),
        MicroToken.endExpression(17, ' '),
        MicroToken.bindIdentifier(19, 'trackBy'),
        MicroToken.bindExpressionBefore(26, ': '),
        MicroToken.bindExpression(28, 'byID')
      ]);
    });

    test('should tokenize a complex micro expression', () {
      var expression = 'let item of items; trackBy: byId; let i = index';
      expect(untokenize(tokenize(expression)), expression);
    });

    test('should tokenize multiple bindings', () {
      expect(tokenize('templateRef; context: templateContext'), <MicroToken>[
        MicroToken.bindExpression(0, 'templateRef'),
        MicroToken.endExpression(11, '; '),
        MicroToken.bindIdentifier(13, 'context'),
        MicroToken.bindExpressionBefore(20, ': '),
        MicroToken.bindExpression(22, 'templateContext')
      ]);
    });

    test('should handle newline after identifier', () {
      expect(tokenize('let item of\n items'), <MicroToken>[
        MicroToken.letKeyword(0, 'let'),
        MicroToken.letKeywordAfter(3, ' '),
        MicroToken.letIdentifier(4, 'item'),
        MicroToken.endExpression(8, ' '),
        MicroToken.bindIdentifier(9, 'of'),
        MicroToken.bindExpressionBefore(11, '\n '),
        MicroToken.bindExpression(13, 'items')
      ]);
    });
  });
}
